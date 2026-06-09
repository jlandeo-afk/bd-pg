-- Function: questions.fn_child_parent_question(bigint)

--

CREATE FUNCTION questions.fn_child_parent_question(p_parent_id bigint) RETURNS TABLE(id bigint, code character varying, parent_id bigint, status character varying, fl_status boolean)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            SELECT
                q.id,
                q.code,
                q.parent_id,
                q.status,
                q.fl_status
            FROM questions.question q
            WHERE q.parent_id = p_parent_id
            AND q.fl_status = true
            ORDER BY q.id ASC;
        END;
        $$;


ALTER FUNCTION questions.fn_child_parent_question(p_parent_id bigint) OWNER TO postgres;

--
