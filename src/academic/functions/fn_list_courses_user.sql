-- Function: academic.fn_list_courses_user(bigint)

--

CREATE FUNCTION academic.fn_list_courses_user(p_user_id bigint) RETURNS TABLE(id smallint, name character varying)
    LANGUAGE plpgsql
    AS $$
            BEGIN
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

                    SELECT
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
                    gce.course_id::SMALLINT AS id,
                    c.name
                FROM get_courses_employees gce
                JOIN course c ON gce.course_id = c.id
                ORDER BY c.id;
            END;
            $$;


ALTER FUNCTION academic.fn_list_courses_user(p_user_id bigint) OWNER TO postgres;

--
