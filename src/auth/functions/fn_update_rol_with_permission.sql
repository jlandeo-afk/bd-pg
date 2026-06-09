-- Function: auth.fn_update_rol_with_permission(bigint, character varying, character varying, character varying, jsonb, bigint, bigint)

--

CREATE FUNCTION auth.fn_update_rol_with_permission(p_id bigint, p_name character varying, p_slug character varying, p_description character varying, p_permissions jsonb, p_updated_by bigint, p_company_id bigint) RETURNS TABLE(id bigint)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        WITH get_rol_user_edit AS (
            SELECT
                ur.rol_id,
                r.fl_administrator
            FROM users_roles ur
            JOIN roles r ON ur.rol_id = r.id
            WHERE ur.user_id = p_updated_by
            AND r.company_id = p_company_id
        ), update_rol AS (
            UPDATE roles as r
            SET
                name = p_name,
                slug = p_slug,
                description = p_description,
                updated_by = p_updated_by,
                company_id = p_company_id
            WHERE r.id = p_id
            RETURNING r.id
        ), deleted_permission AS (
            UPDATE roles_permissions rp
            SET
                fl_status = false
            FROM permissions p
            WHERE rp.permission_id = p.id
                AND rp.rol_id = p_id
                AND rp.fl_status = true
                AND rp.company_id = p_company_id
                AND rp.permission_id NOT IN (
                    SELECT (p.value)::BIGINT
                    FROM jsonb_array_elements(p_permissions) p(value)
                )
                AND (
                    (p.fl_administrator = true and EXISTS (
                        SELECT 1
                        FROM get_rol_user_edit grue
                        WHERE grue.fl_administrator = true
                    )
               ) OR p.fl_administrator = false )
        ), insert_new_permissions AS (
            INSERT INTO roles_permissions (
                rol_id,
                permission_id,
                created_by,
                company_id
            )
            SELECT
                p_id,
                (p.value)::BIGINT,
                p_updated_by,
                p_company_id
            FROM jsonb_array_elements(p_permissions) p(value)
            WHERE NOT EXISTS (
                SELECT 1
                FROM roles_permissions
                WHERE rol_id = p_id
                    AND permission_id = (p.value)::BIGINT
                    AND company_id = p_company_id
                    AND fl_status = true
            )
        )
        SELECT ur.id FROM update_rol ur;

    END;
    $$;


ALTER FUNCTION auth.fn_update_rol_with_permission(p_id bigint, p_name character varying, p_slug character varying, p_description character varying, p_permissions jsonb, p_updated_by bigint, p_company_id bigint) OWNER TO postgres;

--
