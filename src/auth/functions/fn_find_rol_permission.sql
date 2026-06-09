-- Function: auth.fn_find_rol_permission(integer, integer, integer)

--

CREATE FUNCTION auth.fn_find_rol_permission(p_rol_id integer, p_permission_id integer, p_company_id integer) RETURNS TABLE(id bigint, rol_id bigint, permission_id bigint, fl_status boolean, created_by bigint, updated_by bigint, created_at timestamp without time zone, updated_at timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        IF p_company_id IS NULL THEN
            RAISE EXCEPTION 'El parámetro p_company_id es requerido para encontrar el permiso del rol.';
        END IF;

        RETURN QUERY
        SELECT
            rp.id,
            rp.rol_id,
            rp.permission_id,
            rp.fl_status,
            rp.created_by,
            rp.updated_by,
            rp.created_at,
            rp.updated_at
        FROM roles_permissions rp
        WHERE rp.rol_id = p_rol_id
        AND rp.permission_id = p_permission_id
        AND rp.company_id = p_company_id;
    END;
    $$;


ALTER FUNCTION auth.fn_find_rol_permission(p_rol_id integer, p_permission_id integer, p_company_id integer) OWNER TO postgres;

--
