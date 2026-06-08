-- Function: odiseo.fn_get_auth_user(bigint)

--

CREATE FUNCTION odiseo.fn_get_auth_user(p_user_id bigint) RETURNS TABLE(id bigint, uuid uuid, "user" character varying, email character varying, company_id integer, fl_suspended boolean, employee_id bigint, first_name character varying, first_surname character varying, second_surname character varying, document character varying, email_employee character varying, code character varying, charge_id bigint, rol_id bigint, rol character varying, courses jsonb, permissions text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH get_rol AS (
        SELECT
            r.id AS rol_id,
            r.name AS rol,
            r.fl_admin,
            r.fl_administrator,
            ur.user_id
        FROM roles r
        JOIN users_roles ur ON r.id = ur.rol_id
        WHERE ur.user_id = p_user_id
            AND ur.fl_status = true
    ), validate_admin_user AS (
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
    ), get_user AS (
        SELECT
            u.id,
            u.uuid,
            u.user,
            u.email,
            u.company_id,
            u.fl_suspended,
            e.id AS employee_id,
            e.first_name,
            e.first_surname,
            e.second_surname,
            e.document,
            e.email AS email_employee,
            e.code,
            e.charge_id,
            gr.rol_id,
            gr.rol,
			gce.courses
        FROM users u
        LEFT JOIN employees e ON u.id = e.user_id
            AND e.fl_status = true
        JOIN get_rol gr ON u.id = gr.user_id
		LEFT JOIN LATERAL (
			SELECT JSONB_AGG(DISTINCT course_id) AS courses
			FROM get_courses_employees
		) gce ON TRUE
        WHERE u.id = p_user_id
    ), get_permissions AS (
        SELECT
            rp.rol_id,
            jsonb_agg(json_build_object(
                'id', p.id,
                'name', p.name,
                'fl_administrator', p.fl_administrator,
                'fl_to_use_client', p.fl_to_use_client
            ))::TEXT AS permissions
        FROM roles_permissions rp
        JOIN get_rol gr ON rp.rol_id = gr.rol_id
        JOIN permissions p ON rp.permission_id = p.id
        WHERE rp.fl_status = true
        GROUP BY rp.rol_id
    )
    SELECT
        gu.id,
        gu.uuid,
        gu.user,
        gu.email::VARCHAR,
        gu.company_id,
        gu.fl_suspended,
        gu.employee_id,
        gu.first_name,
        gu.first_surname,
        gu.second_surname,
        gu.document,
        gu.email::VARCHAR AS email_employee,
        gu.code,
        gu.charge_id,
        gu.rol_id,
        gu.rol,
		gu.courses,
        gp.permissions
    FROM get_user gu
    JOIN get_permissions gp ON gu.rol_id = gp.rol_id;
    END;
$$;


ALTER FUNCTION odiseo.fn_get_auth_user(p_user_id bigint) OWNER TO postgres;

--
