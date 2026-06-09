-- Function: auth.fn_create_rol_permission(integer, integer, integer, integer)

CREATE OR REPLACE FUNCTION auth.fn_create_rol_permission(p_rol_id integer, p_permission_id integer, p_created_by integer, p_company_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    DECLARE
        v_new_rol_permission_id INTEGER;
    BEGIN
        INSERT INTO roles_permissions (rol_id, permission_id, created_by,company_id, created_at)
        VALUES (p_rol_id, p_permission_id, p_created_by,p_company_id, now())
        RETURNING id AS rol_permission_id INTO v_new_rol_permission_id;
    
        RETURN v_new_rol_permission_id;
    END;
    $$;

ALTER FUNCTION auth.fn_create_rol_permission(p_rol_id integer, p_permission_id integer, p_created_by integer, p_company_id integer) OWNER TO postgres;
