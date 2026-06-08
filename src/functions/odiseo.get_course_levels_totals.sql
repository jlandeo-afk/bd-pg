-- Function: odiseo.get_course_levels_totals(integer, integer, integer, integer, integer)

--

CREATE FUNCTION odiseo.get_course_levels_totals(p_cycle_id integer, p_week integer, p_type_material_id integer, p_university_id integer, p_headquarter_id integer) RETURNS TABLE(course_id bigint, levels_total numeric)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    ls.course_id,
                    (
                        SUM(COALESCE(dlsw.number_questions, 0))::NUMERIC
                        /
                        NULLIF(COUNT(DISTINCT ls.headquarter_id), 0)
                    ) AS levels_total
                FROM
                    detail_level_syllabus_weeks dlsw
                JOIN level_syllabus_weeks lsw ON lsw.id = dlsw.level_syllabus_weeks_id
                JOIN level_syllabus ls ON ls.id = lsw.level_syllabus_id
                WHERE
                    ls.cycle_id = p_cycle_id
                    AND ls.university_id = p_university_id
                    AND ls.headquarter_id = p_headquarter_id
                    AND lsw.week = p_week
                    AND dlsw.type_material_id = p_type_material_id
                    AND dlsw.fl_status = TRUE
                    AND ls.fl_status = TRUE
                    AND ls.deleted_at IS NULL
                    AND lsw.deleted_at IS NULL
                    AND dlsw.deleted_at IS NULL
                GROUP BY
                    ls.course_id;
            END;
            $$;


ALTER FUNCTION odiseo.get_course_levels_totals(p_cycle_id integer, p_week integer, p_type_material_id integer, p_university_id integer, p_headquarter_id integer) OWNER TO postgres;

--
