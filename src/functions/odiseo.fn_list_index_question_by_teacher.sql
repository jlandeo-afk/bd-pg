-- Function: odiseo.fn_list_index_question_by_teacher(integer, integer, character varying, integer[], integer, boolean, character varying, character varying)

--

CREATE FUNCTION odiseo.fn_list_index_question_by_teacher(p_perpage integer, p_npage integer, p_name_text character varying, f_course_ids integer[], f_teacher_id integer, f_fl_diagrammed boolean, f_type character varying, f_status character varying) RETURNS TABLE(id bigint, key_question text, parent_id bigint, subquestions jsonb, type_question text, code character varying, short_description text, course_id smallint, course character varying, teacher_id bigint, teacher text, status character varying, date_status timestamp without time zone, observation text, total_refuzed bigint, pdf_status text, priority integer, is_missing_question boolean, total_count bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    offset_val integer;
BEGIN
    -- Calculate the offset
    offset_val := p_perpage * (p_npage - 1);
    RETURN QUERY WITH all_indexed_questions AS (
        SELECT
            iq.id,
            iq.code,
            iq.short_description,
            iq.parent_id,
            iq.course_id,
            iq.status,
            c.name AS course,
            iq.priority,
            CASE WHEN mmqd.question_id IS NOT NULL THEN
                TRUE
            ELSE
                FALSE
            END AS is_missing_question
        FROM
            question iq
        LEFT JOIN course c ON iq.course_id = c.id
        LEFT JOIN material_missing_question_detail mmqd ON mmqd.question_id = iq.id
    WHERE
        1 = 1
        AND iq.fl_status IS TRUE
        AND iq.deleted_at IS NULL
        AND ((f_status IS NULL
                AND iq.status IN ('DASI', 'INDE'))
            OR (iq.status = f_status))
        AND (f_fl_diagrammed IS NULL
            OR iq.fl_diagrammed = f_fl_diagrammed)
        AND (f_type IS NULL
            OR (f_type = 'T'
                AND iq.parent_id IS NOT NULL)
            OR (f_type = 'P'
                AND iq.parent_id IS NULL))
        AND (f_course_ids IS NULL
            OR iq.course_id = ANY (f_course_ids)) -- Cambio: Filtrado por array de course_ids
),
tbl_question AS (
    SELECT
        -- Indexed P questions
        q.id AS id,
        'p_' || q.id AS key_question,
        q.parent_id AS parent_id,
        NULL AS subquestions,
        'P' AS type_question,
        q.code AS code,
        q.short_description AS short_description,
        q.course_id,
        q.course,
        eq.teacher_id,
        CONCAT(e.first_surname, ' ', e.second_surname, ' ', e.first_name) AS teacher,
        q.status AS status,
        qs.created_at AS date_status,
        '' AS observation,
        (
            SELECT
                COUNT(*)
            FROM
                question_refuzed qr2
            WHERE
                qr2.question_id = q.id) AS total_refuzed,
        CASE WHEN eq.url_pdf_question_solution IS NULL THEN
            'pending'
        ELSE
            'completed'
        END AS pdf_status,
        q.priority,
        q.is_missing_question
    FROM
        all_indexed_questions q
        LEFT JOIN employee_question eq ON eq.question_id = q.id
        LEFT JOIN question_status qs ON q.id = qs.question_id
            AND q.status = qs.status
            AND qs.fl_active = TRUE
        LEFT JOIN employees e ON eq.teacher_id = e.id
    WHERE
        1 = 1
        AND (f_type IS NULL
            OR f_type = 'P')
        AND q.parent_id IS NULL
        AND eq.fl_status = TRUE
        AND (f_teacher_id IS NULL
            OR eq.teacher_id = f_teacher_id)
        AND (p_name_text IS NULL
            OR LOWER(q.code)
            LIKE '%' || LOWER(p_name_text) || '%'
            OR unaccent(LOWER(q.short_description))
            LIKE '%' || LOWER(p_name_text) || '%')
    UNION ALL
    SELECT
        -- Indexed T questions
        pq.id AS id,
        't_' || pq.id AS key_question,
        pq.id AS parent_id,
        JSONB_AGG(JSONB_BUILD_OBJECT('id', q.id, 'key_question', 's_' || q.id, 'code', q.code, 'course', c.name, 'status', q.status, 'teacher_id', es.id, 'teacher', CONCAT(initcap(split_part(es.first_name, ' ', 1)), ' ', upper(
                    LEFT (es.first_surname, 1)), '.', ' ', initcap(es.second_surname)), 'date_status', qs1.created_at, 'type_question', 'S', 'parent_id', q.parent_id, 'short_description', q.short_description, 'total_refuzed', (
                SELECT
                    COUNT(*)
                FROM question_refuzed qr
                WHERE
                    qr.question_id = q.id))) AS subquestions,
        'T' AS type_question,
        pq.code AS code,
        pq.short_description AS short_description,
        pq.course_id,
        c.name AS course,
        - 1::bigint AS teacher_id,
        '' AS teacher,
        pq.status AS status,
        pq.created_at AS date_status,
        '' AS observation,
        0::bigint AS total_refuzed,
        NULL AS pdf_status,
        pq.priority,
        FALSE AS is_missing_question
    FROM
        parent_question pq
        JOIN question q ON pq.status IN ('DASI', 'INDE')
            AND pq.id = q.parent_id
        INNER JOIN course c ON pq.course_id = c.id
        LEFT JOIN question_status qs1 ON q.id = qs1.question_id
            AND q.status = qs1.status
            AND qs1.fl_active IS TRUE
        LEFT JOIN employee_question eoq ON eoq.question_id = q.id
            AND eoq.fl_status IS TRUE
        LEFT JOIN employees es ON eoq.teacher_id = es.id
    WHERE
        1 = 1
        AND (f_type IS NULL
            OR f_type = 'T')
        AND (f_teacher_id IS NULL
            OR eoq.teacher_id = f_teacher_id)
        AND (f_course_ids IS NULL
            OR pq.course_id = ANY (f_course_ids))
        AND ((f_status IS NULL
                AND pq.status IN ('DASI', 'INDE'))
            OR (pq.status = f_status))
    GROUP BY
        pq.id,
        c.id
    HAVING
        p_name_text IS NULL
        OR LOWER(pq.code)
        LIKE '%' || LOWER(p_name_text) || '%'
        OR unaccent(LOWER(pq.short_description))
        LIKE '%' || LOWER(p_name_text) || '%'
        OR BOOL_OR(LOWER(q.code)
            LIKE '%' || LOWER(p_name_text) || '%'
            OR LOWER(q.code)
            LIKE '%' || LOWER(p_name_text) || '%'
            OR LOWER(q.short_description)
            LIKE '%' || LOWER(p_name_text) || '%')
),
counted_questions AS (
    SELECT
        *,
        count(*) OVER () AS total_count
    FROM
        tbl_question fq
    WHERE (f_type IS NULL
        OR fq.type_question = f_type))
SELECT
    *
FROM
    counted_questions AS cq
ORDER BY
    cq.priority DESC,
    CASE WHEN cq.status = 'DASI' THEN
        1
    WHEN cq.status = 'INDE' THEN
        2
    ELSE
        3
    END ASC,
    CASE WHEN cq.status = 'DASI' THEN
        cq.date_status
    ELSE
        NULL
    END ASC,
    CASE WHEN cq.status = 'INDE' THEN
        cq.date_status
    ELSE
        NULL
    END ASC,
    cq.date_status ASC,
    cq.id ASC
LIMIT p_perpage OFFSET offset_val;
END;
$$;


ALTER FUNCTION odiseo.fn_list_index_question_by_teacher(p_perpage integer, p_npage integer, p_name_text character varying, f_course_ids integer[], f_teacher_id integer, f_fl_diagrammed boolean, f_type character varying, f_status character varying) OWNER TO postgres;

--
