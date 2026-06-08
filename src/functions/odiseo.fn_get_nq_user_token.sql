-- Function: odiseo.fn_get_nq_user_token(bigint)

--

CREATE FUNCTION odiseo.fn_get_nq_user_token(p_user_id bigint) RETURNS TABLE(token character varying, "user" character varying)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        SELECT
            nut.nq_token,
            nut.nq_user
        FROM nq_user_token nut
        WHERE 1 = 1
          AND nut.user_id = p_user_id
          AND nut.deleted_at IS NULL
        ORDER BY nut.created_at DESC
        LIMIT 1;
    END;
    $$;


ALTER FUNCTION odiseo.fn_get_nq_user_token(p_user_id bigint) OWNER TO postgres;

--
