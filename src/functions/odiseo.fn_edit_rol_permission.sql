-- Function: odiseo.fn_edit_rol_permission(integer, boolean, integer, integer)

--

CREATE FUNCTION odiseo.fn_edit_rol_permission(p_id integer, p_fl_status boolean, p_updated_by integer, p_company_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    DECLARE
        v_rol_permission_id INTEGER;
    BEGIN
        IF p_company_id IS NULL THEN
            RAISE EXCEPTION 'El company_id es requerido para editar un permiso de rol';
        END IF;

        UPDATE roles_permissions
        SET
            fl_status = p_fl_status,
            updated_by = 1,
            updated_at = now()
        WHERE id = p_id
        AND company_id = p_company_id
        RETURNING id INTO v_rol_permission_id;
        RETURN v_rol_permission_id;
    END;
    $$;


ALTER FUNCTION odiseo.fn_edit_rol_permission(p_id integer, p_fl_status boolean, p_updated_by integer, p_company_id integer) OWNER TO postgres;

--
