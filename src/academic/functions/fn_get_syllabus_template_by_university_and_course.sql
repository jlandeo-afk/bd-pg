-- Function: academic.fn_get_syllabus_template_by_university_and_course(smallint, smallint, bigint)

--

CREATE FUNCTION academic.fn_get_syllabus_template_by_university_and_course(p_university_id smallint, p_course_id smallint, p_company_id bigint) RETURNS TABLE(id smallint)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            SELECT
                st.id
            FROM syllabus_template st
            WHERE 1 = 1
                AND st.university_id = p_university_id
                AND st.course_id = p_course_id
                AND st.fl_status IS TRUE
                AND st.company_id = p_company_id
            ORDER BY st.id DESC;
        END;
        $$;


ALTER FUNCTION academic.fn_get_syllabus_template_by_university_and_course(p_university_id smallint, p_course_id smallint, p_company_id bigint) OWNER TO postgres;

--
