-- Function: odiseo.fn_user_has_permission(bigint, character varying)

--

CREATE FUNCTION odiseo.fn_user_has_permission(p_user_id bigint, p_permission_name character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM users_roles ur
        JOIN users u ON u.id = ur.user_id AND u.fl_status IS TRUE AND u.id = p_user_id
        JOIN roles_permissions rp ON ur.rol_id = rp.rol_id AND rp.fl_status IS TRUE
        JOIN permissions p ON p.id = rp.permission_id AND p.name = p_permission_name AND p.fl_status IS TRUE
        WHERE ur.fl_status IS TRUE
    );
END;
$$;


ALTER FUNCTION odiseo.fn_user_has_permission(p_user_id bigint, p_permission_name character varying) OWNER TO postgres;

--
