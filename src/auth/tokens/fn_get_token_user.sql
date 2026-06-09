-- Function: auth.fn_get_token_user(bigint)

CREATE OR REPLACE FUNCTION auth.fn_get_token_user(p_user_id bigint) RETURNS TABLE(id bigint, tokenable_id bigint, token text, revoked boolean, expires_at timestamp without time zone, created_at timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            SELECT
                p.id,
                p.tokenable_id,
                p.token,
                p.revoked,
                p.expires_at,
                p.created_at
            FROM auth.personal_access_tokens p
            WHERE p.tokenable_id = p_user_id
            AND p.revoked IS FALSE;
        END;
        $$;

ALTER FUNCTION auth.fn_get_token_user(p_user_id bigint) OWNER TO postgres;
