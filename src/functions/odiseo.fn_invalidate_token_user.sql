-- Function: odiseo.fn_invalidate_token_user(bigint)

--

CREATE FUNCTION odiseo.fn_invalidate_token_user(p_user_id bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
            BEGIN
                UPDATE odiseo.personal_access_tokens SET revoked = true, updated_at = now() WHERE tokenable_id = p_user_id AND revoked = false;
                RETURN p_user_id;
            END;
            $$;


ALTER FUNCTION odiseo.fn_invalidate_token_user(p_user_id bigint) OWNER TO postgres;

--
