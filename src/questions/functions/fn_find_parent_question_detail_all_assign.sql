-- Function: questions.fn_find_parent_question_detail_all_assign(bigint)

--

CREATE FUNCTION questions.fn_find_parent_question_detail_all_assign(p_parent_id bigint) RETURNS TABLE(id bigint, code character varying, course_id smallint, status character varying, fl_status boolean, questions json)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    pq.id,
                    pq.code,
					pq.course_id,
                    pq.status,
                    pq.fl_status,
                    CASE
                        WHEN count(q.id) > 0 THEN json_agg(q.*)
                        ELSE '[]'::json
                    END AS questions
                FROM questions.parent_question pq
                LEFT JOIN (
                    SELECT q.id, q.code, q.course_id, q.status, q.parent_id, q.fl_status
                    FROM questions.question q
                    WHERE q.fl_status IS TRUE
                ) q ON pq.id = q.parent_id
                WHERE pq.fl_status IS TRUE
                AND pq.id = p_parent_id
                GROUP BY
                    pq.id,
                    pq.code,
                    pq.status,
                    pq.fl_status
                ORDER BY pq.id ASC;
            END;
            $$;


ALTER FUNCTION questions.fn_find_parent_question_detail_all_assign(p_parent_id bigint) OWNER TO postgres;

--
