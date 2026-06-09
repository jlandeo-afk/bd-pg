-- Function: questions.fn_teacher_assigned_question(integer, integer, character varying, bigint, character varying, smallint, smallint, smallint, smallint, smallint, character varying)

--

CREATE FUNCTION questions.fn_teacher_assigned_question(p_perpage integer, p_npage integer, p_name_text character varying, p_employee_id bigint, f_status character varying, f_course_id smallint, f_university_id smallint, f_option_id smallint, f_modality_id smallint, f_version smallint, f_year character varying) RETURNS TABLE(key_question text, id bigint, code character varying, short_description text, number_question character varying, number character varying, course_id smallint, code_course character varying, course character varying, status character varying, parent_id bigint, type_question text, teacher_id bigint, code_teacher character varying, teacher text, date_status timestamp without time zone, total_refuzed bigint, subquestions jsonb, question_origin jsonb, priority integer, is_missing_question boolean, total_observed bigint, total bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    C_MORE_RECENT_VERSION smallint DEFAULT 1;
    C_FORWARD_STATUS varchar[] := ARRAY['INDE', 'DASI', 'OBSE', 'DIG', 'VERI', 'APRB', 'PEND', 'RESV'];
    offset_val integer := p_perpage * (p_npage - 1);
    status_array varchar[];
BEGIN
    -- Manejo del parámetro f_status
    IF f_status IS NULL OR f_status = '' OR f_status NOT IN ('ASIG', 'RESO', 'SSOL', 'RECH') THEN
        status_array := ARRAY['ASIG', 'RESO', 'SSOL', 'RECH'];
    ELSE
        status_array := ARRAY[f_status];
    END IF;
    RETURN QUERY WITH employee_course AS (
        SELECT
            ec.course_id
        FROM
            employee_course ec
        WHERE (p_employee_id IS NULL
            OR ec.teacher_id = p_employee_id)
),
asig_questions AS (
    SELECT
        q.*,
        qn.question_origin,
        qn.university_id,
        qn.option_id,
        qn.modality_id,
        qn."version",
        qn."year"
    FROM
        question q
        LEFT JOIN v_all_question_origins qn ON qn.question_id = q.id
    WHERE
        1 = 1
        AND q.fl_status = TRUE
        AND (q.parent_id IS NULL
            AND q.status = ANY (ARRAY[status_array])
            OR q.parent_id IS NOT NULL
            AND (q.status = ANY (ARRAY[status_array])
                OR q.status = ANY (ARRAY[C_FORWARD_STATUS])))
        AND q.deleted_at IS NULL
        AND (f_university_id IS NULL
            OR qn.university_id = f_university_id)
        AND (f_option_id IS NULL
            OR qn.option_id = f_option_id)
        AND (f_modality_id IS NULL
            OR qn.modality_id = f_modality_id)
        AND (f_version IS NULL
            OR qn."version" = f_version)
        AND (f_year IS NULL
            OR qn."year" = f_year)
),
questions AS (
    SELECT
        concat('p_', q.id) AS key_question,
        q.id,
        q.code,
        q.short_description,
        q.number_question,
        q.number,
        q.course_id,
        c.code AS code_course,
        c.name AS course,
        q.status,
        q.parent_id,
        CASE WHEN q.parent_id IS NULL THEN
            'P'
        ELSE
            'S'
        END AS type_question,
        es1.id AS teacher_id,
        es1.code AS code_teacher,
        CONCAT(es1.first_surname, ' ', es1.second_surname, ' ', es1.first_name) AS teacher,
        qs.created_at AS date_status,
        (
            SELECT
                COUNT(*)
            FROM
                question_refuzed qr2
            WHERE
                qr2.question_id = q.id
                AND qr2.fl_status = TRUE) AS total_refuzed,
            q.question_origin,
            q.priority,
            CASE WHEN mmqd.question_id IS NOT NULL THEN
                TRUE
            ELSE
                FALSE
            END AS is_missing_question
        FROM
            asig_questions q
            INNER JOIN course c ON q.course_id = c.id
            LEFT JOIN question_status qs ON qs.fl_active = TRUE
                AND q.id = qs.question_id
                AND q.status = qs.status
            INNER JOIN employee_question eq ON eq.question_id = q.id
                AND eq.fl_status = TRUE
            INNER JOIN employees es1 ON eq.teacher_id = es1.id
            LEFT JOIN material_missing_question_detail mmqd ON mmqd.question_id = q.id
        WHERE
            1 = 1
            AND (p_employee_id IS NULL
                OR es1.id = p_employee_id)
),
sub_questions AS (
    SELECT
        pq.id AS parent_id,
        jsonb_agg(jsonb_build_object('key_question', concat('s_', q.id), 'id', q.id, 'code', q.code, 'short_description', q.short_description, 'number_question', q.number_question, 'number', q.number, 'course_id', q.course_id, 'code_course', c.code, 'course', c.name, 'status', q.status, 'parent_id', q.parent_id, 'type_question', 'S', 'teacher_id', es1.id, 'code_teacher', es1.code, 'teacher', CONCAT(es1.first_surname, ' ', es1.second_surname, ' ', es1.first_name), 'date_status', qs.created_at, 'total_refuzed', (
                    SELECT
                        COUNT(*)
                    FROM question_refuzed qr
                    WHERE
                        qr.question_id = q.id
                        AND qr.fl_status = TRUE), 'origin_question', q.question_origin)) AS subquestions
    FROM
        asig_questions q
        INNER JOIN parent_question pq ON q.parent_id = pq.id
            AND pq.status = ANY (ARRAY[status_array])
            INNER JOIN course c ON q.course_id = c.id
            LEFT JOIN question_status qs ON q.id = qs.question_id
                AND q.status = qs.status
                AND qs.fl_active = TRUE
            INNER JOIN employee_question eq ON eq.question_id = q.id
                AND eq.fl_status = TRUE
            INNER JOIN employees es1 ON eq.teacher_id = es1.id
        WHERE
            1 = 1
            AND (p_employee_id IS NULL
                OR es1.id = p_employee_id)
        GROUP BY
            pq.id
),
tbl_question AS (
    SELECT
        concat('p_', q.id) AS key_question,
        q.id,
        q.code,
        q.short_description,
        q.number_question,
        q.number,
        q.course_id,
        q.code_course,
        q.course,
        q.status,
        q.parent_id,
        q.type_question,
        q.teacher_id,
        q.code_teacher,
        q.teacher,
        q.date_status,
        q.total_refuzed,
        COALESCE(sq.subquestions, '[]'::jsonb) AS subquestions,
        q.question_origin,
        q.priority,
        q.is_missing_question
    FROM
        questions q
        LEFT JOIN sub_questions sq ON q.parent_id = sq.parent_id
    WHERE
        q.parent_id IS NULL
    UNION ALL SELECT DISTINCT
        concat('t_', pq.id) AS key_question,
        pq.id,
        pq.code,
        pq.short_description,
        pq.number_question,
        pq.number,
        pq.course_id,
        c.code AS code_course,
        c.name AS course,
        pq.status,
        pq.id AS parent_id,
        'T' AS type_question,
        NULL::bigint AS teacher_id,
        NULL::varchar AS code_teacher,
        NULL::text AS teacher,
        pq.created_at AS date_status,
        0::bigint AS total_refuzed,
        COALESCE(sq.subquestions, '[]'::jsonb) AS subquestions,
        opq.question_origin,
        pq.priority,
        FALSE AS is_missing_question
    FROM
        parent_question pq
        INNER JOIN course c ON pq.course_id = c.id
        LEFT JOIN sub_questions sq ON pq.id = sq.parent_id
            AND sq.parent_id IS NOT NULL
        LEFT JOIN v_all_parent_origins opq ON opq.parent_id = pq.id
    WHERE
        pq.fl_status = TRUE
        AND pq.status <> 'DUPL'
        AND pq.deleted_at IS NULL
        AND (sq.subquestions <> '[]')
        AND (f_university_id IS NULL
            OR opq.university_id = f_university_id)
        AND (f_option_id IS NULL
            OR opq.option_id = f_option_id)
        AND (f_modality_id IS NULL
            OR opq.modality_id = f_modality_id)
        AND (f_version IS NULL
            OR opq."version" = f_version)
        AND (f_year IS NULL
            OR opq."year" = f_year)
),
observed_questions AS (
    SELECT
        q.id,
        COUNT(*) total_observed
    FROM
        question q
        JOIN question_status qs ON qs.question_id = q.id
    WHERE
        q.status = 'DIGI'
        AND qs.status = 'OBSE'
    GROUP BY
        q.id
),
filtered_questions AS (
    SELECT
        tq.*,
        oq.total_observed
    FROM
        tbl_question tq
        LEFT JOIN observed_questions oq ON oq.id = tq.id
    WHERE (f_course_id IS NULL
        OR tq.course_id = f_course_id)
    AND (p_employee_id IS NULL
        OR tq.course_id IN (
            SELECT
                *
            FROM
                employee_course))
        AND (p_name_text IS NULL
            OR unaccent(LOWER(tq.short_description))
            LIKE '%' || LOWER(p_name_text) || '%'
            OR LOWER(tq.number_question)
            LIKE '%' || LOWER(p_name_text) || '%'
            OR LOWER(tq.number)
            LIKE '%' || LOWER(p_name_text) || '%'
            OR LOWER(tq.code)
            LIKE '%' || LOWER(p_name_text) || '%'
            OR EXISTS (
                SELECT
                    1
                FROM
                    jsonb_array_elements(tq.subquestions) AS sq
                WHERE
                    unaccent(LOWER(sq ->> 'short_description'))
                    LIKE '%' || LOWER(p_name_text) || '%'
                    OR LOWER(sq ->> 'number_question')
                    LIKE '%' || LOWER(p_name_text) || '%'
                    OR LOWER(sq ->> 'number')
                    LIKE '%' || LOWER(p_name_text) || '%'
                    OR LOWER(sq ->> 'code')
                    LIKE '%' || LOWER(p_name_text) || '%'))
),
counted_questions AS (
    SELECT
        *,
        count(*) OVER () AS total
    FROM
        filtered_questions
)
SELECT
    *
FROM
    counted_questions
ORDER BY
    priority DESC,
    date_status ASC,
    key_question ASC
LIMIT p_perpage OFFSET offset_val;
END;
$$;


ALTER FUNCTION questions.fn_teacher_assigned_question(p_perpage integer, p_npage integer, p_name_text character varying, p_employee_id bigint, f_status character varying, f_course_id smallint, f_university_id smallint, f_option_id smallint, f_modality_id smallint, f_version smallint, f_year character varying) OWNER TO postgres;

--
