-- Function: odiseo.fn_get_exam_configuration_inconsistencies(bigint, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_get_exam_configuration_inconsistencies(p_cycle_id bigint, p_university_id bigint, p_company_id bigint) RETURNS TABLE(type_material_id smallint, type_material_name character varying, syllabus_id bigint, area_id smallint, area_name character varying, course_id smallint, course_name character varying, cycle_id bigint, university_id bigint, company_id bigint, cycle_description character varying, exam_week smallint, record_type text, is_text_record boolean, expected_amount integer, actual_level_amount integer, has_level_mismatch boolean, has_syllabus_mismatch boolean, has_inconsistencies boolean, period_detail jsonb)
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                        RETURN QUERY
                        WITH request_info AS (
                            SELECT c.id AS cycle_id, c.description AS cycle_description
                            FROM cycle c 
                            WHERE c.id = p_cycle_id
                        )
                        , expected_raw AS (
                            SELECT
                                tma.area_id::smallint, ea.description AS area_name,
                                tm.id::smallint AS type_material_id, tmt.name AS type_material_name,
                                tmt.type_exam_id, te.name type_exam,
                                tmc.course_id::smallint, c.name AS course_name,
                                v.is_text_record, v.type_str, v.expected_amount,
                                s.id AS syllabus_id
                            FROM type_material tm
                            JOIN request_info ri ON tm.cycle_id = ri.cycle_id
                            JOIN type_material_template tmt ON tmt.id = tm.type_material_template_id
                            JOIN type_exams te ON te.id = tmt.type_exam_id 
                            JOIN type_material_area tma ON tma.type_material_id = tm.id
                            JOIN exam_area ea ON ea.id = tma.area_id
                            JOIN type_material_area_courses tmac ON tmac.type_material_area_id = tma.id
                            JOIN type_material_course tmc ON tmc.id = tmac.type_material_course_id AND tmc.type_material_id = tm.id
                            JOIN course c ON c.id = tmc.course_id
                            LEFT JOIN syllabus s ON s.course_id = c.id AND s.cycle_id = p_cycle_id AND s.university_id = p_university_id AND s.company_id = p_company_id AND s.fl_status = true
                            CROSS JOIN LATERAL (
                                VALUES
                                    (FALSE, 'P'::text, tmc.amount_question),
                                    (TRUE, 'T'::text, COALESCE(tmc.amount_text, 0))
                            ) AS v(is_text_record, type_str, expected_amount)
                            WHERE tm.fl_exam = true AND tm.fl_status = true AND tma.fl_status = true AND tmc.fl_status = true AND tmac.fl_status = true
                            AND (v.is_text_record = FALSE OR c.apply_text = TRUE)
                            AND v.expected_amount > 0
                        )
                        , materials_type_2 AS (
                            SELECT DISTINCT er.type_material_id 
                            FROM expected_raw er
                            WHERE er.type_exam = 'Tipo 2'
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
                            SELECT ampr.type_material_id, ampr.eval_week, 2::smallint AS period_number, 1::smallint AS starting_week,
                                (ampr.current_starting_week - 1)::smallint AS ending_week
                            FROM all_materials_periods_raw ampr
                            WHERE ampr.week_order > 1 -- Evita crear el periodo duplicado en la semana 1
                        )
                        , actual_levels AS (
                            SELECT emcac.exam_area_id::smallint AS area_id, emc.type_material_id::smallint, emcac.course_id::smallint, FALSE AS is_text_record, COALESCE(SUM(emcacl.amount_question), 0)::INTEGER AS level_amount
                            FROM exam_material_configurations emc
                            JOIN exam_material_config_area_courses emcac ON emc.id = emcac.exam_material_config_id
                            JOIN exam_material_config_area_course_levels emcacl ON emcac.id = emcacl.exam_material_config_area_course_id AND emcacl.fl_status = true
                            JOIN course_level cl ON cl.level_id = emcacl.level_id AND cl.course_id = emcac.course_id AND cl.fl_status = true
                            WHERE emc.fl_status = true AND emcac.fl_status = true AND emc.cycle_id = p_cycle_id
                            GROUP BY emcac.exam_area_id, emc.type_material_id, emcac.course_id
                            UNION ALL
                            SELECT ttemc.area_id::smallint, emc.type_material_id::smallint, ttemc.course_id::smallint, TRUE AS is_text_record, COALESCE(SUM(ttemc.text_amount), 0)::INTEGER AS level_amount
                            FROM exam_material_configurations emc
                            JOIN type_text_exam_material_configuration ttemc ON emc.id = ttemc.exam_material_config_id
                            WHERE emc.fl_status = true AND ttemc.deleted_at IS NULL AND emc.cycle_id = p_cycle_id
                            GROUP BY ttemc.area_id, emc.type_material_id, ttemc.course_id
                        ) 
                        , cte_valid_syllabus_weeks AS (
                            SELECT distinct st.syllabus_id, stw.week, FALSE AS is_text_record
                            FROM syllabus_topic st
                            JOIN syllabus s ON s.id = st.syllabus_id 
                            JOIN syllabus_topic_week stw ON stw.syllabus_topic_id = st.id
                            WHERE st.fl_status IS TRUE AND stw.fl_status IS TRUE AND stw.total_questions_amount > 0 AND s.cycle_id = p_cycle_id 
                            UNION ALL
                            SELECT distinct stw.syllabus_id, stw.week, TRUE AS is_text_record
                            FROM syllabus_text_weeks stw
                            JOIN syllabus s ON s.id = stw.syllabus_id 
                            JOIN syllabus_text_distributions std ON std.syllabus_text_week_id = stw.id
                            JOIN type_material tm ON tm.id = std.type_material_id
                            WHERE stw.fl_status IS TRUE AND std.fl_status IS TRUE AND tm.fl_status IS TRUE AND tm.description <> 'ECO' AND s.cycle_id = p_cycle_id 
                        )
                        , syllabus_valid_weeks_agg AS (
                            SELECT cvsw.syllabus_id, cvsw.is_text_record, array_agg(cvsw.week) AS arr_weeks
                            FROM cte_valid_syllabus_weeks cvsw
                            GROUP BY cvsw.syllabus_id, cvsw.is_text_record
                        )
                        , course_type_base AS (
                            SELECT
                                er.area_id, er.area_name, er.type_material_id, er.type_material_name, er.type_exam,
                                er.course_id, er.course_name, er.syllabus_id,
                                er.is_text_record, er.type_str, er.expected_amount,
                                COALESCE(al.level_amount, 0) AS actual_level_amount
                            FROM expected_raw er
                            LEFT JOIN actual_levels al ON al.area_id = er.area_id AND al.type_material_id = er.type_material_id AND al.course_id = er.course_id AND al.is_text_record = er.is_text_record
                        )
                        , periods_evaluation AS (
                            SELECT
                                cb.area_id, cb.area_name, cb.type_material_id, cb.type_material_name, cb.course_id, cb.course_name, cb.syllabus_id,
                                cb.is_text_record, cb.type_str, cb.expected_amount, cb.actual_level_amount,
                                tmdt.week AS exam_week, p.period_number, p.starting_week, p.ending_week,
                                CASE 
                                    WHEN cb.syllabus_id IS NULL OR svw.arr_weeks IS NULL THEN FALSE
                                    WHEN cb.type_exam = 'Tipo 1' THEN tmdt.week = ANY(svw.arr_weeks)
                                    WHEN cb.type_exam = 'Tipo 2' THEN COALESCE((SELECT bool_or(w BETWEEN p.starting_week AND p.ending_week) FROM unnest(svw.arr_weeks) AS w), FALSE)
                                    WHEN cb.type_exam = 'Tipo 3' THEN array_length(svw.arr_weeks, 1) > 0
                                    ELSE FALSE 
                                END AS has_data
                            FROM course_type_base cb
                            JOIN type_material_detail_template tmdt ON tmdt.type_material_id = cb.type_material_id AND tmdt.fl_status = true
                            LEFT JOIN syllabus_valid_weeks_agg svw ON svw.syllabus_id = cb.syllabus_id AND svw.is_text_record = cb.is_text_record
                            LEFT JOIN all_materials_periods_precalculated p ON p.type_material_id = cb.type_material_id AND p.eval_week = tmdt.week AND cb.type_exam = 'Tipo 2'
                        )
                        , flat_week_level_agg AS (
                            SELECT
                                pe.area_id, pe.area_name, pe.type_material_id, pe.type_material_name, pe.course_id, pe.course_name, MAX(pe.syllabus_id) AS syllabus_id,
                                pe.exam_week, pe.type_str, pe.is_text_record, pe.expected_amount, pe.actual_level_amount,
                                bool_or(NOT pe.has_data) AS has_syllabus_mismatch,
                                (pe.expected_amount != pe.actual_level_amount) AS has_level_mismatch,
                                jsonb_agg(
                                    jsonb_build_object(
                                        'period_number', COALESCE(pe.period_number, 1),
                                        'start_week', COALESCE(pe.starting_week, pe.exam_week),
                                        'end_week', COALESCE(pe.ending_week, pe.exam_week),
                                        'has_data', pe.has_data,
                                        'has_error', NOT pe.has_data
                                    ) ORDER BY COALESCE(pe.starting_week, pe.exam_week) ASC
                                ) AS period_detail
                            FROM periods_evaluation pe
                            GROUP BY pe.area_id, pe.area_name, pe.type_material_id, pe.type_material_name, pe.course_id, pe.course_name, pe.exam_week, pe.type_str, pe.is_text_record, pe.expected_amount, pe.actual_level_amount
                        )
                        SELECT
                            fwa.type_material_id,
                            fwa.type_material_name::varchar,
                            fwa.syllabus_id,
                            fwa.area_id, 
                            fwa.area_name::varchar,
                            fwa.course_id, 
                            fwa.course_name::varchar,
                            p_cycle_id AS cycle_id, 
                            p_university_id AS university_id, 
                            p_company_id AS company_id,
                            r.cycle_description::varchar, 
                            fwa.exam_week::smallint,
                            fwa.type_str AS record_type,
                            fwa.is_text_record,
                            fwa.expected_amount,
                            fwa.actual_level_amount,
                            fwa.has_level_mismatch,
                            fwa.has_syllabus_mismatch,
                            (fwa.has_syllabus_mismatch OR fwa.has_level_mismatch) AS has_inconsistencies,
                            fwa.period_detail
                        FROM flat_week_level_agg fwa
                        CROSS JOIN request_info r
                        WHERE fwa.has_syllabus_mismatch = true OR fwa.has_level_mismatch = true
                        ORDER BY fwa.exam_week, fwa.type_material_id, fwa.course_id;
                    END;
                    $$;


ALTER FUNCTION odiseo.fn_get_exam_configuration_inconsistencies(p_cycle_id bigint, p_university_id bigint, p_company_id bigint) OWNER TO postgres;

--
