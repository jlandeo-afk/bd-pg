-- Function: materials.fn_get_material_inconsistency_status(smallint, bigint, smallint, bigint)

--

CREATE FUNCTION materials.fn_get_material_inconsistency_status(p_headquarter_id smallint, p_cycle_id bigint, p_university_id smallint, p_company_id bigint) RETURNS text
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
                            WHERE c.id = p_cycle_id
                            AND tm.fl_exam = false
                            AND tm.fl_status = true
                            AND (
                                tm.parent_id IS NOT NULL
                                OR tm.id NOT IN (
                                    SELECT sub_tm.parent_id 
                                    FROM type_material sub_tm 
                                    WHERE sub_tm.cycle_id = tm.cycle_id 
                                    AND sub_tm.parent_id IS NOT NULL
                                )
                            )
                        ) INTO v_has_expected;

                        IF NOT v_has_expected THEN
                            RETURN 'without-type-material';
                        END IF;

                        SELECT EXISTS (
                            WITH expected_raw AS (
                                SELECT 
                                    tmc.course_id, tmdt.week, tm.id AS material_type_id, 'P'::text AS type,
                                    SUM(CASE WHEN tmc.is_generic = true THEN tmc.amount_question ELSE COALESCE(tmdc.amount_question, 0) END) AS amount
                                FROM type_material tm
                                JOIN cycle c ON c.id = tm.cycle_id AND c.id = p_cycle_id
                                JOIN type_material_detail_template tmdt ON tmdt.type_material_id = tm.id AND tmdt.fl_status = true
                                JOIN type_material_course tmc ON tmc.type_material_id = tm.id
                                LEFT JOIN type_material_detail_courses tmdc ON tmdc.type_material_course_id = tmc.id AND tmdc.type_material_detail_template_id = tmdt.id
                                WHERE tm.fl_exam = false AND tm.fl_status = true
                                AND (tm.parent_id IS NOT NULL OR tm.id NOT IN (SELECT sub_tm.parent_id FROM type_material sub_tm WHERE sub_tm.cycle_id = tm.cycle_id AND sub_tm.parent_id IS NOT NULL))
                                GROUP BY tmc.course_id, tmdt.week, tm.id
                                HAVING SUM(CASE WHEN tmc.is_generic = true THEN tmc.amount_question ELSE COALESCE(tmdc.amount_question, 0) END) > 0
                                
                                UNION ALL
                                
                                SELECT 
                                    tmc.course_id, tmdt.week, tm.id AS material_type_id, 'T'::text AS type,
                                    SUM(CASE WHEN tmc.is_generic_text = true THEN tmc.amount_text ELSE COALESCE(tmdct.amount_text, 0) END) AS amount
                                FROM type_material tm
                                JOIN cycle c ON c.id = tm.cycle_id AND c.id = p_cycle_id
                                JOIN type_material_detail_template tmdt ON tmdt.type_material_id = tm.id AND tmdt.fl_status = true
                                JOIN type_material_course tmc ON tmc.type_material_id = tm.id
                                LEFT JOIN type_material_detail_course_texts tmdct ON tmdct.type_material_course_id = tmc.id AND tmdct.type_material_detail_template_id = tmdt.id
                                WHERE tm.fl_exam = false AND tm.fl_status = true
                                AND (tm.parent_id IS NOT NULL OR tm.id NOT IN (SELECT sub_tm.parent_id FROM type_material sub_tm WHERE sub_tm.cycle_id = tm.cycle_id AND sub_tm.parent_id IS NOT NULL))
                                GROUP BY tmc.course_id, tmdt.week, tm.id
                                HAVING SUM(CASE WHEN tmc.is_generic_text = true THEN tmc.amount_text ELSE COALESCE(tmdct.amount_text, 0) END) > 0
                            ),
                            actual_levels AS (
                                SELECT ls.course_id, lsw.week, dlsw.type_material_id, 'P'::text AS type, SUM(COALESCE(dlsw.number_questions, 0)) AS actual_amount
                                FROM level_syllabus ls
                                JOIN level_syllabus_weeks lsw ON lsw.level_syllabus_id = ls.id AND lsw.fl_status = true
                                JOIN detail_level_syllabus_weeks dlsw ON dlsw.level_syllabus_weeks_id = lsw.id AND dlsw.fl_status = true AND dlsw.deleted_at IS NULL
                                WHERE ls.fl_status = true AND ls.deleted_at IS NULL
                                AND ls.headquarter_id = p_headquarter_id AND ls.cycle_id = p_cycle_id AND ls.university_id = p_university_id AND ls.company_id = p_company_id
                                AND COALESCE(dlsw.number_questions, 0) > 0
                                GROUP BY ls.course_id, lsw.week, dlsw.type_material_id
                                
                                UNION ALL
                                
                                SELECT ls.course_id, lsw.week, dlswp.type_material_id, 'T'::text AS type, SUM(COALESCE(dlswp.number_of_passages, 0)) AS actual_amount
                                FROM level_syllabus ls
                                JOIN level_syllabus_weeks lsw ON lsw.level_syllabus_id = ls.id AND lsw.fl_status = true
                                JOIN detail_level_syllabus_weeks_parents dlswp ON dlswp.level_syllabus_weeks_id = lsw.id AND dlswp.fl_status = true AND dlswp.deleted_at IS NULL
                                WHERE ls.fl_status = true AND ls.deleted_at IS NULL
                                AND ls.headquarter_id = p_headquarter_id AND ls.cycle_id = p_cycle_id AND ls.university_id = p_university_id AND ls.company_id = p_company_id
                                AND COALESCE(dlswp.number_of_passages, 0) > 0
                                GROUP BY ls.course_id, lsw.week, dlswp.type_material_id
                            ),
                            actual_syllabus AS (
                                SELECT s.course_id, stw.week, sstm.type_material_id, 'P'::text AS type, SUM(sstm.questions_amount) AS actual_amount
                                FROM syllabus s
                                JOIN syllabus_topic st ON st.syllabus_id = s.id 
                                JOIN syllabus_topic_week stw ON stw.syllabus_topic_id = st.id AND stw.fl_status = true
                                JOIN syllabus_detail_subtopic sds ON sds.syllabus_topic_week_id = stw.id AND sds.fl_status = true
                                JOIN syllabus_subtopic_type_material sstm ON sstm.syllabus_detail_subtopic_id = sds.id
                                WHERE s.fl_status = true AND s.deleted_at IS NULL AND sstm.fl_status = true AND sstm.deleted_at IS NULL 
                                AND s.cycle_id = p_cycle_id AND s.university_id = p_university_id AND s.company_id = p_company_id
                                GROUP BY s.course_id, stw.week, sstm.type_material_id
                                
                                UNION ALL
                                
                                SELECT s.course_id, stw.week, std.type_material_id, 'T'::text AS type, COUNT(stx.id) AS actual_amount
                                FROM syllabus s 
                                JOIN syllabus_text_weeks stw ON stw.syllabus_id = s.id AND stw.fl_status = true
                                JOIN syllabus_text_distributions std ON std.syllabus_text_week_id = stw.id AND std.fl_status = true
                                JOIN syllabus_texts stx ON stx.syllabus_text_distribution_id = std.id AND stx.fl_status = true
                                WHERE s.fl_status = true AND s.deleted_at IS NULL
                                AND s.cycle_id = p_cycle_id AND s.university_id = p_university_id AND s.company_id = p_company_id
                                GROUP BY s.course_id, stw.week, std.type_material_id
                            )
                            -- LA COMPARACIÓN FINAL
                            SELECT 1
                            FROM expected_raw e
                            LEFT JOIN actual_levels al ON e.course_id = al.course_id AND e.week = al.week AND e.material_type_id = al.type_material_id AND e.type = al.type
                            LEFT JOIN actual_syllabus sy ON e.course_id = sy.course_id AND e.week = sy.week AND e.material_type_id = sy.type_material_id AND e.type = sy.type
                            WHERE e.amount != COALESCE(al.actual_amount, 0)
                            OR e.amount != COALESCE(sy.actual_amount, 0)
                        ) INTO v_has_error;

                        IF v_has_error THEN
                            RETURN 'with-observations';
                        ELSE
                            RETURN 'without-observations';
                        END IF;
                    END;
                    $$;


ALTER FUNCTION materials.fn_get_material_inconsistency_status(p_headquarter_id smallint, p_cycle_id bigint, p_university_id smallint, p_company_id bigint) OWNER TO postgres;

--
