-- Function: odiseo.fn_has_user_nq_courses(bigint)

--

CREATE FUNCTION odiseo.fn_has_user_nq_courses(p_user_id bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN EXISTS(
        SELECT 1
        FROM odiseo.employee_course ec
        JOIN odiseo.employees e ON e.id = ec.teacher_id AND e.user_id = p_user_id
        JOIN odiseo.course c ON c.id = ec.course_id AND ec.fl_status IS TRUE AND c.alias_nq IS NOT NULL
    );
END;
$$;


ALTER FUNCTION odiseo.fn_has_user_nq_courses(p_user_id bigint) OWNER TO postgres;

--
