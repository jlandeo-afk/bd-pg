-- Function: exams.fn_validate_config_exam(integer, integer, integer, jsonb)

--

CREATE FUNCTION exams.fn_validate_config_exam(p_type_material_id integer, p_material_id integer, p_week integer, p_areas_ids jsonb) RETURNS TABLE(area text, detail jsonb)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_cycle_id integer;
    v_university_id integer;
    v_type_exam_id integer;
    v_areas_array integer[];
BEGIN
    SELECT m.cycle_id, m.university_id 
    INTO v_cycle_id, v_university_id
    FROM material m 
    WHERE m.id = p_material_id AND m.fl_status IS TRUE;

    SELECT te.id 
    INTO v_type_exam_id
    FROM type_material tm
    JOIN type_material_template tmt ON tm.type_material_template_id = tmt.id
    JOIN type_exams te ON tmt.type_exam_id = te.id
    WHERE tm.id = p_type_material_id AND tm.fl_status IS TRUE;

    SELECT ARRAY(SELECT jsonb_array_elements_text(p_areas_ids)::int) INTO v_areas_array;

    RETURN QUERY
    WITH cte_typ_material_area AS (
        SELECT tma.id, tma.area_id
        FROM type_material_area tma
        WHERE tma.type_material_id = p_type_material_id
          AND tma.fl_status IS TRUE
          AND tma.area_id = ANY(v_areas_array)
    ),

    cte_type_material_course AS (
        SELECT 
            tmc.id,
            tmc.course_id,
            v.generated_amount AS amount_question,
            v.generated_name AS course_name,
            v.is_text_record,
            s.id AS syllabus_id
        FROM type_material_course tmc
        JOIN course c ON tmc.course_id = c.id
        JOIN syllabus s ON s.course_id = c.id 
            AND s.cycle_id = v_cycle_id 
            AND s.university_id = v_university_id 
            AND s.fl_status IS TRUE
        CROSS JOIN LATERAL (
            VALUES 
                (tmc.amount_question, c.name, FALSE),
                (COALESCE(tmc.amount_text, 0), CONCAT(c.name, ' (Texto)'), TRUE)
        ) AS v(generated_amount, generated_name, is_text_record)
        WHERE tmc.type_material_id = p_type_material_id
          AND tmc.fl_status IS TRUE
          AND (v.is_text_record = FALSE OR c.apply_text = TRUE)
          AND v.generated_amount > 0
    ),

    cte_valid_syllabus_weeks AS (
        SELECT st.syllabus_id, stw.week, FALSE AS is_text_record
        FROM syllabus_topic st
        JOIN syllabus_topic_week stw ON stw.syllabus_topic_id = st.id
        WHERE st.fl_status IS TRUE 
          AND stw.fl_status IS TRUE 
          AND stw.total_questions_amount > 0
          AND st.syllabus_id IN (SELECT syllabus_id FROM cte_type_material_course WHERE is_text_record = FALSE)

        UNION ALL

        SELECT stw.syllabus_id, stw.week, TRUE AS is_text_record
        FROM syllabus_text_weeks stw
        JOIN syllabus_text_distributions std ON std.syllabus_text_week_id = stw.id
        JOIN type_material tm ON tm.id = std.type_material_id
        WHERE stw.fl_status IS TRUE 
          AND std.fl_status IS TRUE 
          AND tm.fl_status IS TRUE 
          AND tm.description <> 'ECO'
          AND stw.syllabus_id IN (SELECT syllabus_id FROM cte_type_material_course WHERE is_text_record = TRUE)
    ),

    cte_config_level_sums AS (
        SELECT
            emcac.exam_area_id,
            emcac.course_id,
            FALSE as config_is_text, 
            COALESCE(SUM(emcacl.amount_question), 0)::INTEGER as total_level_amount
        FROM exam_material_configurations emc
        INNER JOIN exam_material_config_area_courses emcac ON emc.id = emcac.exam_material_config_id
        INNER JOIN exam_material_config_area_course_levels emcacl ON emcac.id = emcacl.exam_material_config_area_course_id AND emcacl.fl_status = TRUE
        JOIN course_level cl ON cl.level_id = emcacl.level_id AND cl.course_id = emcac.course_id AND cl.fl_status = true
        WHERE emc.type_material_id = p_type_material_id
            AND emc.fl_status = TRUE
            AND emcac.fl_status = TRUE
            AND emc.cycle_id = v_cycle_id
        GROUP BY emcac.exam_area_id, emcac.course_id

        UNION ALL

        SELECT 
            ttemc.area_id, ttemc.course_id,
            TRUE as config_is_text, 
            COALESCE(SUM(ttemc.text_amount), 0)::INTEGER as total_level_amount 
        FROM exam_material_configurations emc
        INNER JOIN type_text_exam_material_configuration ttemc ON emc.id = ttemc.exam_material_config_id
        WHERE emc.type_material_id = p_type_material_id
            AND emc.fl_status = TRUE
            AND ttemc.deleted_at IS NULL
            AND emc.cycle_id = v_cycle_id
        GROUP BY ttemc.area_id, ttemc.course_id
    ),

    cte_periods AS (
        SELECT 
            ROW_NUMBER() OVER (ORDER BY starting_week) AS period_number,
            starting_week AS start_week,
            ending_week   AS end_week
        FROM fn_get_periods_weeks_on_type_material(p_type_material_id::bigint, p_week::smallint)
        WHERE ending_week <= p_week
          AND v_type_exam_id = 3
    ),

    type_material_area_course_relation AS (
        SELECT DISTINCT
            tma.area_id::INTEGER,
            tmc.course_id::INTEGER,
            tmc.course_name::VARCHAR,
            tmc.amount_question::INTEGER, 
            tmc.is_text_record,
            COALESCE(cls.total_level_amount, 0)::INTEGER as amount_level_question,

            CASE 
                WHEN v_type_exam_id = 3 THEN COALESCE(p_data.config_syllabus, FALSE)
                WHEN v_type_exam_id = 2 THEN 
                    EXISTS (
                        SELECT 1 FROM cte_valid_syllabus_weeks vw 
                        WHERE vw.syllabus_id = tmc.syllabus_id 
                          AND vw.is_text_record = tmc.is_text_record
                          AND vw.week = p_week
                    )
                WHEN v_type_exam_id = 4 THEN 
                    EXISTS (
                        SELECT 1 FROM cte_valid_syllabus_weeks vw 
                        WHERE vw.syllabus_id = tmc.syllabus_id 
                          AND vw.is_text_record = tmc.is_text_record
                    )
                ELSE FALSE 
            END AS config_syllabus,

            CASE 
                WHEN v_type_exam_id = 3 THEN p_data.period_detail
                ELSE NULL
            END AS period_detail

        FROM type_material_area_courses tmac
        JOIN cte_typ_material_area tma ON tma.id = tmac.type_material_area_id
        JOIN cte_type_material_course tmc ON tmc.id = tmac.type_material_course_id
        LEFT JOIN cte_config_level_sums cls 
            ON cls.exam_area_id = tma.area_id 
            AND cls.course_id = tmc.course_id
            AND cls.config_is_text = tmc.is_text_record
        
        LEFT JOIN LATERAL (
            SELECT 
                BOOL_AND(p.has_data) AS config_syllabus,
                jsonb_agg(
                    jsonb_build_object(
                        'period', p.period_number,
                        'start_week', p.start_week,
                        'end_week', p.end_week,
                        'has_data', p.has_data
                    ) ORDER BY p.period_number
                ) AS period_detail
            FROM (
                SELECT 
                    cp.period_number, cp.start_week, cp.end_week,
                    EXISTS (
                        SELECT 1 FROM cte_valid_syllabus_weeks vw 
                        WHERE vw.syllabus_id = tmc.syllabus_id 
                          AND vw.is_text_record = tmc.is_text_record
                          AND vw.week BETWEEN cp.start_week AND cp.end_week
                    ) AS has_data
                FROM cte_periods cp
            ) p
        ) p_data ON v_type_exam_id = 3
        
        WHERE tmac.fl_status = TRUE
    )

    SELECT
        a.description::TEXT as area,
        jsonb_agg(
            jsonb_build_object(
                'course', tmacr.course_name,
                'config_syllabus', tmacr.config_syllabus,
                'config_level', tmacr.amount_level_question,
                'config_type_material', tmacr.amount_question,
                'period_detail', tmacr.period_detail
            ) ORDER BY tmacr.course_id, tmacr.is_text_record
        ) as detail
    FROM type_material_area_course_relation tmacr
    JOIN exam_area a ON a.id = tmacr.area_id 
    GROUP BY a.id, a.description;

END;
$$;


ALTER FUNCTION exams.fn_validate_config_exam(p_type_material_id integer, p_material_id integer, p_week integer, p_areas_ids jsonb) OWNER TO postgres;

--
