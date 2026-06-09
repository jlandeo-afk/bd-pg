-- Function: auth.fn_create_user_role(bigint, bigint, integer)

--

CREATE FUNCTION auth.fn_create_user_role(p_user_id bigint, p_rol_id bigint, p_created_by integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
            BEGIN
                INSERT INTO auth.users_roles(user_id, rol_id, created_by, created_at)
                VALUES (p_user_id, p_rol_id, p_created_by, NOW());
            END;
            $$;


ALTER FUNCTION auth.fn_create_user_role(p_user_id bigint, p_rol_id bigint, p_created_by integer) OWNER TO postgres;

--
