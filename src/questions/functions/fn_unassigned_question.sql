-- Function: questions.fn_unassigned_question(integer, integer, integer, character varying, bigint, integer, character varying, integer, smallint, smallint, smallint, smallint, character varying)

--

CREATE FUNCTION questions.fn_unassigned_question(p_perpage integer, p_npage integer, p_employee_id integer, p_name_text character varying, p_employee_didi_id bigint, f_course_id integer, f_type character varying, f_week_id integer, f_university_id smallint, f_option_id smallint, f_modality_id smallint, f_version smallint, f_year character varying) RETURNS TABLE(key_question text, id bigint, code character varying, short_description text, number_question character varying, number character varying, course_id smallint, code_course character varying, course character varying, status character varying, fl_status boolean, parent_id bigint, type_question text, subquestions jsonb, created_by bigint, created_at timestamp without time zone, user_name character varying, user_email odiseo.email_citext, employee_id bigint, name_employee text, origin_question jsonb, type_text_template_id smallint, priority integer, is_missing_question boolean, total bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    offset_val integer := p_perpage * (p_npage - 1);
    C_MORE_RECENT_VERSION smallint DEFAULT 1;
BEGIN
    RETURN QUERY WITH employee_course AS (
        SELECT
            ec.course_id
        FROM
            employee_course ec
        WHERE (p_employee_id IS NULL
            OR ec.teacher_id = p_employee_id)
),
sasi_questions AS (
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
        AND q.status = 'SASI'
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
p_s_questions AS (
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
        q.fl_status,
        q.parent_id,
        CASE WHEN q.parent_id IS NULL THEN
            'P'
        ELSE
            'S'
        END AS type_question,
        q.created_by,
        qs.created_at created_at,
        u.user AS user_name,
        u.email AS user_email,
        e.id AS employee_id,
        CONCAT(e.first_surname, ' ', e.second_surname, ' ', e.first_name) AS name_employee,
        q.question_origin,
        c.type_text_template_id,
        q.priority,
        CASE WHEN mmqd.question_id IS NOT NULL THEN
            TRUE
        ELSE
            FALSE
        END AS is_missing_question
    FROM
        sasi_questions q
        INNER JOIN course c ON q.course_id = c.id
        LEFT JOIN question_status qs ON qs.fl_active = TRUE
            AND q.id = qs.question_id
            AND q.status = qs.status
        LEFT JOIN users u ON q.created_by = u.id
        LEFT JOIN employees e ON u.id = e.user_id
        LEFT JOIN material_missing_question_detail mmqd ON mmqd.question_id = q.id
    WHERE
        1 = 1
        AND (p_employee_didi_id IS NULL
            OR e.id = p_employee_didi_id)
),
sub_questions AS (
    SELECT
        pq.id AS parent_id,
        jsonb_agg(jsonb_build_object('key_question', concat('s_', q.id), 'id', q.id, 'code', q.code, 'short_description', q.short_description, 'number_question', q.number_question, 'number', q.number, 'course_id', q.course_id, 'code_course', c.code, 'course', c.name, 'status', q.status, 'fl_status', q.fl_status, 'parent_id', q.parent_id, 'type_question', 'S', 'created_by', q.created_by, 'created_at', qs.created_at, 'user_name', u.user, 'user_email', u.email, 'employee_id', e.id, 'name_employee', CONCAT(e.first_surname, ' ', e.second_surname, ' ', e.first_name), 'origin_question', q.question_origin)) AS subquestions
    FROM
        sasi_questions q
        INNER JOIN parent_question pq ON q.parent_id = pq.id
        INNER JOIN course c ON q.course_id = c.id
        LEFT JOIN users u ON q.created_by = u.id
        LEFT JOIN employees e ON u.id = e.user_id
        LEFT JOIN question_status qs ON q.id = qs.question_id
            AND q.status = qs.status
            AND qs.fl_active = TRUE
    WHERE
        1 = 1
        AND (p_employee_didi_id IS NULL
            OR e.id = p_employee_didi_id)
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
        q.fl_status,
        q.parent_id,
        q.type_question,
        COALESCE(sq.subquestions, '[]'::jsonb) AS subquestions,
        q.created_by,
        q.created_at,
        q.user_name,
        q.user_email,
        q.employee_id,
        q.name_employee,
        q.question_origin,
        NULL AS type_text_template_id,
        q.priority,
        q.is_missing_question
    FROM
        p_s_questions q
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
        pq.fl_status,
        pq.id AS parent_id,
        'T' AS type_question,
        COALESCE(sq.subquestions, '[]'::jsonb) AS subquestions,
        pq.created_by,
        pq.created_at AS created_at,
        u.user AS user_name,
        u.email AS user_email,
        e.id AS employee_id,
        CONCAT(e.first_surname, ' ', e.second_surname, ' ', e.first_name) AS name_employee,
        opq.question_origin,
        c.type_text_template_id,
        pq.priority,
        FALSE AS is_missing_question
    FROM
        parent_question pq
        INNER JOIN course c ON pq.course_id = c.id
        LEFT JOIN type_text_templates ttt ON ttt.id = c.type_text_template_id
        LEFT JOIN users u ON pq.created_by = u.id
        LEFT JOIN employees e ON u.id = e.user_id
        LEFT JOIN sub_questions sq ON pq.id = sq.parent_id
            AND sq.parent_id IS NOT NULL
        LEFT JOIN v_all_parent_origins opq ON opq.parent_id = pq.id
    WHERE
        pq.fl_status = TRUE
        AND pq.status <> 'DUPL'
        AND pq.deleted_at IS NULL
        AND (p_employee_didi_id IS NULL
            OR e.id = p_employee_didi_id)
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
filtered_questions AS (
    SELECT
        *
    FROM
        tbl_question
    WHERE (f_course_id IS NULL
        OR tbl_question.course_id = f_course_id)
    AND (f_type IS NULL
        OR tbl_question.type_question = f_type)
    AND (p_employee_id IS NULL
        OR tbl_question.course_id IN (
            SELECT
                *
            FROM
                employee_course))
        AND (p_name_text IS NULL
            OR unaccent(LOWER(tbl_question.short_description))
            ILIKE '%' || LOWER(p_name_text) || '%'
            OR LOWER(tbl_question.number_question)
            ILIKE '%' || LOWER(p_name_text) || '%'
            OR LOWER(tbl_question.number)
            ILIKE '%' || LOWER(p_name_text) || '%'
            OR LOWER(tbl_question.code)
            ILIKE '%' || LOWER(p_name_text) || '%'
            OR EXISTS (
                SELECT
                    1
                FROM
                    jsonb_array_elements(tbl_question.subquestions) AS sq
                WHERE
                    unaccent(LOWER(sq ->> 'short_description'))
                    ILIKE '%' || LOWER(p_name_text) || '%'
                    OR LOWER(sq ->> 'number_question')
                    ILIKE '%' || LOWER(p_name_text) || '%'
                    OR LOWER(sq ->> 'number')
                    ILIKE '%' || LOWER(p_name_text) || '%'
                    OR LOWER(sq ->> 'code')
                    ILIKE '%' || LOWER(p_name_text) || '%'))
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
    created_at ASC,
    key_question ASC
LIMIT p_perpage OFFSET offset_val;
END;
$$;


ALTER FUNCTION questions.fn_unassigned_question(p_perpage integer, p_npage integer, p_employee_id integer, p_name_text character varying, p_employee_didi_id bigint, f_course_id integer, f_type character varying, f_week_id integer, f_university_id smallint, f_option_id smallint, f_modality_id smallint, f_version smallint, f_year character varying) OWNER TO postgres;

--
