-- Function: auth.fn_show_user_uuid(uuid, bigint)

--

CREATE FUNCTION auth.fn_show_user_uuid(p_uuid uuid, p_company_id bigint) RETURNS TABLE(uuid uuid, user_name character varying, email character varying, rol_id bigint, employee_uuid uuid, first_name character varying, first_surname character varying, second_surname character varying, personal_email character varying, phone character varying, charge_id bigint, type_document_id bigint, document character varying, company_id integer, data_universities jsonb, courses jsonb, data_teacher json)
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


ALTER FUNCTION auth.fn_show_user_uuid(p_uuid uuid, p_company_id bigint) OWNER TO postgres;

--
