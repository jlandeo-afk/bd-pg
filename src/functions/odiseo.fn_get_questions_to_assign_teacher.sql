-- Function: odiseo.fn_get_questions_to_assign_teacher()

--

CREATE FUNCTION odiseo.fn_get_questions_to_assign_teacher() RETURNS TABLE(type_question text, id bigint, course_id bigint, questions json, priority integer, created_at timestamp without time zone)
    LANGUAGE sql
    AS $$
        WITH question_sasi_p AS (
            SELECT q.id, q.course_id, q.priority, q.created_at 
            FROM question AS q
            WHERE q.status = 'SASI'
            AND q.parent_id IS NULL
            AND (q.number_question IS NULL OR q.number_question NOT ILIKE 'D%')
        ),
        parent_question_sasi_t AS (
            SELECT
                pq.id,
                pq.course_id,
                CASE
                    WHEN count(q.id) > 0 THEN json_agg(q.* ORDER BY
                        CASE
                            WHEN q.type_material_id = 3 THEN 1
                            WHEN q.type_material_id = 2 THEN 2
                            WHEN q.type_material_id = 1 THEN 3
                            WHEN q.type_material_id IS NOT NULL THEN 4
                            ELSE 5
                        END ASC, q.type_material_id ASC, q.id ASC)
                    ELSE '[]'::json
                END AS questions,
                pq.priority,
                pq.created_at
            FROM parent_question pq
            LEFT JOIN (
                SELECT q_inner.id, q_inner.code, q_inner.course_id, q_inner.status, q_inner.parent_id, q_inner.fl_status, qt.type_material_id, t.description
                FROM question q_inner
                LEFT JOIN question_temporary qt ON qt.question_id = q_inner.id
                LEFT JOIN type_material t ON qt.type_material_id = t.id
                WHERE q_inner.status IN ('SASI', 'DUPL')
                AND q_inner.fl_status IS TRUE
                AND (q_inner.number_question IS NULL OR q_inner.number_question NOT ILIKE 'D%')
            ) q ON pq.id = q.parent_id
            WHERE pq.fl_status IS TRUE
            AND pq.status IN ('SASI', 'ASIG')
            AND (pq.number_question IS NULL OR pq.number_question NOT ILIKE 'D%')
            GROUP BY pq.id, pq.course_id, pq.priority, pq.created_at
            HAVING count(q.id) > 0
        ), result as (
            SELECT
                'P'::text AS type_question,
                p.id,
                p.course_id,
                NULL::json AS questions,
                p.priority,
                p.created_at
            FROM question_sasi_p p
            
            UNION ALL
            
            SELECT
                'T'::text AS type_question,
                t.id,
                t.course_id,
                t.questions,
                t.priority,
                t.created_at
            FROM parent_question_sasi_t t

        )
        SELECT * FROM result
        ORDER BY priority DESC, created_at ASC, id ASC;
    $$;


ALTER FUNCTION odiseo.fn_get_questions_to_assign_teacher() OWNER TO postgres;

--
