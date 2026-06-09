-- Function: auth.fn_get_auth_user_details_details(bigint)

CREATE OR REPLACE FUNCTION auth.fn_get_auth_user_details_details(p_user_id bigint) RETURNS TABLE(id bigint, uuid uuid, "user" character varying, email character varying, company_id integer, fl_suspended boolean, employee_id bigint, first_name character varying, first_surname character varying, second_surname character varying, document character varying, email_employee character varying, code character varying, charge_id bigint, rol_id bigint, rol character varying, courses jsonb, permissions text)
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

ALTER FUNCTION auth.fn_get_auth_user_details_details(p_user_id bigint) OWNER TO postgres;


-- Function: auth.fn_get_user_profile(uuid, bigint)

CREATE OR REPLACE FUNCTION auth.fn_get_user_profile(p_uuid uuid, p_company_id bigint) RETURNS TABLE(uuid uuid, user_name character varying, email character varying, rol_id bigint, employee_uuid uuid, first_name character varying, first_surname character varying, second_surname character varying, personal_email character varying, phone character varying, charge_id bigint, type_document_id bigint, document character varying, company_id integer, data_universities jsonb, courses jsonb, data_teacher json)
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                        RETURN QUERY
                        WITH exists_employee AS (
                            SELECT
                                u.uuid,
                                e.id AS employee_id
                            FROM users u
                            JOIN employees e ON u.id = e.user_id
                            WHERE u.uuid = p_uuid
                                AND u.company_id = p_company_id
                        ), get_courses AS (
                            SELECT
                                ec.course_id AS id,
                                c.name,
                                ec.created_at
                            FROM employee_course ec
                            JOIN course c ON ec.course_id = c.id
                            WHERE ec.teacher_id IN (SELECT ee.employee_id FROM exists_employee ee)
                                AND ec.fl_status = true
                        ), get_universities AS (
                            SELECT
                                eu.university_id AS id,
                                ou.name,
                                eu.created_at
                            FROM employee_university eu
                            JOIN origin_university ou ON eu.university_id = ou.id
                            WHERE eu.employee_id IN (SELECT ee.employee_id FROM exists_employee ee)
                                AND eu.fl_status = true
                        ), get_data_teacher AS (
                            SELECT
                                e.fl_unlimit_questions,
                                e.goal,
                                e.lot,
                                e.level_id,
                                lr.level_name,
                                e.fl_resolve_missing_questions,
                                e.limit_missing_questions
                            FROM employees e
                            LEFT JOIN level_rates lr ON e.level_id = lr.id
                            WHERE e.id IN (SELECT ee.employee_id FROM exists_employee ee)
                                AND e.charge_id = 2
                        )
                        SELECT
                            u.uuid,
                            u.user AS user_name,
                            u.email::varchar,
                            ur.rol_id,
                            e.uuid AS employee_uuid,
                            e.first_name,
                            e.first_surname,
                            e.second_surname,
                            e.email::varchar AS personal_email,
                            e.phone,
                            e.charge_id,
                            e.type_document_id,
                            e.document,
                            u.company_id,
                            (
                                SELECT JSONB_AGG(gu.id ORDER BY gu.id)
                                FROM get_universities gu
                            ) data_universities,
                            (
                                SELECT JSONB_AGG(gc.id ORDER BY gc.id)
                                FROM get_courses gc
                            ) courses,
                            (
                                SELECT JSON_BUILD_OBJECT(
                                    'fl_unlimit_questions', gdt.fl_unlimit_questions,
                                    'goal', gdt.goal,
                                    'lot', gdt.lot,
                                    'level_id', gdt.level_id,
                                    'level_name', gdt.level_name,
                                    'fl_resolve_missing_questions', gdt.fl_resolve_missing_questions,
                                    'missing_questions_lot', gdt.limit_missing_questions
                                )
                                FROM get_data_teacher gdt
                                LIMIT 1
                            ) AS data_teacher
                        FROM employees e
                        JOIN users u ON e.user_id = u.id
                        JOIN users_roles ur ON u.id = ur.user_id
                        WHERE e.id IN (SELECT ee.employee_id FROM exists_employee ee);
                    END;
                    $$;

ALTER FUNCTION auth.fn_get_user_profile(p_uuid uuid, p_company_id bigint) OWNER TO postgres;
