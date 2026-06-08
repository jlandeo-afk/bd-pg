-- Function: odiseo.fn_total_text_by_courses_syllabus(integer, integer, integer, integer, integer[])

--

CREATE FUNCTION odiseo.fn_total_text_by_courses_syllabus(p_university_id integer, p_cycle_id integer, p_week integer, p_type_material_id integer, p_courses integer[]) RETURNS TABLE(total_passages_syllabus bigint, syllabus_total bigint, course_id smallint, course_name character varying, type_config text)
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                        RETURN QUERY
                        SELECT
                            COUNT(st.id) AS total_passages_syllabus,
                            COUNT(st.id) AS syllabus_total,
                            c.id AS course_id,
                            c.name AS course_name,
                            'syllabus' AS type_config
                        FROM
                            course c
                        LEFT JOIN syllabus s
                            ON s.course_id = c.id
                            AND s.university_id = p_university_id
                            AND s.cycle_id = p_cycle_id
                        LEFT JOIN syllabus_text_weeks stw
                            ON stw.syllabus_id = s.id
                            AND stw.week = p_week AND stw.fl_status = true
                        LEFT JOIN syllabus_text_distributions std
                            ON std.syllabus_text_week_id = stw.id
                            AND std.type_material_id = p_type_material_id 
                            AND std.fl_status = true
                        LEFT JOIN syllabus_texts st
                            ON st.syllabus_text_distribution_id = std.id
                            AND st.fl_status = true
                        WHERE
                            c.id = ANY(p_courses)
                        GROUP BY
                            c.id, c.name;
                    END;
                    $$;


ALTER FUNCTION odiseo.fn_total_text_by_courses_syllabus(p_university_id integer, p_cycle_id integer, p_week integer, p_type_material_id integer, p_courses integer[]) OWNER TO postgres;

--
