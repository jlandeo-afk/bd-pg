-- Function: odiseo.fn_digitalized_teacher_question(integer, integer, character varying, integer, integer, integer[], character varying, character varying)

--

CREATE FUNCTION odiseo.fn_digitalized_teacher_question(p_perpage integer, p_npage integer, p_name_text character varying, p_teacher_id integer, f_employee_didi_id integer, f_course_id integer[], f_status character varying, f_type character varying) RETURNS TABLE(id bigint, key_question text, type_question text, code character varying, parent_id bigint, short_description text, subquestions jsonb, course_id smallint, course character varying, status character varying, teacher_id bigint, teacher text, url_pdf_index character varying, didi_id bigint, didi text, url_pdf_digitalized character varying, date_status timestamp without time zone, observation text, priority integer, is_missing_question boolean, total_count bigint)
    LANGUAGE plpgsql
    AS $$
            DECLARE
                offset_val INTEGER;
            BEGIN
                -- Calcular el offset
                offset_val := p_perpage * (p_npage - 1);

                RETURN QUERY
                -- Obtiene todas las preguntas de tipo P Y T
                WITH all_digitalized_questions AS (
                    SELECT
                        dq.id,
                        dq.code,
                        dq.status,
                        dq.short_description,
                        dq.parent_id,
                        dq.course_id,
                        c.name as course,
                        dq.priority
                    FROM question dq
                    LEFT JOIN course c ON dq.course_id = c.id
                    WHERE 1 = 1
                    AND dq.fl_status = TRUE
                    AND dq.deleted_at IS NULL
                    AND (
                        f_type IS NULL OR
                        (f_type = 'T' AND dq.parent_id IS NOT NULL) OR
                        (f_type = 'P' AND dq.parent_id IS NULL)
                    )
                    AND (f_course_id IS NULL OR dq.course_id = ANY(f_course_id)) -- Modificado para manejar una lista de IDs
                    AND (
                        (f_status IS NULL OR f_status = '') AND dq.status IN ('DIGI', 'OBSE')
                        OR (f_status IS NOT NULL AND f_status <> '' AND dq.status = f_status)
                    )
                    AND (
                        p_name_text IS NULL
                        OR LOWER(dq.code) LIKE '%' || LOWER(p_name_text) || '%'
                        OR unaccent(LOWER(dq.short_description)) LIKE '%' || LOWER(p_name_text) || '%'
                    )
                ),
                -- Creando una tabla con los registros de preguntas de tipo S
                digitalzied_s_subquestions AS (
                    SELECT
                        oq.parent_id AS parent_id,
                        JSONB_AGG(
                            JSONB_BUILD_OBJECT(
                                'id', oq.id,
                                'key_question', 's_' || oq.id,
                                'type_question', 'S',
                                'code', oq.code,
                                'parent_id', oq.parent_id,
                                'short_description', oq.short_description,
                                'course_id', oq.course_id,
                                'course', oq.course,
                                'status', oq.status,
                                'teacher_id', es1.id,
                                'teacher', CONCAT(es1.first_surname, ' ', es1.second_surname, ' ', es1.first_name),
                                'url_pdf_index', eoq.url_pdf_question_solution,
                                'didi_id', es2.id,
                                'didi', CONCAT(es2.first_surname, ' ', es2.second_surname, ' ', es2.first_name),
                                'url_pdf_digitalized', edq.url_file_digitalized_solution,
                                'date_status', qs1.created_at,
                                'observation', qo.description
                            )
                        ) AS subquestions
                    FROM all_digitalized_questions oq
                    LEFT JOIN question_status qs1 ON oq.id = qs1.question_id
                        AND oq.status = qs1.status AND qs1.fl_active = TRUE
                    LEFT JOIN employee_question eoq ON eoq.question_id = oq.id AND eoq.fl_status = true
                    LEFT JOIN employees es1 ON eoq.teacher_id = es1.id
                    LEFT JOIN employee_didi_question edq ON edq.question_id = oq.id AND edq.fl_status = true
                    LEFT JOIN employees es2 ON edq.employee_id = es2.id
                    LEFT JOIN question_observation qo ON qo.question_id = oq.id
                        AND qo.fl_status = true AND qo.type IN ('DIGI', 'OBSE')
                    WHERE 1 = 1
                    AND oq.parent_id IS NOT NULL
                    AND (p_teacher_id IS NULL OR es1.id = p_teacher_id)
                    AND (f_employee_didi_id IS NULL OR es2.id = f_employee_didi_id)
                    GROUP BY oq.parent_id
                ),
                tbl_questions AS (
                    SELECT -- preguntas digitalizadas de tipo P
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
                        eq.url_pdf_question_solution AS url_pdf_index,
                        e2.id AS didi_id,
                        CONCAT(e2.first_surname, ' ', e2.second_surname, ' ', e2.first_name) AS didi,
                        edq.url_file_digitalized_solution AS url_pdf_digitalized,
                        qs.created_at AS date_status,
                        qo.description AS observation,
                        q.priority,
                        CASE WHEN mmqd.id IS NOT NULL THEN true ELSE false END AS is_missing_question
                    FROM all_digitalized_questions q
                    LEFT JOIN employee_question eq ON eq.question_id = q.id
                    LEFT JOIN question_status qs ON q.id = qs.question_id
                        AND q.status = qs.status AND qs.fl_active = true
                    LEFT JOIN employees e1 ON eq.teacher_id = e1.id
                    LEFT JOIN employee_didi_question edq ON edq.question_id = q.id AND edq.fl_status = true
                    LEFT JOIN employees e2 ON edq.employee_id = e2.id
                    LEFT JOIN question_observation qo ON qo.question_id = q.id
                        AND qo.fl_status = true AND qo.type IN ('DIGI', 'OBSE')
                    LEFT JOIN material_missing_question_detail mmqd ON mmqd.question_id = q.id
                    WHERE 1 = 1
                    AND q.parent_id IS NULL
                    AND eq.fl_status = true
                    AND (p_teacher_id IS NULL OR e1.id = p_teacher_id)
                    AND (f_employee_didi_id IS NULL OR e2.id = f_employee_didi_id)
                    UNION ALL
                    SELECT -- Preguntas digitalizadas de tipo T
                        pq.id AS id,
                        't_' || pq.id AS key_question,
                        'T' AS type_question,
                        pq.code AS code,
                        pq.id AS parent_id,
                        pq.short_description AS short_description,
                        COALESCE(dq.subquestions, '[]'::jsonb) AS subquestions,
                        pq.course_id,
                        c.name AS course,
                        pq.status AS status,
                        0::BIGINT AS teacher_id,
                        '' AS teacher,
                        '' AS url_pdf_index,
                        0::BIGINT AS didi_id,
                        '' AS didi,
                        '' AS url_pdf_digitalized,
                        pq.created_at AS date_status,
                        '' AS observation,
                        pq.priority,
                        false AS is_missing_question
                    FROM parent_question pq
                    INNER JOIN digitalzied_s_subquestions dq ON dq.parent_id = pq.id
                    INNER JOIN course c ON pq.course_id = c.id
                ),
                counted_questions AS (
                    SELECT *, count(*) OVER () AS total_count
                    FROM tbl_questions fq
                )
                SELECT *
                FROM counted_questions AS cq
                ORDER BY 
                cq.priority DESC NULLS LAST,
                cq.date_status ASC,
                CASE
                    WHEN cq.status = 'OBSE' THEN 1
                    WHEN cq.status = 'DIGI' THEN 2
                    ELSE 3
                END,
                CASE
                    WHEN cq.status = 'OBSE' THEN cq.date_status
                    ELSE NULL
                END ASC,
                CASE
                    WHEN cq.status = 'DIGI' THEN cq.date_status
                    ELSE NULL
                END ASC,
                cq.id ASC
                LIMIT p_perpage
                OFFSET offset_val;
            END;
            $$;


ALTER FUNCTION odiseo.fn_digitalized_teacher_question(p_perpage integer, p_npage integer, p_name_text character varying, p_teacher_id integer, f_employee_didi_id integer, f_course_id integer[], f_status character varying, f_type character varying) OWNER TO postgres;

--
