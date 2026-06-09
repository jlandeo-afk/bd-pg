-- Function: questions.fn_list_digitalized_question(integer, integer, character varying, integer, integer, integer, character varying, character varying, smallint, smallint, smallint, smallint, character varying)

--

CREATE FUNCTION questions.fn_list_digitalized_question(p_perpage integer, p_npage integer, p_name_text character varying, p_employee_didi_id integer, p_teacher_id integer, p_course_id integer, p_status character varying, p_type character varying, p_university_id smallint, p_option_id smallint, p_modality_id smallint, p_version smallint, p_year character varying) RETURNS TABLE(id bigint, key_question text, type_question text, code character varying, parent_id bigint, short_description text, subquestions jsonb, course_id smallint, course character varying, status character varying, teacher_id bigint, teacher text, didi_id bigint, didi text, date_status timestamp without time zone, observation text, origin_question jsonb, type_text_template_id smallint, type_text_template_name character varying, description_text character varying, description_subquestion character varying, text_attributes character varying, subquestion_attributes character varying, priority integer, is_missing_question boolean, subtopic_id integer, total_count bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    offset_val integer;
BEGIN
    -- Calculate the offset
    offset_val := p_perpage * (p_npage - 1);
    RETURN QUERY
    -- Obtiene toda las preguntas de tipo P Y T
    WITH all_digitalized_questions AS (
        SELECT
            dq.id,
            dq.code,
            dq.status,
            dq.short_description,
            dq.parent_id,
            dq.course_id,
            c.name AS course,
            qn.question_origin,
            qn.university_id,
            qn.option_id,
            qn.modality_id,
            qn."version",
            qn."year",
            dq.priority,
            CASE WHEN mmqd.question_id IS NOT NULL THEN
                TRUE
            ELSE
                FALSE
            END AS is_missing_question
        FROM
            question dq
        LEFT JOIN v_all_question_origins qn ON qn.question_id = dq.id
        LEFT JOIN course c ON dq.course_id = c.id
        LEFT JOIN material_missing_question_detail mmqd ON mmqd.question_id = dq.id
    WHERE
        1 = 1
        AND dq.fl_status = TRUE
        AND dq.deleted_at IS NULL
        AND (p_type IS NULL
            OR p_type = 'P')
        AND (p_course_id IS NULL
            OR dq.course_id = p_course_id)
        AND (((p_status IS NULL
                    OR p_status = '')
                AND dq.status IN ('DIGI', 'OBSE'))
            OR (p_status IS NOT NULL
                AND p_status <> ''
                AND dq.status = p_status))
        AND (p_name_text IS NULL
            OR LOWER(dq.code)
            LIKE '%' || LOWER(p_name_text) || '%'
            OR unaccent(LOWER(dq.short_description))
            LIKE '%' || LOWER(p_name_text) || '%')
        AND (p_university_id IS NULL
            OR qn.university_id = p_university_id)
        AND (p_option_id IS NULL
            OR qn.option_id = p_option_id)
        AND (p_modality_id IS NULL
            OR qn.modality_id = p_modality_id)
        AND (p_version IS NULL
            OR qn."version" = p_version)
        AND (p_year IS NULL
            OR qn."year" = p_year)
),
tbl_questions AS (
    SELECT
        -- preguntas digitalizadas de tipo P
        q.id AS id,
        'p_' || q.id AS key_question,
        'P' AS type_question,
        q.code AS code,
        q.parent_id AS parent_id,
        q.short_description AS short_description,
        NULL AS subquestions,
        q.course_id,
        q.course,
        q.status AS status,
        e1.id AS teacher_id,
        CONCAT(e1.first_surname, ' ', e1.second_surname, ' ', e1.first_name) AS teacher,
        e2.id AS didi_id,
        CONCAT(e2.first_surname, ' ', e2.second_surname, ' ', e2.first_name) AS didi,
        qs.created_at AS date_status,
        qo.description AS observation,
        q.question_origin AS origin_question,
        NULL AS type_text_template_id,
        NULL AS type_text_template_name,
        NULL AS description_text,
        NULL AS description_subquestion,
        NULL AS text_attributes,
        NULL AS subquestion_attributes,
        q.priority,
        q.is_missing_question,
        qspt.subtopic_id
    FROM
        all_digitalized_questions q
        LEFT JOIN employee_question eq ON eq.question_id = q.id
        LEFT JOIN question_status qs ON q.id = qs.question_id
            AND q.status = qs.status
            AND qs.fl_active = TRUE
        LEFT JOIN employees e1 ON eq.teacher_id = e1.id
        LEFT JOIN employee_didi_question edq ON edq.question_id = q.id
            AND edq.fl_status = TRUE
        LEFT JOIN employees e2 ON edq.employee_id = e2.id
        LEFT JOIN question_observation qo ON qo.question_id = q.id
            AND qo.fl_status = TRUE
            AND qo."type" IN ('DIGI', 'OBSE')
        LEFT JOIN question_subtopic qspt ON qspt.question_id = q.id AND qspt.fl_status = TRUE
    WHERE
        1 = 1
        AND q.parent_id IS NULL
        AND eq.fl_status = TRUE
        AND (p_teacher_id IS NULL
            OR e1.id = p_teacher_id)
        AND (p_employee_didi_id IS NULL
            OR e2.id = p_employee_didi_id)
    UNION ALL
    SELECT
        -- Preguntas digitalizadas de tipo T
        pq.id AS id,
        't_' || pq.id AS key_question,
        'T' AS type_question,
        pq.code AS code,
        pq.id AS parent_id,
        pq.short_description AS short_description,
        JSONB_AGG(
            JSONB_BUILD_OBJECT(
                'id', dq.id, 
                'key_question', 's_' || dq.id, 
                'type_question', 'S', 
                'code', dq.code, 
                'subtopic_id', qs2.subtopic_id,
                'parent_id', dq.parent_id, 
                'short_description', dq.short_description, 
                'course_id', c.id, 
                'course', c.name, 
                'status', dq.status, 
                'teacher_id', es1.id, 
                'teacher', CONCAT(es1.first_surname, ' ', es1.second_surname, ' ', es1.first_name), 
                'didi_id', es2.id, 
                'didi', CONCAT(es2.first_surname, ' ', es2.second_surname, ' ', es2.first_name), 
                'date_status', qs1.created_at, 
                'observation', qo.description, 
                'origin_question', qn.question_origin
            )) AS subquestions,
        pq.course_id,
        c.name AS course,
        pq.status AS status,
        0::bigint AS teacher_id,
        '' AS teacher,
        0::bigint AS didi_id,
        '' AS didi,
        pq.created_at AS date_status,
        '' AS observation,
        opq.question_origin,
        c.type_text_template_id,
        ttt.name AS type_text_template_name,
        ttt.description_text,
        ttt.description_subquestion,
        ttt.text_attributes,
        ttt.subquestion_attributes,
        pq.priority,
        FALSE AS is_missing_question,
        NULL::integer AS subtopic_id
    FROM
        parent_question pq
        INNER JOIN question dq ON pq.status IN ('DIGI', 'OBSE')
            AND dq.parent_id = pq.id
        LEFT JOIN v_all_question_origins qn ON qn.question_id = dq.id
        LEFT JOIN odiseo.v_all_parent_origins opq ON opq.parent_id = pq.id
        INNER JOIN course c ON pq.course_id = c.id
        LEFT JOIN type_text_templates ttt ON ttt.id = c.type_text_template_id
        LEFT JOIN question_status qs1 ON dq.id = qs1.question_id
            AND dq.status = qs1.status
            AND qs1.fl_active = TRUE
        INNER JOIN question_subtopic qs2 ON dq.id = qs2.question_id
            AND qs2.fl_status = TRUE AND  qs2.fl_status = TRUE
        LEFT JOIN employee_question eoq ON eoq.question_id = dq.id
            AND eoq.fl_status = TRUE
        LEFT JOIN employees es1 ON eoq.teacher_id = es1.id
        LEFT JOIN employee_didi_question edq ON edq.question_id = dq.id
            AND edq.fl_status = TRUE
        LEFT JOIN employees es2 ON edq.employee_id = es2.id
        LEFT JOIN question_observation qo ON qo.question_id = dq.id
            AND qo.fl_status = TRUE
            AND qo."type" IN ('DIGI', 'OBSE')
    WHERE
        1 = 1
        AND (p_status IS NULL
            OR p_status = ''
            OR pq.status = p_status)
        AND (p_course_id IS NULL
            OR pq.course_id = p_course_id)
        AND (p_teacher_id IS NULL
            OR es1.id = p_teacher_id)
        AND (p_employee_didi_id IS NULL
            OR es2.id = p_employee_didi_id)
        AND (p_university_id IS NULL
            OR opq.university_id = p_university_id
            OR qn.university_id = p_university_id)
        AND (p_option_id IS NULL
            OR opq.option_id = p_option_id
            OR qn.option_id = p_option_id)
        AND (p_modality_id IS NULL
            OR opq.modality_id = p_modality_id
            OR qn.modality_id = p_modality_id)
        AND (p_version IS NULL
            OR opq."version" = p_version
            OR qn."version" = p_version)
        AND (p_year IS NULL
            OR opq."year" = p_year
            OR qn."year" = p_year)
    GROUP BY
        pq.id,
        c.id,
        opq.question_origin,
        ttt.id
    HAVING
        1 = 1
        AND (p_name_text IS NULL
            OR p_name_text = ''
            OR LOWER(pq.number_question)
            ILIKE '%' || LOWER(p_name_text) || '%'
            OR LOWER(pq.code)
            ILIKE '%' || LOWER(p_name_text) || '%'
            OR BOOL_OR(LOWER(dq.number_question)
                ILIKE '%' || LOWER(p_name_text) || '%')
            OR BOOL_OR(LOWER(dq.code)
                ILIKE '%' || LOWER(p_name_text) || '%'))
),
counted_questions AS (
    SELECT
        *,
        COUNT(*) OVER () AS total_count
    FROM
        tbl_questions fq
)
SELECT
    *
FROM
    counted_questions AS cq
ORDER BY
    cq.priority DESC NULLS LAST,
    CASE
        WHEN cq.status = 'OBSE' THEN 0
        ELSE 1
    END,
    cq.date_status ASC
LIMIT p_perpage OFFSET offset_val;
END;
$$;


ALTER FUNCTION questions.fn_list_digitalized_question(p_perpage integer, p_npage integer, p_name_text character varying, p_employee_didi_id integer, p_teacher_id integer, p_course_id integer, p_status character varying, p_type character varying, p_university_id smallint, p_option_id smallint, p_modality_id smallint, p_version smallint, p_year character varying) OWNER TO postgres;

--
