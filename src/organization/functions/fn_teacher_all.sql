-- Function: organization.fn_teacher_all(bigint)

--

CREATE FUNCTION organization.fn_teacher_all(p_company_id bigint) RETURNS TABLE(id bigint, value text, courses json, fl_status boolean)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    e.id,
                    CONCAT(e.code, ' - ', e.first_name, ' ', e.first_surname, ' ', e.second_surname) as value,
                    CASE
                        WHEN count(c.id) > 0 THEN json_agg(c.*)
                        ELSE '[]'::json
                    END AS courses,
                    e.fl_status
                FROM employees e
                INNER JOIN employee_course ec ON e.id = ec.teacher_id AND ec.fl_status = true
                INNER JOIN users u ON e.user_id = u.id AND u.fl_status = true and u.fl_suspended = false
                INNER JOIN users_roles ur ON e.user_id = ur.user_id AND ur.fl_status = true
                INNER JOIN (SELECT c.id, c.code, c.name, c.fl_status FROM course c WHERE c.fl_status = true ORDER BY c.id ASC) c ON ec.course_id = c.id
                WHERE e.fl_status = true
                    AND (ur.rol_id = 11 OR charge_id = 2)
                    AND e.company_id = p_company_id
                GROUP BY
                    e.id,
                    value,
                    e.fl_status
                ORDER BY e.id ASC;
            END;
            $$;


ALTER FUNCTION organization.fn_teacher_all(p_company_id bigint) OWNER TO postgres;

--
