-- Function: odiseo.fn_create_user_from_contributor(uuid, character varying, character varying, character varying, boolean, bigint, integer)

--

CREATE FUNCTION odiseo.fn_create_user_from_contributor(p_uuid uuid, p_user character varying, p_email character varying, p_password character varying, p_status boolean, p_company bigint, p_created_by integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_new_user_id INTEGER;
                BEGIN
                    INSERT INTO users("uuid", "user", email, "password", fl_status, status_session, company_id, created_by, created_at)
                    VALUES (p_uuid, p_user, p_email, p_password, p_status,1001, p_company, p_created_by, NOW())
                    RETURNING id AS user_id INTO v_new_user_id;

                    RETURN v_new_user_id;
                END;
            $$;


ALTER FUNCTION odiseo.fn_create_user_from_contributor(p_uuid uuid, p_user character varying, p_email character varying, p_password character varying, p_status boolean, p_company bigint, p_created_by integer) OWNER TO postgres;

--
