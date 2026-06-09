-- Function: auth.fn_nq_create_user_token(uuid, character varying, character varying, timestamp with time zone, bigint)

--

CREATE FUNCTION auth.fn_nq_create_user_token(p_user_uuid uuid, p_nq_user character varying, p_nq_token character varying, p_nq_token_expiration_date timestamp with time zone, p_created_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE v_user_id BIGINT;
    BEGIN
        SELECT id INTO v_user_id FROM users WHERE uuid = p_user_uuid;

        PERFORM fn_revoke_user_token(p_user_uuid, p_created_by);
                
        INSERT INTO nq_user_request(user_id, request_status, created_by, created_at)
        VALUES(v_user_id, 'delivered', p_created_by, NOW())
        ON CONFLICT ON CONSTRAINT nq_req_user_id
        DO UPDATE
            SET
                request_status = 'delivered',
                updated_at = NOW(),
                deleted_at = NULL,
                deleted_by = NULL;
                            
        INSERT INTO nq_user_token(user_id, nq_user, nq_token, nq_expiration_date, created_by, created_at)
        VALUES(v_user_id, p_nq_user, p_nq_token, p_nq_token_expiration_date, p_created_by, NOW());
    END;
    $$;


ALTER FUNCTION auth.fn_nq_create_user_token(p_user_uuid uuid, p_nq_user character varying, p_nq_token character varying, p_nq_token_expiration_date timestamp with time zone, p_created_by bigint) OWNER TO postgres;

--
