-- Function: questions.fn_list_index_question(integer, integer, character varying, integer, integer, integer, boolean, character varying, character varying, smallint, smallint, smallint, smallint, character varying, boolean)

--

CREATE FUNCTION questions.fn_list_index_question(p_perpage integer, p_npage integer, p_name_text character varying, p_teacher_id integer, p_course_id integer, p_didi_id integer, p_fl_diagrammed boolean, p_type character varying, p_status character varying, p_university_id smallint, p_option_id smallint, p_modality_id smallint, p_version smallint, p_year character varying, p_is_secondary boolean) RETURNS TABLE(id bigint, key_question text, type_question text, code character varying, parent_id bigint, short_description text, subquestions jsonb, course_id smallint, course character varying, status character varying, teacher_id bigint, teacher text, didi_id bigint, didi text, type_text_id bigint, date_status timestamp without time zone, origin_question jsonb, is_secondary boolean, priority integer, is_missing_question boolean, total_count bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    offset_val integer;
BEGIN
    offset_val := p_perpage * (p_npage - 1);
    RETURN QUERY
    -- Obtiene toda las preguntas de tipo P Y T
    WITH all_index_questions AS (
        SELECT
            vq.id,
            vq.code,
            vq.status,
            vq.short_description,
            vq.parent_id,
            vq.course_id,
            c.name AS course,
            qn.question_origin,
            qn.university_id,
            qn.option_id,
            qn.modality_id,
            qn."version",
            qn."year",
            vq.priority,
            CASE WHEN mmqd.question_id IS NOT NULL THEN
                TRUE
            ELSE
                FALSE
            END AS is_missing_question
        FROM
            question vq
        LEFT JOIN course c ON vq.course_id = c.id
        LEFT JOIN v_all_question_origins qn ON qn.question_id = vq.id
        LEFT JOIN material_missing_question_detail mmqd ON mmqd.question_id = vq.id
    WHERE
        1 = 1
        AND vq.fl_status = TRUE
        AND vq.parent_id IS NULL
        AND vq.deleted_at IS NULL
        AND CASE WHEN p_status IS NULL THEN
            vq.status IN ('RECH', 'DASI')
        ELSE
            vq.status = p_status
        END
        AND ((p_type IS NULL)
            OR (p_type = 'T'
                AND vq.parent_id IS NOT NULL)
            OR (p_type = 'P'
                AND vq.parent_id IS NULL))
        AND (p_course_id IS NULL
            OR vq.course_id = p_course_id)
        AND (p_fl_diagrammed IS NULL
            OR vq.fl_diagrammed = p_fl_diagrammed)
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
tbl_primary AS (
    SELECT
        -- index P questions
        q.id AS id,
        'p_' || q.id AS key_question,
        'P' type_question,
        q.code AS code,
        q.parent_id AS parent_id,
        q.short_description short_description,
        '[]'::jsonb AS subquestions,
        q.course_id,
        q.course,
        q.status AS status,
        e1.id AS teacher_id,
        CONCAT(e1.first_surname, ' ', e1.second_surname, ' ', e1.first_name) AS teacher,
        e2.id AS didi_id,
        CONCAT(e2.first_surname, ' ', e2.second_surname, ' ', e2.first_name) AS didi,
        NULL::bigint AS type_text_id,
        qs.created_at AS date_status,
        q.question_origin,
        FALSE AS is_secondary,
        q.priority,
        q.is_missing_question
    FROM
        all_index_questions q
        LEFT JOIN employee_question eq ON eq.question_id = q.id
        LEFT JOIN question_status qs ON q.id = qs.question_id
            AND q.status = qs.status
            AND qs.fl_active = TRUE
        LEFT JOIN employees e1 ON eq.teacher_id = e1.id
        LEFT JOIN employee_didi_question edq ON edq.question_id = q.id
            AND edq.fl_status = TRUE
        LEFT JOIN employees e2 ON edq.employee_id = e2.id
    WHERE
        1 = 1
        AND (p_is_secondary IS NULL
            OR p_is_secondary IS FALSE)
        AND (p_type IS NULL
            OR p_type = 'P')
        AND q.parent_id IS NULL
        AND eq.fl_status = TRUE
        AND (p_teacher_id IS NULL
            OR e1.id = p_teacher_id)
        AND (p_didi_id IS NULL
            OR e2.id = p_didi_id)
        AND (p_name_text IS NULL
            OR LOWER(q.code)
            LIKE '%' || LOWER(p_name_text) || '%'
            OR unaccent(LOWER(q.short_description))
            LIKE '%' || LOWER(p_name_text) || '%')
    UNION ALL
    SELECT
        -- Index T questions
        pq.id AS id,
        't_' || pq.id AS key_question,
        'T' type_question,
        pq.code AS code,
        pq.id AS parent_id,
        pq.short_description short_description,
        JSONB_AGG(JSONB_BUILD_OBJECT('id', oq.id, 'key_question', 's_' || oq.id, 'type_question', 'S', 'code', oq.code, 'parent_id', oq.parent_id, 'short_description', oq.short_description, 'course_id', c.id, 'course', c.name, 'status', oq.status, 'teacher_id', es1.id, 'teacher', CONCAT(es1.first_surname, ' ', es1.second_surname, ' ', es1.first_name), 'didi_id', es2.id, 'didi', CONCAT(es2.first_surname, ' ', es2.second_surname, ' ', es2.first_name), 'date_status', qs1.created_at, 'origin_question', qn.question_origin)) AS subquestions,
        pq.course_id,
        c.name AS course,
        pq.status AS status,
        0::bigint AS teacher_id,
        '' AS teacher,
        0::bigint AS didi_id,
        '' AS didi,
        pq.type_text_id,
        pq.created_at AS date_status,
        opq.question_origin,
        FALSE AS is_secondary,
        pq.priority,
        FALSE AS is_missing_question
    FROM
        parent_question pq
        INNER JOIN question oq ON pq.status IN ('RECH', 'DASI')
            AND oq.parent_id = pq.id
        LEFT JOIN v_all_question_origins qn ON qn.question_id = oq.id
        LEFT JOIN v_all_parent_origins opq ON opq.parent_id = pq.id
        LEFT JOIN question_status qs1 ON oq.id = qs1.question_id
            AND oq.status = qs1.status
            AND qs1.fl_active IS TRUE
        LEFT JOIN employee_question eoq ON eoq.question_id = oq.id
            AND eoq.fl_status IS TRUE
        LEFT JOIN employees es1 ON eoq.teacher_id = es1.id
        LEFT JOIN employee_didi_question edq ON edq.question_id = oq.id
            AND edq.fl_status = TRUE
        LEFT JOIN employees es2 ON edq.employee_id = es2.id
        INNER JOIN course c ON pq.course_id = c.id
    WHERE
        1 = 1
        AND (p_is_secondary IS NULL
            OR p_is_secondary IS FALSE)
        AND (p_teacher_id IS NULL
            OR es1.id = p_teacher_id)
        AND (p_didi_id IS NULL
            OR edq.employee_id = p_didi_id)
        AND (p_type IS NULL
            OR p_type = 'T')
        AND oq.fl_status IS TRUE
        AND (p_course_id IS NULL
            OR c.id = p_course_id)
        AND (p_fl_diagrammed IS NULL
            OR oq.fl_diagrammed = p_fl_diagrammed)
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
    GROUP BY
        pq.id,
        c.id,
        opq.question_origin
    HAVING
        COUNT(oq.*) > 0
        AND (p_name_text IS NULL
            OR LOWER(pq.code)
            LIKE '%' || LOWER(p_name_text) || '%'
            OR unaccent(LOWER(pq.short_description))
            LIKE '%' || LOWER(p_name_text) || '%'
            OR BOOL_OR(LOWER(oq.code)
                LIKE '%' || LOWER(p_name_text) || '%'
                OR LOWER(oq.code)
                LIKE '%' || LOWER(p_name_text) || '%'
                OR unaccent(LOWER(oq.short_description))
                LIKE '%' || LOWER(p_name_text) || '%'))
),
tbl_secondary AS (
    SELECT
        q.id AS id,
        'sec_' || sec.id AS key_question,
        'P' type_question,
        sec.code AS code,
        q.parent_id AS parent_id,
        q.short_description short_description,
        '[]'::jsonb AS subquestions,
        sec.course_id::smallint,
        c.name AS course,
        q.status AS status,
        e1.id AS teacher_id,
        CONCAT(e1.first_surname, ' ', e1.second_surname, ' ', e1.first_name) AS teacher,
        e2.id AS didi_id,
        CONCAT(e2.first_surname, ' ', e2.second_surname, ' ', e2.first_name) AS didi,
        NULL::bigint AS type_text_id,
        qs.created_at AS date_status,
        qn.question_origin,
        TRUE AS is_secondary,
        q.priority,
        FALSE AS is_missing_question
    FROM
        question_secondary sec
        JOIN question q ON sec.question_id = q.id
        LEFT JOIN course c ON sec.course_id = c.id
        LEFT JOIN v_all_question_origins qn ON qn.question_id = q.id
        LEFT JOIN employee_question eq ON eq.question_id = q.id
        LEFT JOIN employees e1 ON eq.teacher_id = e1.id
        LEFT JOIN employee_didi_question edq ON edq.question_id = q.id
            AND edq.fl_status = TRUE
        LEFT JOIN employees e2 ON edq.employee_id = e2.id
        LEFT JOIN question_status qs ON q.id = qs.question_id
            AND q.status = qs.status
            AND qs.fl_active = TRUE
    WHERE
        1 = 1
        AND (p_is_secondary IS NULL
            OR p_is_secondary IS TRUE)
        AND q.fl_status = TRUE
        AND q.parent_id IS NULL
        AND q.deleted_at IS NULL
        AND CASE WHEN p_status IS NULL THEN
            q.status IN ('RECH', 'DASI')
        ELSE
            q.status = p_status
        END
        AND (p_type IS NULL
            OR p_type = 'P')
        AND (p_course_id IS NULL
            OR sec.course_id = p_course_id)
        AND (p_fl_diagrammed IS NULL
            OR q.fl_diagrammed = p_fl_diagrammed)
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
        AND eq.fl_status = TRUE
        AND (p_teacher_id IS NULL
            OR e1.id = p_teacher_id)
        AND (p_didi_id IS NULL
            OR e2.id = p_didi_id)
        AND (p_name_text IS NULL
            OR LOWER(sec.code)
            LIKE '%' || LOWER(p_name_text) || '%'
            OR unaccent(LOWER(q.short_description))
            LIKE '%' || LOWER(p_name_text) || '%')
),
combined_questions AS (
    SELECT
        *
    FROM
        tbl_primary
    UNION ALL
    SELECT
        *
    FROM
        tbl_secondary
),
counted_questions AS (
    SELECT
        fq.*,
        count(*) OVER () AS total_count
FROM
    combined_questions fq
)
SELECT DISTINCT
    cq.*
FROM
    counted_questions cq
ORDER BY
    cq.priority DESC,
    cq.date_status ASC,
    cq.id ASC
LIMIT p_perpage OFFSET offset_val;
END;
$$;


ALTER FUNCTION questions.fn_list_index_question(p_perpage integer, p_npage integer, p_name_text character varying, p_teacher_id integer, p_course_id integer, p_didi_id integer, p_fl_diagrammed boolean, p_type character varying, p_status character varying, p_university_id smallint, p_option_id smallint, p_modality_id smallint, p_version smallint, p_year character varying, p_is_secondary boolean) OWNER TO postgres;

--
