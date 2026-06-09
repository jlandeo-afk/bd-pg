-- Function: questions.fn_change_status_parent(bigint, character varying)

--

CREATE FUNCTION questions.fn_change_status_parent(p_question_id bigint, p_status character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    UPDATE parent_question pq
                    SET status = p_status
                    WHERE 
                    pq.id = (SELECT parent_id FROM question WHERE id = p_question_id) 
                    AND NOT EXISTS (
                        SELECT 1
                        FROM question q
                        WHERE q.parent_id = pq.id
                        AND q.status IS DISTINCT FROM p_status
                    );
                END;
            $$;


ALTER FUNCTION questions.fn_change_status_parent(p_question_id bigint, p_status character varying) OWNER TO postgres;

--
