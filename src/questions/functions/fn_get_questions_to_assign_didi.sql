-- Function: questions.fn_get_questions_to_assign_didi()

--

CREATE FUNCTION questions.fn_get_questions_to_assign_didi() RETURNS TABLE(type_question text, id bigint, course_id bigint, code text, status text, employee_id bigint, questions json, priority integer, created_at timestamp without time zone)
    LANGUAGE sql
    AS $$
                WITH question_p AS (
                    SELECT
                        q.id,
                        q.course_id,
                        q.code,
                        q.priority,
                        qs.created_at
                    FROM question q
                    JOIN question_status qs ON q.id = qs.question_id
                        AND qs.status = q.status
                        AND qs.fl_active = true
                    WHERE q.status = 'INDE'
                    AND q.fl_status IS TRUE
                    AND q.parent_id IS NULL
                    ORDER BY qs.created_at ASC
                ),
                question_t AS (
                    SELECT
                        pq.id,
                        pq.code,
                        pq.course_id,
                        pq.status,
                        pq.fl_status,
                        e.id AS employee_id,
                        json_agg(q.*) AS questions,
                        pq.priority,
                        pq.created_at,
	                    MAX(q.created_at) AS last_question_created_at
                    FROM parent_question pq
                    JOIN (
                        SELECT q.id, q.code, q.course_id, q.status, q.parent_id, q.fl_status, qs.created_at
                        FROM question q
                        JOIN question_status qs ON q.id = qs.question_id
                            AND qs.status = q.status
                            AND qs.fl_active = true
                        WHERE q.status = 'INDE' AND q.fl_status IS TRUE
                    ) q ON pq.id = q.parent_id
                    LEFT JOIN users u ON u.id = pq.created_by
                    LEFT JOIN employees e ON e.user_id = u.id
                    WHERE pq.fl_status IS TRUE
                    AND pq.status IN ('INDE')
                    AND NOT EXISTS (
                        SELECT 1
                        FROM question q2
                        WHERE q2.parent_id = pq.id
                        AND q2.status != 'INDE'
                        AND q2.fl_status IS TRUE
                    )
                    GROUP BY
                        pq.id,
                        pq.code,
                        pq.course_id,
                        u.id,
                        e.id,
                        pq.status,
                        pq.fl_status
                    HAVING count(q.id) > 0
	                ORDER BY last_question_created_at ASC
                ),
                resultado_union AS (
                    SELECT
                        'P'::text AS type_question,
                        id,
                        course_id,
                        code,
                        'INDE'::text AS status,
                        NULL::bigint AS employee_id,
                        NULL::json AS questions,
                        priority,
                        created_at
                    FROM question_p

                    UNION ALL

                    SELECT
                        'T'::text AS type_question,
                        id,
                        course_id,
                        code,
                        status,
                        employee_id,
                        questions,
                        priority,
                        created_at
                    FROM question_t
                )

                SELECT * FROM resultado_union ORDER BY priority DESC, created_at ASC, id ASC;
            $$;


ALTER FUNCTION questions.fn_get_questions_to_assign_didi() OWNER TO postgres;

--
