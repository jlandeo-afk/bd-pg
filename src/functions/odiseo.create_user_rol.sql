-- Function: odiseo.create_user_rol(bigint, bigint, integer)

--

CREATE FUNCTION odiseo.create_user_rol(p_user_id bigint, p_rol_id bigint, p_created_by integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
            BEGIN
                INSERT INTO odiseo.users_roles(user_id, rol_id, created_by, created_at)
                VALUES (p_user_id, p_rol_id, p_created_by, NOW());
            END;
            $$;


ALTER FUNCTION odiseo.create_user_rol(p_user_id bigint, p_rol_id bigint, p_created_by integer) OWNER TO postgres;

--
