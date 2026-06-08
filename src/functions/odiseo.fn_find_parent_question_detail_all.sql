-- Function: odiseo.fn_find_parent_question_detail_all(bigint)

--

CREATE FUNCTION odiseo.fn_find_parent_question_detail_all(p_parent_id bigint) RETURNS TABLE(id bigint, code character varying, course_id smallint, status character varying, fl_status boolean, questions json)
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
                FROM odiseo.parent_question pq
                LEFT JOIN (
                    SELECT q.id, q.code, q.course_id, q.status, q.parent_id, q.fl_status
                    FROM odiseo.question q
                    WHERE q.fl_status IS TRUE
                ) q ON pq.id = q.parent_id
                WHERE pq.fl_status IS TRUE
                AND pq.status IN ('SASI', 'DUPL', 'ASIG')
                AND pq.id = p_parent_id
                GROUP BY
                    pq.id,
                    pq.code,
                    pq.status,
                    pq.fl_status
                ORDER BY pq.id ASC;
            END;
            $$;


ALTER FUNCTION odiseo.fn_find_parent_question_detail_all(p_parent_id bigint) OWNER TO postgres;

--
