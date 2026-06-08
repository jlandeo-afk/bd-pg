-- Function: odiseo.fn_list_teachers_by_company(bigint, jsonb)

--

CREATE FUNCTION odiseo.fn_list_teachers_by_company(p_company_id bigint, p_courses jsonb) RETURNS TABLE(id bigint, value text, courses jsonb, fl_status boolean)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id,
        CONCAT(e.code, ' - ', e.first_name, ' ', e.first_surname, ' ', e.second_surname)::TEXT AS value,
        COALESCE(
            jsonb_agg(
                jsonb_build_object(
                    'id', c.id,
                    'code', c.code,
                    'name', c.name,
                    'fl_status', c.fl_status
                ) ORDER BY c.id ASC
            ),
            '[]'::jsonb
        ) AS courses,
        e.fl_status
    FROM teachers t
    INNER JOIN employees e ON e.id = t.employee_id
    INNER JOIN employee_course ec ON e.id = ec.teacher_id AND ec.fl_status = true
    INNER JOIN users u ON e.user_id = u.id AND u.fl_status = true AND u.fl_suspended = false
    INNER JOIN users_roles ur ON e.user_id = ur.user_id AND ur.fl_status = true
    INNER JOIN course c ON ec.course_id = c.id AND c.fl_status = true
    WHERE e.company_id = p_company_id
        AND e.fl_status = true
        AND ec.course_id = ANY (
            SELECT (jsonb_array_elements_text(p_courses))::SMALLINT
        )
        AND e.fl_resolve_missing_questions IS TRUE
    GROUP BY
        e.id,
        e.code,
        e.first_name,
        e.first_surname,
        e.second_surname,
        e.fl_status
    ORDER BY e.id ASC;
END;
$$;


ALTER FUNCTION odiseo.fn_list_teachers_by_company(p_company_id bigint, p_courses jsonb) OWNER TO postgres;

--
