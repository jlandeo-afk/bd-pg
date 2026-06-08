-- Function: odiseo.fn_total_text_by_courses_levels(integer, integer, integer, integer, integer, integer[])

--

CREATE FUNCTION odiseo.fn_total_text_by_courses_levels(p_university_id integer, p_cycle_id integer, p_headquarter_id integer, p_week integer, p_type_material_id integer, p_courses integer[]) RETURNS TABLE(total_passages_levels bigint, levels_total bigint, course_id smallint, course_name character varying, type_config text)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    SUM(COALESCE(dlswp.number_of_passages, 0)) AS total_passages_levels,
                    SUM(COALESCE(dlswp.number_of_passages, 0)) AS levels_total,
                    c.id AS course_id,
                    c.name AS course_name,
                    'level' AS type_config
                FROM
                    course c
                LEFT JOIN level_syllabus ls
                    ON ls.course_id = c.id
                    AND ls.fl_status = TRUE
                    AND ls.headquarter_id = p_headquarter_id
                    AND ls.cycle_id = p_cycle_id
                    AND ls.university_id = p_university_id
                LEFT JOIN level_syllabus_weeks lsw
                    ON lsw.level_syllabus_id = ls.id
                    AND lsw.week = p_week
                LEFT JOIN detail_level_syllabus_weeks_parents dlswp
                    ON dlswp.level_syllabus_weeks_id = lsw.id
                    AND dlswp.fl_status = TRUE
                    AND dlswp.type_material_id = p_type_material_id
                WHERE
                    c.id = ANY(p_courses)
                GROUP BY
                    c.id, c.name;
            END;
            $$;


ALTER FUNCTION odiseo.fn_total_text_by_courses_levels(p_university_id integer, p_cycle_id integer, p_headquarter_id integer, p_week integer, p_type_material_id integer, p_courses integer[]) OWNER TO postgres;

--
