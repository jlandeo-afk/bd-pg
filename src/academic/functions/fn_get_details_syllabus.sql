-- Function: academic.fn_get_details_syllabus(jsonb, integer)

--

CREATE FUNCTION academic.fn_get_details_syllabus(p_course_ids jsonb, p_cycle_id integer) RETURNS TABLE(course_id smallint, course_name character varying, cycle_id smallint, cycle_description character varying, weeks smallint, detail_type_material jsonb, course_levels jsonb)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH filtered_courses AS (
        SELECT c.id AS course_id, c."name" AS course_name
        FROM course c
        WHERE c.id IN (SELECT value::INT FROM jsonb_array_elements_text(p_course_ids))
          AND c.fl_status = TRUE
          AND c.deleted_at IS NULL
    ),
    cycle_details AS (
        SELECT 
            c.id AS cycle_id, 
            c.description AS cycle_description, 
            MAX(cw.week) AS weeks
        FROM "cycle" c
        INNER JOIN "cycle_weeks" cw ON cw.cycle_id = c.id
        WHERE c.id = p_cycle_id 
        group by c.id
    ),
    course_materials AS (
        SELECT
            tmc.course_id,
            JSONB_AGG(
                JSONB_BUILD_OBJECT(
                    'type_material_id', tm.id,
                    'type_material', tm.description,
                    'total_question', COALESCE(tmc.amount_question, 0)
                )
            ) AS detail_type_material
        FROM type_material tm
        JOIN type_material_course tmc ON tmc.type_material_id = tm.id
        WHERE tm.cycle_id = p_cycle_id
          AND tm.fl_status = TRUE
          AND tm.deleted_at IS NULL
          AND tm.fl_exam = FALSE
          AND tmc.course_id IN (SELECT fc.course_id FROM filtered_courses fc)
        GROUP BY tmc.course_id
    ),
    course_levels_agg AS (
        SELECT
            cl.course_id,
            JSONB_AGG(
                JSONB_BUILD_OBJECT(
                    'level_id', l.id,
                    'level_name', l."name",
                    'level_description', l.description
                )
            ) AS course_levels
        FROM course_level cl
        JOIN "level" l ON cl.level_id = l.id
        WHERE cl.fl_status = TRUE
          AND cl.deleted_at IS NULL
          AND l.fl_status = TRUE
          AND l.deleted_at IS NULL
          AND cl.course_id IN (SELECT fc.course_id FROM filtered_courses fc)
        GROUP BY cl.course_id
    )
    SELECT
        fc.course_id::SMALLINT,
        fc.course_name,
        cd.cycle_id::SMALLINT,
        cd.cycle_description,
        cd.weeks::SMALLINT,
        COALESCE(cm.detail_type_material, '[]'::JSONB),
        COALESCE(cla.course_levels, '[]'::JSONB)
    FROM filtered_courses fc
    CROSS JOIN cycle_details cd
    LEFT JOIN course_materials cm ON cm.course_id = fc.course_id
    LEFT JOIN course_levels_agg cla ON cla.course_id = fc.course_id;
END;
$$;


ALTER FUNCTION academic.fn_get_details_syllabus(p_course_ids jsonb, p_cycle_id integer) OWNER TO postgres;

--
