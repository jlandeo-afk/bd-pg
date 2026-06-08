-- Function: odiseo.fn_get_material_configuration_inconsistencies(bigint, bigint, bigint, bigint, smallint, smallint, jsonb)

--

CREATE FUNCTION odiseo.fn_get_material_configuration_inconsistencies(p_headquarter_id bigint, p_cycle_id bigint, p_university_id bigint, p_company_id bigint, p_week smallint DEFAULT NULL::smallint, p_type_material_id smallint DEFAULT NULL::smallint, p_courses jsonb DEFAULT NULL::jsonb) RETURNS TABLE(level_id bigint, syllabus_id bigint, headquarter_id smallint, headquarter character varying, course_id smallint, course_name character varying, cycle_id bigint, cycle_description character varying, university_id smallint, company_id bigint, week_number smallint, type_material_id smallint, type_material_name character varying, record_type text, expected_amount integer, levels_actual_amount integer, syllabus_actual_amount integer, has_levels_mismatch boolean, has_syllabus_mismatch boolean, has_inconsistencies boolean, has_configuration boolean, has_levels_configuration boolean, has_syllabus_configuration boolean)
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                        RETURN QUERY
                        WITH request_info AS (
                            SELECT
                                c.id AS cycle_id,
                                c.description AS cycle_description,
                                c.weeks AS total_weeks,
                                (SELECT h.name FROM headquarters h WHERE h.id = p_headquarter_id) AS headquarter
                            FROM cycle c
                            WHERE c.id = p_cycle_id
                        ),
                        expected_raw AS (
                            SELECT
                                tmc.course_id,
                                c2.name AS course_name,
                                tmdt.week,
                                tm.id AS material_type_id,
                                tmt."name" AS type_material_name,
                                SUM(CASE WHEN tmc.is_generic = true THEN tmc.amount_question ELSE COALESCE(tmdc.amount_question, 0) END) AS total_question,
                                SUM(CASE WHEN tmc.is_generic_text = true THEN tmc.amount_text ELSE COALESCE(tmdct.amount_text, 0) END) AS total_text
                            FROM type_material tm
                            JOIN type_material_detail_template tmdt ON tmdt.type_material_id = tm.id AND tmdt.fl_status = true
                            JOIN type_material_template tmt ON tmt.id = tm.type_material_template_id
                            JOIN type_material_course tmc ON tmc.type_material_id = tm.id
                            LEFT JOIN type_material_detail_courses tmdc ON tmdc.type_material_course_id = tmc.id AND tmdc.type_material_detail_template_id = tmdt.id
                            LEFT JOIN type_material_detail_course_texts tmdct ON tmdct.type_material_course_id = tmc.id AND tmdct.type_material_detail_template_id = tmdt.id
                            JOIN course c2 ON c2.id = tmc.course_id
                            JOIN request_info r ON r.cycle_id = tm.cycle_id
                            WHERE tm.fl_exam = false AND tm.fl_status = true
                            AND (p_week IS NULL OR tmdt.week = p_week)
                            AND (
                                tm.parent_id IS NOT NULL
                                OR
                                tm.id NOT IN (
                                        SELECT sub_tm.parent_id
                                        FROM type_material sub_tm
                                        WHERE sub_tm.cycle_id = tm.cycle_id
                                        AND sub_tm.parent_id IS NOT NULL
                                    )
                            )
                            GROUP BY tmc.course_id, c2.name, tmdt.week, tm.id, tmt.name
                        ),
                        syllabus_ids AS (
                            SELECT DISTINCT
                                s.id AS syllabus_id,
                                s.cycle_id,
                                s.course_id,
                                s.university_id,
                                s.company_id
                            FROM syllabus s
                            WHERE fl_status = true AND deleted_at IS NULL
                            AND s.cycle_id = p_cycle_id AND s.university_id = p_university_id AND s.company_id = p_company_id
                        ),
                        expected AS (
                            SELECT
                                expected_raw.course_id,
                                expected_raw.course_name,
                                expected_raw.week,
                                expected_raw.material_type_id,
                                expected_raw.type_material_name,
                                'P'::text AS type,
                                expected_raw.total_question AS expected_amount
                            FROM expected_raw WHERE expected_raw.total_question > 0
                            UNION ALL
                            SELECT
                                expected_raw.course_id,
                                expected_raw.course_name,
                                expected_raw.week,
                                expected_raw.material_type_id,
                                expected_raw.type_material_name,
                                'T'::text AS type,
                                expected_raw.total_text AS expected_amount
                            FROM expected_raw WHERE expected_raw.total_text > 0
                        ),
                        active_levels AS (
                            SELECT
                                ls.id AS level_syllabus_id,
                                ls.course_id
                            FROM level_syllabus ls
                            WHERE 1 = 1
                            AND ls.cycle_id = p_cycle_id
                            AND ls.headquarter_id = p_headquarter_id
                            AND ls.university_id = p_university_id
                            AND ls.company_id = p_company_id
                            AND ls.fl_status = true
                            AND ls.deleted_at IS NULL
                        ),
                        actual_materials AS (
                            SELECT
                                detail_level_syllabus_weeks.level_syllabus_weeks_id,
                                detail_level_syllabus_weeks.type_material_id,
                                'P'::text AS type,
                                COALESCE(detail_level_syllabus_weeks.number_questions, 0) AS actual_amount
                            FROM detail_level_syllabus_weeks
                            WHERE 1 = 1
                            AND detail_level_syllabus_weeks.fl_status = true
                            AND detail_level_syllabus_weeks.deleted_at IS NULL
                            AND COALESCE(detail_level_syllabus_weeks.number_questions, 0) > 0

                            UNION ALL

                            SELECT
                                detail_level_syllabus_weeks_parents.level_syllabus_weeks_id,
                                detail_level_syllabus_weeks_parents.type_material_id,
                                'T'::text AS type,
                                COALESCE(detail_level_syllabus_weeks_parents.number_of_passages, 0) AS actual_amount
                            FROM detail_level_syllabus_weeks_parents
                            WHERE 1 = 1
                            AND detail_level_syllabus_weeks_parents.fl_status = true
                            AND detail_level_syllabus_weeks_parents.deleted_at IS NULL
                            AND COALESCE(detail_level_syllabus_weeks_parents.number_of_passages, 0) > 0
                        ),
                        actual_levels_agg AS (
                            SELECT
                                al.course_id,
                                lsw.week,
                                am.type_material_id,
                                am.type, SUM(am.actual_amount) AS actual_amount
                            FROM active_levels al
                            JOIN level_syllabus_weeks lsw ON lsw.level_syllabus_id = al.level_syllabus_id
                            JOIN actual_materials am ON am.level_syllabus_weeks_id = lsw.id
                            WHERE lsw.fl_status = true
                            AND (p_week IS NULL OR lsw.week = p_week)
                            GROUP BY al.course_id, lsw.week, am.type_material_id, am.type
                        ),
                        actual_syllabus_materials AS (
                            SELECT
                                s.course_id,
                                stw.week,
                                sstm.type_material_id,
                                'P'::text AS type,
                                SUM(sstm.questions_amount) AS total
                            FROM syllabus s
                            JOIN syllabus_topic st ON st.syllabus_id = s.id
                            JOIN syllabus_topic_week stw ON stw.syllabus_topic_id = st.id AND stw.fl_status = true
                            JOIN syllabus_detail_subtopic sds ON sds.syllabus_topic_week_id = stw.id AND sds.fl_status = true
                            JOIN syllabus_subtopic_type_material sstm ON sstm.syllabus_detail_subtopic_id = sds.id
                            WHERE 1 = 1
                            AND s.cycle_id = p_cycle_id
                            AND s.university_id = p_university_id
                            AND s.company_id = p_company_id
                            AND s.fl_status = true
                            AND s.deleted_at IS NULL
                            AND sstm.fl_status = true
                            AND sstm.deleted_at IS NULL
                            AND (p_week IS NULL OR stw.week = p_week)
                            GROUP BY s.course_id, stw.week, sstm.type_material_id

                            UNION ALL

                            SELECT
                                s.course_id,
                                stw.week,
                                std.type_material_id,
                                'T'::text AS type,
                                COUNT(stx.id) AS total
                            FROM syllabus s
                            JOIN syllabus_text_weeks stw ON stw.syllabus_id = s.id AND stw.fl_status = true
                            JOIN syllabus_text_distributions std ON std.syllabus_text_week_id = stw.id AND std.fl_status = true
                            JOIN syllabus_texts stx ON stx.syllabus_text_distribution_id = std.id AND stx.fl_status = true
                            WHERE 1 = 1
                            AND s.cycle_id = p_cycle_id
                            AND s.university_id = p_university_id
                            AND s.company_id = p_company_id
                            AND s.fl_status = true
                            AND s.deleted_at IS NULL
                            AND (p_week IS NULL OR stw.week = p_week)
                            GROUP BY s.course_id, stw.week, std.type_material_id
                        ),
                        cycle_active_weeks AS (
                            SELECT DISTINCT
                                cw.week
                            FROM cycle_weeks cw
                            JOIN type_week tw ON tw.id = cw.type_week_id
                            WHERE cw.cycle_id = p_cycle_id
                            AND cw.fl_status = true
                            AND tw.description != 'Inactiva'
                            AND cw.week IS NOT NULL
                            AND (p_week IS NULL OR cw.week = p_week)
                        ),
                        all_course_types AS (
                            SELECT DISTINCT
                                tmc.course_id,
                                c2.name AS course_name,
                                tm.id AS material_type_id,
                                tmt."name" AS type_material_name
                            FROM type_material tm
                            JOIN type_material_template tmt ON tmt.id = tm.type_material_template_id
                            JOIN type_material_course tmc ON tmc.type_material_id = tm.id
                            JOIN course c2 ON c2.id = tmc.course_id
                            WHERE tm.cycle_id = p_cycle_id
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
                            AND (p_type_material_id IS NULL OR tm.id = p_type_material_id)
                            AND (p_courses IS NULL OR tmc.course_id IN (SELECT value::smallint FROM jsonb_array_elements_text(p_courses)))
                        ),
                        all_week_course_combinations AS (
                            SELECT
                                caw.week,
                                act.course_id,
                                act.course_name,
                                act.material_type_id,
                                act.type_material_name
                            FROM cycle_active_weeks caw
                            CROSS JOIN all_course_types act
                        )
                        SELECT
                            al.level_syllabus_id AS level_id,
                            sids.syllabus_id,
                            p_headquarter_id::smallint AS headquarter_id,
                            r.headquarter,
                            COALESCE(e.course_id, awcc.course_id)::smallint AS course_id,
                            COALESCE(e.course_name, awcc.course_name)::varchar AS course_name,
                            p_cycle_id AS cycle_id,
                            r.cycle_description::varchar,
                            p_university_id::smallint AS university_id,
                            p_company_id AS company_id,
                            COALESCE(e.week, awcc.week)::smallint AS week_number,
                            COALESCE(e.material_type_id, awcc.material_type_id) AS type_material_id,
                            COALESCE(e.type_material_name, awcc.type_material_name)::varchar AS type_material_name,
                            COALESCE(e.type, 'P')::text AS record_type,
                            COALESCE(e.expected_amount, 0)::integer AS expected_amount,
                            COALESCE(ala.actual_amount, 0)::integer AS levels_actual_amount,
                            COALESCE(sy.total, 0)::integer AS syllabus_actual_amount,
                            (COALESCE(e.expected_amount, 0) != COALESCE(ala.actual_amount, 0)) AS has_levels_mismatch,
                            (COALESCE(e.expected_amount, 0) != COALESCE(sy.total, 0)) AS has_syllabus_mismatch,
                            (COALESCE(e.expected_amount, 0) != COALESCE(ala.actual_amount, 0) OR COALESCE(e.expected_amount, 0) != COALESCE(sy.total, 0)) AS has_inconsistencies,
                            (e.expected_amount IS NOT NULL) AS has_configuration,
                            (ala.actual_amount IS NOT NULL) AS has_levels_configuration,
                            (sy.total IS NOT NULL) AS has_syllabus_configuration
                        FROM all_week_course_combinations awcc
                        LEFT JOIN expected e
                            ON awcc.course_id = e.course_id AND awcc.week = e.week AND awcc.material_type_id = e.material_type_id
                        LEFT JOIN actual_levels_agg ala
                            ON COALESCE(e.course_id, awcc.course_id) = ala.course_id
                            AND COALESCE(e.week, awcc.week) = ala.week
                            AND COALESCE(e.material_type_id, awcc.material_type_id) = ala.type_material_id
                            AND COALESCE(e.type, 'P') = ala.type
                        LEFT JOIN actual_syllabus_materials sy
                            ON COALESCE(e.course_id, awcc.course_id) = sy.course_id
                            AND COALESCE(e.week, awcc.week) = sy.week
                            AND COALESCE(e.material_type_id, awcc.material_type_id) = sy.type_material_id
                            AND COALESCE(e.type, 'P') = sy.type
                        LEFT JOIN syllabus_ids sids
                            ON sids.course_id = COALESCE(e.course_id, awcc.course_id)
                        LEFT JOIN active_levels al
                            ON al.course_id = COALESCE(e.course_id, awcc.course_id)
                        CROSS JOIN request_info r
                        WHERE 1 = 1
                        AND (p_type_material_id IS NULL OR COALESCE(e.material_type_id, awcc.material_type_id) = p_type_material_id)
                        AND (
                            p_courses IS NULL
                            OR COALESCE(e.course_id, awcc.course_id) IN (SELECT value::smallint FROM jsonb_array_elements_text(p_courses))
                        )
                        AND (COALESCE(e.expected_amount, 0) != COALESCE(ala.actual_amount, 0) OR COALESCE(e.expected_amount, 0) != COALESCE(sy.total, 0))
                        ORDER BY COALESCE(e.week, awcc.week), COALESCE(e.course_id, awcc.course_id);
                    END;
                    $$;


ALTER FUNCTION odiseo.fn_get_material_configuration_inconsistencies(p_headquarter_id bigint, p_cycle_id bigint, p_university_id bigint, p_company_id bigint, p_week smallint, p_type_material_id smallint, p_courses jsonb) OWNER TO postgres;

--
