-- Function: odiseo.fn_change_user_courses(bigint, jsonb, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_change_user_courses(p_employee_id bigint, p_courses jsonb, p_company_id bigint, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
        WITH get_courses AS (
            SELECT
                course::BIGINT AS course_id
            FROM jsonb_array_elements(p_courses) course
        ), rol_user_edit AS (
            SELECT
                r.name AS rol,
                CASE
                    WHEN e.user_id IS NOT NULL THEN
                        CONCAT(split_part(e.first_name, ' ', 1), ' ', upper(left(e.first_surname, 1)), '. ', e.second_surname)
                    ELSE 'admin-odiseo'
                END AS user_name
            FROM users_roles ur
            INNER JOIN roles r ON ur.rol_id = r.id
            LEFT JOIN users u ON ur.user_id = u.id
            LEFT JOIN employees e ON u.id = e.user_id
            WHERE ur.user_id = p_updated_by
        ), get_employees AS (
            SELECT
                e.id,
                concat(
                    split_part(e.first_name, ' ', 1),
                    ' ',
                    upper(left(e.first_surname, 1)),
                    '. ',
                    e.second_surname
                ) AS employee_name,
                e.charge_id
            FROM employees e
            WHERE e.id = p_employee_id
                AND e.company_id = p_company_id
        ), deleted_courses AS (
            UPDATE employee_course ec
            SET fl_status = false,
                deleted_by = p_updated_by,
                deleted_at = now()
            WHERE ec.teacher_id = p_employee_id
                AND ec.fl_status IS TRUE
                AND NOT EXISTS (
                    SELECT 1
                    FROM get_courses gc
                    WHERE gc.course_id = ec.course_id
                )
            RETURNING ec.course_id
        ), insert_courses AS (
            INSERT INTO employee_course AS ec(
                teacher_id,
                course_id,
                created_by,
                created_at
            )
            SELECT
                p_employee_id,
                gc.course_id,
                p_updated_by,
                now()
            FROM get_courses gc
            WHERE NOT EXISTS (
                SELECT 1
                FROM employee_course ec
                WHERE ec.teacher_id = p_employee_id
                    AND ec.course_id = gc.course_id
                    AND ec.fl_status IS TRUE
            )
            RETURNING ec.course_id
        ), deleted_questions_is_teacher AS (
            UPDATE employee_question AS eq
            SET fl_status = false,
                deleted_by = p_updated_by,
                deleted_at = NOW()
            FROM question q,
                get_employees ge
            WHERE ge.id = eq.teacher_id
                AND ge.charge_id = 2
                AND eq.fl_status = true
                AND eq.question_id = q.id
                AND q.fl_status = true
                AND q.status IN ('ASIG', 'RESO')
                AND q.course_id IN (SELECT dc.course_id FROM deleted_courses dc)
            RETURNING eq.question_id
        ), change_status_question AS (
            UPDATE question AS q
            SET status = 'SASI',
                updated_by = p_updated_by,
                updated_at = NOW()
            WHERE q.id IN (SELECT eq.question_id FROM deleted_questions_is_teacher eq)
            RETURNING q.id, q.parent_id
        ), inactive_history_status AS (
            UPDATE question_status qs
            SET fl_active = false,
                updated_at = NOW()
            WHERE qs.question_id IN (SELECT csq.id FROM change_status_question csq)
                AND qs.fl_active = true
        ), save_history_question AS (
            INSERT INTO question_status (
                question_id,
                status,
                process,
                description,
                fl_active,
                created_by,
                created_at
            )
            SELECT
                csq.id,
                'SASI',
                'SIN ASIGNACIÓN',
                CONCAT(
                    'La pregunta se le ha quitado al Docente <span class="text-teacher">',
                    ge.employee_name,
                    '</span> por el ',
                    rue.user_name,
                    ' <span class="text-user">',
                    rue.rol,
                    '</span>'
                ),
                true,
                p_updated_by,
                NOW()
            FROM change_status_question csq,
                get_employees ge,
                rol_user_edit rue
        )
        UPDATE parent_question pq
        SET status = 'SASI',
            updated_by = p_updated_by,
            updated_at = NOW()
        WHERE pq.id IN (
            SELECT
                csq.parent_id
            FROM change_status_question csq
            WHERE csq.parent_id IS NOT NULL
        );
    END;
    $$;


ALTER FUNCTION odiseo.fn_change_user_courses(p_employee_id bigint, p_courses jsonb, p_company_id bigint, p_updated_by bigint) OWNER TO postgres;

--
