-- Function: academic.fn_get_level_syllabus_detail(bigint)

--

CREATE FUNCTION academic.fn_get_level_syllabus_detail(p_level_syllabus_id bigint) RETURNS TABLE(cycle_id bigint, code_cycle character varying, name_cycle character varying, university_id smallint, name_university character varying, headquarter_id smallint, name_headquarter character varying, course_id smallint, code_course character varying, name_course character varying, total_weeks smallint, weeks jsonb)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN QUERY
    WITH base_level AS (
        SELECT
            ls.id AS level_syllabus_id,
            c.id AS cycle_id,
            c.code AS code_cycle,
            c.description AS name_cycle,
            ou.id AS university_id,
            ou.name AS name_university,
            h.id AS headquarter_id,
            h.name AS name_headquarter,
            c2.id AS course_id,
            c2.code AS code_course,
            c2.name AS name_course,
            c.weeks AS total_weeks
        FROM level_syllabus ls
        LEFT JOIN cycle c ON ls.cycle_id = c.id
        LEFT JOIN course c2 ON ls.course_id = c2.id
        LEFT JOIN origin_university ou ON ls.university_id = ou.id
        LEFT JOIN headquarters h ON ls.headquarter_id = h.id
        WHERE ls.id = p_level_syllabus_id AND ls.fl_status = TRUE AND ls.deleted_at IS NULL
    ),
    expected_raw AS (
        SELECT 
            tmdt.week,
            tm.id AS material_type_id,
            SUM(CASE WHEN tmc.is_generic = true THEN tmc.amount_question ELSE COALESCE(tmdc.amount_question, 0) END) AS total_question,
            SUM(CASE WHEN tmc.is_generic_text = true THEN tmc.amount_text ELSE COALESCE(tmdct.amount_text, 0) END) AS total_text
        FROM type_material tm
        JOIN type_material_detail_template tmdt ON tmdt.type_material_id = tm.id
        JOIN type_material_template tmt ON tmt.id = tm.type_material_template_id 
        JOIN type_material_course tmc ON tmc.type_material_id = tm.id
        LEFT JOIN type_material_detail_courses tmdc ON tmdc.type_material_course_id = tmc.id AND tmdc.type_material_detail_template_id = tmdt.id
        LEFT JOIN type_material_detail_course_texts tmdct ON tmdct.type_material_course_id = tmc.id AND tmdct.type_material_detail_template_id = tmdt.id
        CROSS JOIN base_level bl
        WHERE tm.cycle_id = bl.cycle_id
        AND tmc.course_id = bl.course_id
        AND tm.fl_exam = false
        AND tm.fl_status = true
        AND (
                tm.parent_id IS NOT NULL
                OR 
                tm.id NOT IN (SELECT parent_id FROM type_material tm2 WHERE tm2.cycle_id = tm.cycle_id  AND parent_id IS NOT NULL)
            )
        GROUP BY tmdt.week, tm.id
    ),
    expected AS (
        SELECT week, material_type_id, 'P' AS type, total_question AS total
        FROM expected_raw 
        UNION ALL
        SELECT week, material_type_id, 'T' AS type, total_text AS total
        FROM expected_raw 
    ),
    actual_materials AS (
        SELECT 
            level_syllabus_weeks_id, 
            type_material_id, 
            'P' AS type, 
            COALESCE(number_questions, 0) AS total
        FROM detail_level_syllabus_weeks
        WHERE fl_status = true AND deleted_at IS NULL AND COALESCE(number_questions, 0) > 0
        
        UNION ALL
        
        SELECT 
            level_syllabus_weeks_id, 
            type_material_id, 
            'T' AS type, 
            COALESCE(number_of_passages, 0) AS total
        FROM detail_level_syllabus_weeks_parents
        WHERE fl_status = true AND deleted_at IS NULL AND COALESCE(number_of_passages, 0) > 0
    ),
    actual AS (
        SELECT 
            lsw.week, 
            am.type_material_id AS material_type_id, 
            am.type,
            SUM(am.total) AS total
        FROM level_syllabus_weeks lsw 
        CROSS JOIN base_level bl
        JOIN actual_materials am ON am.level_syllabus_weeks_id = lsw.id 
        WHERE 
            lsw.level_syllabus_id = bl.level_syllabus_id 
            AND lsw.fl_status = true 
        GROUP BY 
            lsw.id, lsw.week, am.type_material_id, am.type
    ),
    inconsistent_weeks AS (
        SELECT DISTINCT COALESCE(e.week, a.week) AS error_week 
        FROM expected e
        FULL OUTER JOIN actual a 
            ON e.week = a.week 
        AND e.material_type_id = a.material_type_id
        AND e.type = a.type
        WHERE 
            COALESCE(e.total, 0) != COALESCE(a.total, 0)
    ),
    list_weeks AS (
        SELECT 
            bl.level_syllabus_id,
            cw.week AS week_number 
        FROM base_level bl
        JOIN cycle_weeks cw ON cw.cycle_id = bl.cycle_id
        JOIN type_week tw ON cw.type_week_id = tw.id
        WHERE cw.fl_status = true 
          AND cw.deleted_at IS NULL
          AND tw.description != 'Inactiva'
          AND tw.fl_status = true
          AND tw.deleted_at IS NULL
    ),
    weeks_json_build AS (
        SELECT 
            lw.level_syllabus_id,
            jsonb_agg(
                jsonb_build_object(
                    'week', lw.week_number,
                    'name_week', 'Semana ' || lw.week_number,
                    'exist_level_syllabus', CASE WHEN iw.error_week IS NOT NULL THEN false ELSE true END
                ) ORDER BY lw.week_number
            ) AS weeks_array
        FROM list_weeks lw
        LEFT JOIN inconsistent_weeks iw ON lw.week_number = iw.error_week
        GROUP BY lw.level_syllabus_id
    )
    SELECT 
        bl.cycle_id,
        bl.code_cycle,
        bl.name_cycle,
        bl.university_id,
        bl.name_university,
        bl.headquarter_id,
        bl.name_headquarter,
        bl.course_id,
        bl.code_course,
        bl.name_course,
        bl.total_weeks,
        wjb.weeks_array AS weeks
    FROM base_level bl
    LEFT JOIN weeks_json_build wjb ON bl.level_syllabus_id = wjb.level_syllabus_id;
END;
$$;


ALTER FUNCTION academic.fn_get_level_syllabus_detail(p_level_syllabus_id bigint) OWNER TO postgres;

--
