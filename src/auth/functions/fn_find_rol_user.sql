-- Function: auth.fn_find_rol_user(integer, integer)

--

CREATE FUNCTION auth.fn_find_rol_user(p_user_id integer, p_company_id integer) RETURNS TABLE(id bigint, name character varying, slug character varying, fl_administrator boolean, permissions json, courses jsonb)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_can_see_all BOOLEAN;
            v_company_base BOOLEAN;
        BEGIN
            -- Verificamos si el usuario tiene el permiso 'admin.filtrar-empresas'
            SELECT EXISTS (
                SELECT 1
                FROM users_roles ur
                JOIN roles r ON ur.rol_id = r.id AND r.fl_status = TRUE
                JOIN roles_permissions rp ON r.id = rp.rol_id AND rp.fl_status = TRUE
                JOIN permissions p ON rp.permission_id = p.id AND p.fl_status = TRUE
                WHERE ur.user_id = p_user_id
                AND p.name = 'admin.filtrar-empresas'
            ) INTO v_can_see_all;

            -- Verificar si p_company_id es igual a 1 (Vonex)
            v_company_base := p_company_id = 1;

            RETURN QUERY
            WITH validate_admin_user AS (
                SELECT
                    u.id,
                    r.fl_administrator,
                    rp.permission_id
                FROM users u
                JOIN users_roles ur ON u.id = ur.user_id
                JOIN roles r ON ur.rol_id = r.id
                LEFT JOIN roles_permissions rp ON r.id = rp.rol_id
                    AND rp.permission_id = 133 -- 'admin.admin'
                WHERE u.id = p_user_id
            ), get_courses_employees AS (
                SELECT DISTINCT
                    ec.course_id
                FROM employees e
                JOIN employee_course ec ON e.id = ec.teacher_id
                WHERE e.user_id = p_user_id
                    AND ec.fl_status = true
                    AND NOT EXISTS (
                        SELECT 1
                        FROM validate_admin_user vau
                        WHERE vau.permission_id = 133
                    )

                UNION ALL

                SELECT DISTINCT
                    c.id AS course_id
                FROM course c
                WHERE c.fl_status = true
                AND EXISTS (
                        SELECT 1
                        FROM validate_admin_user vau
                        WHERE vau.permission_id = 133
                    )
            )
            SELECT
                r.id,
                r.name,
                r.slug,
                r.fl_administrator,
                COALESCE(
                    JSON_AGG(
                        JSON_BUILD_OBJECT('name', p.name)
                    ) FILTER ( -- Filtramos si el permiso es diferente de NULL, y si tiene el permiso 'admin.filtrar-empresas' o si es de Vonex para solo mostrar los permisos fl_to_use_client
                        WHERE p.id IS NOT NULL
                        AND (
                            v_can_see_all IS TRUE OR
                            v_company_base IS TRUE OR (
                                v_company_base IS FALSE AND p.fl_to_use_client IS TRUE
                            )
                        )
                    ),
                    '[]'::json
                ) AS permissions,
                gce.courses
            FROM users_roles ur
            LEFT JOIN roles r ON ur.rol_id = r.id AND r.fl_status = TRUE
            LEFT JOIN roles_permissions rp ON r.id = rp.rol_id AND rp.fl_status = TRUE
            LEFT JOIN permissions p ON rp.permission_id = p.id AND p.fl_status = TRUE
            LEFT JOIN LATERAL (
                SELECT JSONB_AGG(DISTINCT course_id) AS courses
                FROM get_courses_employees
            ) gce ON TRUE
            WHERE ur.user_id = p_user_id
            GROUP BY r.id, r.name, r.slug, r.fl_administrator, gce.courses;
        END;
        $$;


ALTER FUNCTION auth.fn_find_rol_user(p_user_id integer, p_company_id integer) OWNER TO postgres;

--
