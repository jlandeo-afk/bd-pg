-- Function: odiseo.fn_revoke_user_token(uuid, bigint)

--

CREATE FUNCTION odiseo.fn_revoke_user_token(p_user_uuid uuid, p_created_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE v_user_id BIGINT;
    BEGIN
        SELECT id INTO v_user_id FROM users WHERE uuid = p_user_uuid;

        UPDATE nq_user_request
            SET request_status = 'to_be_requested'
        WHERE user_id = v_user_id;

        UPDATE nq_user_token
            SET
                deleted_at = NOW(),
                deleted_by = p_created_by
        WHERE 1 = 1
          AND deleted_at IS NULL
          AND user_id = v_user_id;
    END;
    $$;


ALTER FUNCTION odiseo.fn_revoke_user_token(p_user_uuid uuid, p_created_by bigint) OWNER TO postgres;

--
