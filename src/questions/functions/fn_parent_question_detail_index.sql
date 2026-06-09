-- Function: questions.fn_parent_question_detail_index()

--

CREATE FUNCTION questions.fn_parent_question_detail_index() RETURNS TABLE(id bigint, code character varying, course_id smallint, status character varying, fl_status boolean, employee_id bigint, questions json)
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
            e.id as employee_id,
            json_agg(q.*) AS questions
        FROM parent_question pq
        JOIN (
            SELECT q.id, q.code, q.course_id, q.status, q.parent_id, q.fl_status
            FROM question q
            WHERE q.status = 'INDE' AND q.fl_status IS TRUE
        ) q ON pq.id = q.parent_id
        JOIN users u
            ON u.id = pq.created_by 
        JOIN employees e
            ON e.user_id  = u.id
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
            u.id ,
            e.id,
            pq.status,
            pq.fl_status
        HAVING jsonb_array_length(json_agg(q.*)::jsonb) > 0
        ORDER BY pq.id ASC;
    END;
    $$;


ALTER FUNCTION questions.fn_parent_question_detail_index() OWNER TO postgres;

--
