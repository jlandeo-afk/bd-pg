-- Function: academic.fn_get_course_by_syllabus(smallint, bigint, bigint, bigint)

--

CREATE FUNCTION academic.fn_get_course_by_syllabus(p_university_id smallint, p_cycle_id bigint, p_company_id bigint, p_employee_id bigint DEFAULT NULL::bigint) RETURNS TABLE(id smallint, code character varying, name character varying, course text, quantity bigint, fl_template boolean, is_pseudo boolean, apply_text boolean, is_syllabus boolean, type_text_template_id smallint)
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
                        CASE
                            WHEN syllab_course.course_id IS NOT NULL
                                THEN true
                                ELSE false
                        END AS is_syllabus,
                        c.type_text_template_id
                    FROM course c
                    LEFT JOIN employee_course ec ON ec.course_id = c.id AND ec.fl_status IS true
                    LEFT JOIN (
                        SELECT
                            course_id, COUNT(*) AS quantity
                        FROM syllabus_template st
                        WHERE (p_university_id IS null OR st.university_id = p_university_id)
                        AND st.fl_status = true
                        AND st.company_id = p_company_id
                        GROUP BY course_id
                    ) syllab_count ON syllab_count.course_id = c.id
                    LEFT JOIN (
                        SELECT
                            course_id, COUNT(*) AS quantity
                        FROM syllabus s
                        WHERE s.university_id = p_university_id
                            AND s.cycle_id = p_cycle_id
                            AND s.fl_status = true
                            AND s.company_id = p_company_id
                        GROUP BY course_id
                    ) syllab_course ON syllab_course.course_id = c.id
                    WHERE 1 = 1
                        AND (p_employee_id IS null OR ec.teacher_id = p_employee_id)
                        AND c.fl_status = true
                    ORDER BY course ASC, c.id ASC;
                END;
                $$;


ALTER FUNCTION academic.fn_get_course_by_syllabus(p_university_id smallint, p_cycle_id bigint, p_company_id bigint, p_employee_id bigint) OWNER TO postgres;

--
