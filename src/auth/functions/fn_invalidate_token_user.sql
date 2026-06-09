-- Function: auth.fn_invalidate_token_user(bigint)

--

CREATE FUNCTION auth.fn_invalidate_token_user(p_user_id bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
            BEGIN
                UPDATE auth.personal_access_tokens SET revoked = true, updated_at = now() WHERE tokenable_id = p_user_id AND revoked = false;
                RETURN p_user_id;
            END;
            $$;


ALTER FUNCTION auth.fn_invalidate_token_user(p_user_id bigint) OWNER TO postgres;

--
