-- Function: auth.fn_update_user_by_uuid(uuid, character varying, bigint, integer, bigint)

CREATE OR REPLACE FUNCTION auth.fn_update_user_by_uuid(p_user_uuid uuid, p_email character varying, p_role_id bigint, p_company_id integer, p_update_by bigint) RETURNS TABLE(status boolean, data uuid)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        WITH get_user AS (
            SELECT
                u.id
            FROM users u
            WHERE u.uuid = p_user_uuid::UUID
            AND u.fl_status = true
        ), update_user AS (
            UPDATE users u
                set email = p_email,
                updated_by = p_update_by,
                updated_at = now()
            WHERE u.id IN (SELECT gu.id FROM get_user gu)
        ), update_rol AS (
            UPDATE users_roles
            SET rol_id = p_role_id,
            updated_by = p_update_by,
            updated_at = now()
            WHERE user_id IN (SELECT gu.id FROM get_user gu)
                AND fl_status = true
        ), validate_change_company_user AS (
            SELECT
                u.id,
                r.fl_administrator,
                rp.permission_id
            FROM users u
            JOIN users_roles ur ON u.id = ur.user_id
            JOIN roles r ON ur.rol_id = r.id
            LEFT JOIN roles_permissions rp ON r.id = rp.rol_id
                AND rp.permission_id = 219 -- 'admin.seleccionar-empresa-usuario'
            WHERE u.id = p_update_by
        ), update_company_user AS (
            UPDATE users u
                set company_id = p_company_id
            WHERE u.id IN (SELECT gu.id FROM get_user gu)
                AND EXISTS (
                    SELECT 1 FROM validate_change_company_user vcu
                )
        ), update_company_employee AS (
            UPDATE employees e
                set company_id = p_company_id
            WHERE e.user_id IN (SELECT gu.id FROM get_user gu)
                AND EXISTS (
                    SELECT 1 FROM validate_change_company_user vcu
                )
        )
        SELECT
            TRUE AS status,
            e.uuid AS data
        FROM employees e
        WHERE e.user_id IN (SELECT gu.id FROM get_user gu);
    END;
    $$;

ALTER FUNCTION auth.fn_update_user_by_uuid(p_user_uuid uuid, p_email character varying, p_role_id bigint, p_company_id integer, p_update_by bigint) OWNER TO postgres;
