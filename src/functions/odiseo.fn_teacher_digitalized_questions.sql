-- Function: odiseo.fn_teacher_digitalized_questions(integer, integer, character varying, bigint, character varying, smallint, smallint, smallint, smallint, smallint, character varying)

--

CREATE FUNCTION odiseo.fn_teacher_digitalized_questions(p_perpage integer, p_npage integer, p_name_text character varying, p_employee_id bigint, f_status character varying, f_course_id smallint, f_university_id smallint, f_option_id smallint, f_modality_id smallint, f_version smallint, f_year character varying) RETURNS TABLE(key_question text, id bigint, code character varying, short_description text, number_question character varying, number character varying, course_id smallint, code_course character varying, course character varying, status character varying, parent_id bigint, type_question text, teacher_id bigint, teacher text, didi_id bigint, didi text, url_pdf_index character varying, url_pdf_digitalized character varying, date_status timestamp without time zone, observation text, subquestions jsonb, origin_question jsonb, priority integer, is_missing_question boolean, total_observed bigint, total bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    offset_val integer := p_perpage * (p_npage - 1);
BEGIN
    RETURN QUERY WITH employee_course AS (
        SELECT DISTINCT
            ec.course_id
        FROM
            employee_course ec
        WHERE (p_employee_id IS NULL
            OR ec.teacher_id = p_employee_id)
    ORDER BY
        ec.course_id ASC
),
digi_questions AS (
    SELECT
        q.id,
        q.code,
        q.short_description,
        q.number_question,
        q.number,
        q.course_id,
        q.status,
        q.parent_id,
        qn.question_origin,
        qn.university_id,
        qn.option_id,
        qn.modality_id,
        qn."version",
        qn."year",
        q.priority,
        CASE WHEN mmqd.question_id IS NOT NULL THEN
            TRUE
        ELSE
            FALSE
        END AS is_missing_question
    FROM
        question q
        LEFT JOIN v_all_question_origins qn ON qn.question_id = q.id
        LEFT JOIN material_missing_question_detail mmqd ON mmqd.question_id = q.id
    WHERE
        1 = 1
        AND q.fl_status = TRUE
        AND q.parent_id IS NULL
        AND q.status IN ('DIGI', 'OBSE')
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
        CONCAT(es1.first_surname, ' ', es1.second_surname, ' ', es1.first_name) AS teacher,
        es2.id AS didi_id,
        CONCAT(es2.first_surname, ' ', es2.second_surname, ' ', es2.first_name) AS didi,
        eq.url_pdf_question_solution AS url_pdf_index,
        edq.url_file_digitalized_solution AS url_pdf_digitalized,
        qs.created_at AS date_status,
        qo.description AS observation,
        q.question_origin,
        q.priority,
        q.is_missing_question
    FROM
        digi_questions q
        INNER JOIN course c ON q.course_id = c.id
        LEFT JOIN question_status qs ON qs.fl_active = TRUE
            AND q.id = qs.question_id
            AND q.status = qs.status
        INNER JOIN employee_question eq ON eq.question_id = q.id
            AND eq.fl_status = TRUE
        LEFT JOIN employees es1 ON eq.teacher_id = es1.id
        INNER JOIN employee_didi_question edq ON edq.question_id = q.id
            AND edq.fl_status = TRUE
        LEFT JOIN employees es2 ON edq.employee_id = es2.id
        LEFT JOIN question_observation qo ON qo.question_id = q.id
            AND qo.fl_status = TRUE
            AND qo.type IN ('DIGI', 'OBSE')
    WHERE
        1 = 1
        AND (p_employee_id IS NULL
            OR es1.id = p_employee_id)
        AND q.parent_id IS NULL
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
        q.teacher,
        q.didi_id,
        q.didi,
        q.url_pdf_index,
        q.url_pdf_digitalized,
        q.date_status,
        q.observation,
        '[]'::jsonb AS subquestions,
        q.question_origin,
        q.priority,
        q.is_missing_question
    FROM
        questions q
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
        NULL::text AS teacher,
        NULL::bigint AS didi_id,
        NULL::text AS didi,
        NULL::text AS url_pdf_index,
        NULL::text AS url_pdf_digitalized,
        pq.created_at AS date_status,
        NULL::text AS observation,
        JSONB_AGG(JSONB_BUILD_OBJECT('key_question', concat('s_', q.id), 'id', q.id, 'code', q.code, 'short_description', q.short_description, 'number_question', q.number_question, 'number', q.number, 'course_id', q.course_id, 'code_course', c.code, 'course', c.name, 'status', q.status, 'parent_id', q.parent_id, 'type_question', 'S', 'teacher_id', es1.id, 'teacher', CONCAT(es1.first_surname, ' ', es1.second_surname, ' ', es1.first_name), 'didi_id', es2.id, 'didi', CONCAT(es2.first_surname, ' ', es2.second_surname, ' ', es2.first_name), 'url_pdf_index', eq.url_pdf_question_solution, 'url_pdf_digitalized', edq.url_file_digitalized_solution, 'date_status', qs.created_at, 'observation', qo.description, 'origin_question', qn.question_origin)) AS subquestions,
        opq.question_origin,
        pq.priority,
        FALSE AS is_missing_question
    FROM
        parent_question pq
        JOIN question q ON pq.status IN ('DIGI', 'OBSE')
            AND pq.status <> 'DUPL'
            AND pq.id = q.parent_id
        LEFT JOIN question_status qs ON q.id = qs.question_id
            AND q.status = qs.status
            AND qs.fl_active IS TRUE
        INNER JOIN employee_question eq ON eq.question_id = q.id
            AND eq.fl_status IS TRUE
        LEFT JOIN employees es1 ON eq.teacher_id = es1.id
        INNER JOIN employee_didi_question edq ON edq.question_id = q.id
            AND edq.fl_status IS TRUE
        LEFT JOIN employees es2 ON edq.employee_id = es2.id
        LEFT JOIN question_observation qo ON qo.question_id = q.id
            AND qo.fl_status IS TRUE
        INNER JOIN course c ON pq.course_id = c.id
        LEFT JOIN v_all_question_origins qn ON qn.question_id = q.id
        LEFT JOIN v_all_parent_origins opq ON opq.parent_id = pq.id
    WHERE
        1 = 1
        AND pq.fl_status IS TRUE
        AND pq.deleted_at IS NULL
        AND (p_employee_id IS NULL
            OR es1.id = p_employee_id)
        AND (f_university_id IS NULL
            OR opq.university_id = f_university_id
            OR qn.university_id = f_university_id)
        AND (f_option_id IS NULL
            OR opq.option_id = f_option_id
            OR qn.option_id = f_option_id)
        AND (f_modality_id IS NULL
            OR opq.modality_id = f_modality_id
            OR qn.modality_id = f_modality_id)
        AND (f_version IS NULL
            OR opq."version" = f_version
            OR qn."version" = f_version)
        AND (f_year IS NULL
            OR opq."year" = f_year
            OR qn."year" = f_year)
    GROUP BY
        pq.id,
        opq.question_origin,
        c.id
    HAVING
        COUNT(q.*) > 0
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
        tbl_question.*,
        oq.total_observed
    FROM
        tbl_question
        LEFT JOIN observed_questions oq ON oq.id = tbl_question.id
    WHERE (f_course_id IS NULL
        OR tbl_question.course_id = f_course_id)
    AND (p_employee_id IS NULL
        OR tbl_question.course_id IN (
            SELECT
                *
            FROM
                employee_course))
        AND (p_name_text IS NULL
            OR unaccent(LOWER(tbl_question.short_description))
            LIKE '%' || LOWER(p_name_text) || '%'
            OR LOWER(tbl_question.number_question)
            LIKE '%' || LOWER(p_name_text) || '%'
            OR LOWER(tbl_question.number)
            LIKE '%' || LOWER(p_name_text) || '%'
            OR LOWER(tbl_question.code)
            LIKE '%' || LOWER(p_name_text) || '%'
            OR EXISTS (
                SELECT
                    1
                FROM
                    jsonb_array_elements(tbl_question.subquestions) AS sq
                WHERE
                    unaccent(LOWER(sq ->> 'short_description'))
                    LIKE '%' || LOWER(p_name_text) || '%'
                    OR LOWER(sq ->> 'number_question')
                    LIKE '%' || LOWER(p_name_text) || '%'
                    OR LOWER(sq ->> 'number')
                    LIKE '%' || LOWER(p_name_text) || '%'
                    OR LOWER(sq ->> 'code')
                    LIKE '%' || LOWER(p_name_text) || '%'))
            AND (f_status IS NULL
                OR tbl_question.status = f_status)
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
    priority DESC NULLS LAST,
    date_status ASC,
    key_question ASC
LIMIT p_perpage OFFSET offset_val;
END;
$$;


ALTER FUNCTION odiseo.fn_teacher_digitalized_questions(p_perpage integer, p_npage integer, p_name_text character varying, p_employee_id bigint, f_status character varying, f_course_id smallint, f_university_id smallint, f_option_id smallint, f_modality_id smallint, f_version smallint, f_year character varying) OWNER TO postgres;

--
