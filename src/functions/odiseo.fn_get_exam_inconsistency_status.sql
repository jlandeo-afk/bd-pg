-- Function: odiseo.fn_get_exam_inconsistency_status(bigint, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_get_exam_inconsistency_status(p_cycle_id bigint, p_university_id bigint, p_company_id bigint) RETURNS text
    LANGUAGE plpgsql
    AS $$
                    DECLARE
                        v_has_expected boolean;
                        v_has_error boolean;
                    BEGIN
                        SELECT EXISTS (
                            SELECT 1
                            FROM type_material tm
                            JOIN cycle c ON c.id = tm.cycle_id
                            WHERE c.id = p_cycle_id AND tm.fl_exam = true AND tm.fl_status = true
                        ) INTO v_has_expected;

                        IF NOT v_has_expected THEN
                            RETURN 'without-type-material';
                        END IF;

                        SELECT EXISTS (
                            WITH request_info AS (
                                SELECT c.id AS cycle_id
                                FROM cycle c WHERE c.id = p_cycle_id
                            )
                            , expected_raw AS (
                                SELECT
                                    tma.area_id::smallint, tm.id::smallint AS type_material_id,
                                    tmt.type_exam_id, te.name type_exam,
                                    tmc.course_id::smallint, s.id AS syllabus_id,
                                    v.is_text_record, v.expected_amount
                                FROM type_material tm
                                JOIN request_info ri ON tm.cycle_id = ri.cycle_id
                                JOIN type_material_template tmt ON tmt.id = tm.type_material_template_id
                                JOIN type_exams te ON te.id = tmt.type_exam_id 
                                JOIN type_material_area tma ON tma.type_material_id = tm.id
                                JOIN type_material_area_courses tmac ON tmac.type_material_area_id = tma.id
                                JOIN type_material_course tmc ON tmc.id = tmac.type_material_course_id AND tmc.type_material_id = tm.id
                                JOIN course c ON c.id = tmc.course_id
                                LEFT JOIN syllabus s ON s.course_id = c.id AND s.cycle_id = p_cycle_id AND s.university_id = p_university_id AND s.company_id = p_company_id AND s.fl_status = true
                                CROSS JOIN LATERAL (
                                    VALUES
                                        (FALSE, tmc.amount_question),
                                        (TRUE, COALESCE(tmc.amount_text, 0))
                                ) AS v(is_text_record, expected_amount)
                                WHERE tm.fl_exam = true AND tm.fl_status = true AND tma.fl_status = true AND tmc.fl_status = true AND tmac.fl_status = true
                                AND (v.is_text_record = FALSE OR c.apply_text = TRUE)
                                AND v.expected_amount > 0
                            )
                            , materials_type_2 AS (
                                SELECT DISTINCT er.type_material_id FROM expected_raw er WHERE er.type_exam = 'Tipo 2'
                            )
                            , base_template_weeks AS (
                                SELECT tmdt.type_material_id, tmdt.week
                                FROM type_material_detail_template tmdt
                                JOIN materials_type_2 mt2 ON tmdt.type_material_id = mt2.type_material_id
                                WHERE tmdt.fl_status IS TRUE
                            )
                            , all_materials_periods_raw AS (
                                SELECT
                                    btw.type_material_id, btw.week AS eval_week,
                                    (COALESCE(LAG(btw.week) OVER (PARTITION BY btw.type_material_id ORDER BY btw.week), 0) + 1)::smallint AS current_starting_week,
                                    btw.week::smallint AS current_ending_week,
                                    (ROW_NUMBER() OVER (PARTITION BY btw.type_material_id ORDER BY btw.week))::smallint AS week_order
                                FROM base_template_weeks btw
                            ) 
                            , all_materials_periods_precalculated AS (
                                SELECT ampr.type_material_id, ampr.eval_week, 1::smallint AS period_number, ampr.current_starting_week AS starting_week, ampr.current_ending_week AS ending_week
                                FROM all_materials_periods_raw ampr
                                UNION ALL
                                SELECT ampr.type_material_id, ampr.eval_week, 2::smallint AS period_number, 1::smallint AS starting_week, (ampr.current_starting_week - 1)::smallint AS ending_week
                                FROM all_materials_periods_raw ampr WHERE ampr.week_order > 1
                            )
                            , actual_levels AS (
                                SELECT emcac.exam_area_id::smallint AS area_id, emc.type_material_id::smallint, emcac.course_id::smallint, FALSE AS is_text_record, COALESCE(SUM(emcacl.amount_question), 0)::INTEGER AS level_amount
                                FROM exam_material_configurations emc
                                JOIN exam_material_config_area_courses emcac ON emc.id = emcac.exam_material_config_id
                                JOIN exam_material_config_area_course_levels emcacl ON emcac.id = emcacl.exam_material_config_area_course_id AND emcacl.fl_status = true
                                JOIN course_level cl ON cl.level_id = emcacl.level_id AND cl.course_id = emcac.course_id AND cl.fl_status = true
                                WHERE emc.fl_status = true AND emcac.fl_status = true AND emc.cycle_id = p_cycle_id  AND emc.company_id = p_company_id
                                GROUP BY emcac.exam_area_id, emc.type_material_id, emcac.course_id
                                UNION ALL
                                SELECT ttemc.area_id::smallint, emc.type_material_id::smallint, ttemc.course_id::smallint, TRUE AS is_text_record, COALESCE(SUM(ttemc.text_amount), 0)::INTEGER AS level_amount
                                FROM exam_material_configurations emc
                                JOIN type_text_exam_material_configuration ttemc ON emc.id = ttemc.exam_material_config_id
                                WHERE emc.fl_status = true AND ttemc.deleted_at IS NULL AND emc.cycle_id = p_cycle_id  AND emc.company_id = p_company_id
                                GROUP BY ttemc.area_id, emc.type_material_id, ttemc.course_id
                            ) 
                            , cte_valid_syllabus_weeks AS (
                                SELECT distinct st.syllabus_id, stw.week, FALSE AS is_text_record
                                FROM syllabus_topic st
                                JOIN syllabus s ON s.id = st.syllabus_id 
                                JOIN syllabus_topic_week stw ON stw.syllabus_topic_id = st.id
                                WHERE st.fl_status IS TRUE AND stw.fl_status IS TRUE AND stw.total_questions_amount > 0 AND s.cycle_id = p_cycle_id AND s.university_id = p_university_id AND s.company_id = p_company_id
                                UNION ALL
                                SELECT distinct stw.syllabus_id, stw.week, TRUE AS is_text_record
                                FROM syllabus_text_weeks stw
                                JOIN syllabus s ON s.id = stw.syllabus_id 
                                JOIN syllabus_text_distributions std ON std.syllabus_text_week_id = stw.id
                                JOIN type_material tm ON tm.id = std.type_material_id
                                WHERE stw.fl_status IS TRUE AND std.fl_status IS TRUE AND tm.fl_status IS TRUE AND tm.description <> 'ECO' AND s.cycle_id = p_cycle_id AND s.university_id = p_university_id AND s.company_id = p_company_id
                            )
                            , syllabus_valid_weeks_agg AS (
                                SELECT cvsw.syllabus_id, cvsw.is_text_record, array_agg(cvsw.week) AS arr_weeks
                                FROM cte_valid_syllabus_weeks cvsw
                                GROUP BY cvsw.syllabus_id, cvsw.is_text_record
                            )
                            SELECT 1
                            FROM expected_raw er
                            JOIN type_material_detail_template tmdt ON tmdt.type_material_id = er.type_material_id AND tmdt.fl_status = true
                            LEFT JOIN actual_levels al ON al.area_id = er.area_id AND al.type_material_id = er.type_material_id AND al.course_id = er.course_id AND al.is_text_record = er.is_text_record
                            LEFT JOIN syllabus_valid_weeks_agg svw ON svw.syllabus_id = er.syllabus_id AND svw.is_text_record = er.is_text_record
                            LEFT JOIN all_materials_periods_precalculated p ON p.type_material_id = er.type_material_id AND p.eval_week = tmdt.week AND er.type_exam = 'Tipo 2'
                            WHERE 
                                (er.expected_amount != COALESCE(al.level_amount, 0))
                                OR 
                                (
                                    CASE 
                                        WHEN er.syllabus_id IS NULL OR svw.arr_weeks IS NULL THEN FALSE
                                        WHEN er.type_exam = 'Tipo 1' THEN tmdt.week = ANY(svw.arr_weeks)
                                        WHEN er.type_exam = 'Tipo 2' THEN COALESCE((SELECT bool_or(w BETWEEN p.starting_week AND p.ending_week) FROM unnest(svw.arr_weeks) AS w), FALSE)
                                        WHEN er.type_exam = 'Tipo 3' THEN array_length(svw.arr_weeks, 1) > 0
                                        ELSE FALSE 
                                    END
                                ) = FALSE 
                        ) INTO v_has_error;

                        IF v_has_error THEN
                            RETURN 'with-observations';
                        ELSE
                            RETURN 'without-observations';
                        END IF;
                    END;
                    $$;


ALTER FUNCTION odiseo.fn_get_exam_inconsistency_status(p_cycle_id bigint, p_university_id bigint, p_company_id bigint) OWNER TO postgres;

--
