-- Function: auth.fn_get_nq_user_token(bigint)

CREATE OR REPLACE FUNCTION auth.fn_get_nq_user_token(p_user_id bigint) RETURNS TABLE(token character varying, "user" character varying)
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

ALTER FUNCTION auth.fn_get_nq_user_token(p_user_id bigint) OWNER TO postgres;


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
