-- Function: odiseo.fn_get_all_course_by_employee_and_university(bigint, smallint, bigint)

--

CREATE FUNCTION odiseo.fn_get_all_course_by_employee_and_university(p_employee_id bigint, p_university_id smallint, p_company_id bigint) RETURNS TABLE(id smallint, code character varying, name character varying, course text, quantity bigint, fl_template boolean, is_pseudo boolean, apply_text boolean, type_text_template_id smallint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        c.id,
        c.code,
        c.name,
        CONCAT(c.code, ' - ', c.name) AS course,
        COALESCE(syllab_count.quantity, 0) as quantity,
        CASE
            WHEN syllab_count.quantity > 0
                THEN true
                ELSE false
        END AS fl_template,
        c.fl_pseudo_course AS is_pseudo,
        c.apply_text,
        c.type_text_template_id
    FROM course c
    LEFT JOIN employee_course ec ON ec.course_id = c.id AND ec.fl_status IS true
    LEFT JOIN (
        SELECT course_id, COUNT(*) AS quantity
        FROM syllabus_template st
        WHERE (p_university_id IS null OR st.university_id = p_university_id)
        AND st.fl_status = true
        AND st.company_id = p_company_id
        GROUP BY course_id
    ) syllab_count ON syllab_count.course_id = c.id
    WHERE 1 = 1
    AND (p_employee_id IS null OR ec.teacher_id = p_employee_id)
    AND c.fl_status = true
    ORDER BY course ASC, c.id ASC;
END;
$$;


ALTER FUNCTION odiseo.fn_get_all_course_by_employee_and_university(p_employee_id bigint, p_university_id smallint, p_company_id bigint) OWNER TO postgres;

--
