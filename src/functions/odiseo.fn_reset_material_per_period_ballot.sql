-- Function: odiseo.fn_reset_material_per_period_ballot(bigint, smallint, smallint, smallint, boolean, smallint, smallint, bigint)

--

CREATE FUNCTION odiseo.fn_reset_material_per_period_ballot(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint, p_fl_config_type boolean, p_lower_level_limit smallint, p_upper_level_limit smallint, p_created_by bigint) RETURNS TABLE(id bigint, material_per_period_ballot_id bigint, week smallint, cycle_id bigint, start_date date, type_material_id smallint, type_material character varying, exists_per_period boolean, has_questions boolean, parent_type_material_id smallint, fl_exam boolean, courses jsonb, courses_for_text jsonb, university_id smallint, headquarte_id smallint)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                WITH type_material_ids AS (
                    SELECT
                        CASE
                            WHEN EXISTS ( SELECT 1 FROM type_material tmx WHERE tmx.parent_id = p_type_material_id AND tmx.fl_status = true )
                            THEN ARRAY( SELECT tmy.id FROM type_material tmy WHERE tmy.parent_id = p_type_material_id AND tmy.fl_status = true )
                            ELSE ARRAY[p_type_material_id]
                        END AS ids
                ), insert_material_per_period AS (
                    INSERT INTO material_per_period AS plmm ( material_id, type_material_id, created_at, created_by )
                    VALUES( p_material_id, p_type_material_id, NOW(), p_created_by )
                    ON CONFLICT ON CONSTRAINT per_material_and_type_id
                    DO UPDATE
                        SET
                            updated_by = p_created_by,
                            deleted_by = NULL,
                            updated_at = NOW(),
                            deleted_at = NULL
                    RETURNING plmm.id, plmm.updated_at IS NULL AS is_new
                ), insert_material_per_period_ballot AS (
                    INSERT INTO material_per_period_ballot AS mpt(
                        material_per_period_id,
                        start_week,
                        end_week,
                        fl_config_type,
                        lower_level_limit,
                        upper_level_limit,
                        date_completed,
                        user_completed_id,
                        order_date,
                        order_by_user_id,
                        created_by,
                        created_at
                    )
                    VALUES(
                        ( SELECT im.id FROM insert_material_per_period AS im ),
                        p_start_week,
                        p_end_week,
                        p_fl_config_type,
                        p_lower_level_limit,
                        p_upper_level_limit,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        p_created_by,
                        NOW()
                    )
                     ON CONFLICT (material_per_period_id, start_week, end_week) WHERE deleted_at IS NULL
                        DO UPDATE
                            SET
                                fl_config_type = p_fl_config_type,
                                lower_level_limit = p_lower_level_limit,
                                upper_level_limit = p_upper_level_limit,
                                date_completed = NULL,
                                user_completed_id = NULL,
                                order_date = NULL,
                                order_by_user_id = NULL,
                                updated_by = p_created_by,
                                deleted_by = NULL,
                                updated_at = NOW(),
                                deleted_at = NULL
                        RETURNING mpt.id, mpt.updated_at IS NULL AS is_new
                ), remove_overlapping_periods_in_ballot AS (
                    UPDATE material_per_period_ballot mppb
                    SET
                        deleted_by = p_created_by,
                        deleted_at = NOW()
                    WHERE 1 = 1
                    AND mppb.material_per_period_id IN ( SELECT ip.id FROM insert_material_per_period AS ip WHERE is_new IS FALSE )
                    AND ( mppb.start_week BETWEEN p_start_week AND p_end_week OR mppb.end_week BETWEEN p_start_week AND p_end_week )
                    AND NOT ( mppb.start_week = p_start_week AND mppb.end_week = p_end_week )
                    RETURNING mppb.id AS material_period_id
                ), remove_urls_in_overlapping AS (
                    UPDATE material_per_period_ballot_url mbppbu
                        SET
                        deleted_by = p_created_by,
                        deleted_at = NOW()
                    WHERE mbppbu.material_per_period_ballot_id IN ( SELECT rmv.material_period_id FROM remove_overlapping_periods_in_ballot rmv )
                    RETURNING mbppbu.id AS material_period_url_id
                ), remove_class_urls_in_overlapping AS (
                    UPDATE material_per_period_ballot_class class_urls
                        SET
                            deleted_by = p_created_by,
                            deleted_at = NOW()
                    WHERE class_urls.material_per_period_ballot_url_id IN ( SELECT rmu.material_period_url_id FROM remove_urls_in_overlapping rmu )
                ), weeks_in_type_material_ids AS (
                    SELECT
                        tmdt.week,
                        ttm.id AS child_type_material_id,
                        ttm.parent_id AS parent_type_material_id
                    FROM type_material_detail_template tmdt
                    LEFT JOIN (
                        SELECT tm.id, tm.parent_id FROM type_material tm
                        WHERE tm.id IN ( SELECT UNNEST(ids) FROM type_material_ids )
                    ) ttm ON 1 = 1
                    WHERE 1 = 1
                    AND tmdt.type_material_id = p_type_material_id
                    AND tmdt.week BETWEEN p_start_week AND p_end_week
                    AND tmdt.fl_status = true
                    ORDER BY tmdt.week ASC, ttm.id ASC
                ), insert_or_update_detail_week_type AS (
                    INSERT INTO detail_week_type_mat AS dwtm (
                        material_id,
                        week,
                        type_material_id,
                        parent_type_material_id,
                        fl_config_type,
                        limit_lower_question,
                        limit_upper_question,
                        created_by,
                        created_at
                    )
                    SELECT
                        p_material_id,
                        wt.week,
                        wt.child_type_material_id,
                        wt.parent_type_material_id,
                        p_fl_config_type,
                        p_lower_level_limit,
                        p_upper_level_limit,
                        p_created_by,
                        NOW()
                    FROM weeks_in_type_material_ids wt
                    ON CONFLICT ON CONSTRAINT ux_detail_week_type_mat
                    DO UPDATE
                        SET
                            parent_type_material_id = EXCLUDED.parent_type_material_id,
                            fl_config_type = EXCLUDED.fl_config_type,
                            limit_lower_question = EXCLUDED.limit_lower_question,
                            limit_upper_question = EXCLUDED.limit_upper_question,
                            updated_by = p_created_by,
                            updated_at = NOW(),
                            fl_status = TRUE,
                            deleted_by = NULL,
                            deleted_at = NULL
                    RETURNING
                        dwtm.id,
                        dwtm.week,
                        dwtm.type_material_id,
                        dwtm.parent_type_material_id,
                        dwtm.data_incomplete_questions IS NOT NULL AS incomplete_questions,
                        dwtm.data_missing_course_config IS NOT NULL AS incomplete_course_config,
                        dwtm.data_missing_text IS NOT NULL AS incomplete_missing_text,
                        dwtm.updated_at IS NULL AS is_new
                ), incomplete_fields_in_material_per_period AS (
                    UPDATE material_per_period_ballot mb
                        SET
                            date_completed = NULL,
                            user_completed_id = NULL,
                            order_date = NULL,
                            order_by_user_id = NULL,
                            fl_missing_questions = EXISTS( SELECT 1 FROM insert_or_update_detail_week_type WHERE incomplete_questions IS TRUE ),
                            fl_missing_courses = EXISTS( SELECT 1 FROM insert_or_update_detail_week_type WHERE incomplete_course_config IS TRUE ),
                            fl_missing_text = EXISTS( SELECT 1 FROM insert_or_update_detail_week_type WHERE incomplete_missing_text IS TRUE )
                    WHERE mb.id IN ( SELECT pp.id FROM insert_material_per_period_ballot AS pp )
                ), get_courses_generic AS (
                    SELECT DISTINCT
                        tmc.course_id,
                        tmc.type_material_id
                    FROM type_material_course tmc
                    WHERE tmc.type_material_id IN (SELECT UNNEST(ids) FROM type_material_ids)
                        AND tmc.is_generic = true
                        AND tmc.fl_status = true
                        AND tmc.amount_question > 0
                ), get_courses_text_generic AS (
                    SELECT DISTINCT
                        tmc.course_id,
                        tmc.type_material_id
                    FROM type_material_course tmc
                    WHERE tmc.type_material_id IN (SELECT UNNEST(ids) FROM type_material_ids)
                        AND tmc.is_generic_text = true
                        AND tmc.amount_text > 0
                        AND tmc.fl_status = true
                ), get_courses_not_generic AS (
                    SELECT DISTINCT
                        tmc.course_id,
                        tm.id AS type_material_id
                    FROM odiseo.type_material tm
                    JOIN odiseo.type_material_detail_template tmdt ON tmdt.type_material_id = tm.id
                        AND tmdt.fl_status = true
                    JOIN odiseo.type_material_course tmc ON tmc.type_material_id = tm.id
                    LEFT JOIN odiseo.type_material_detail_courses tmdc ON tmdc.type_material_course_id = tmc.id
                        AND tmdc.type_material_detail_template_id = tmdt.id
                    WHERE tm.id IN (SELECT UNNEST(ids) FROM type_material_ids)
                        AND tmc.is_generic = false
                        AND tmdt.week BETWEEN p_start_week AND p_end_week
                        AND tmdc.amount_question > 0
                ), get_courses_text_not_generic AS (
                    SELECT DISTINCT
                        tmc.course_id,
                        tm.id AS type_material_id
                    FROM odiseo.type_material tm
                    JOIN odiseo.type_material_detail_template tmdt ON tmdt.type_material_id = tm.id
                        AND tmdt.fl_status = true
                    JOIN odiseo.type_material_course tmc ON tmc.type_material_id = tm.id
                    LEFT JOIN odiseo.type_material_detail_course_texts tmdct ON tmdct.type_material_course_id = tmc.id
                        AND tmdct.type_material_detail_template_id = tmdt.id
                    WHERE tm.id IN (SELECT UNNEST(ids) FROM type_material_ids)
                        AND tmc.is_generic_text = false
                        AND tmdt.week BETWEEN p_start_week AND p_end_week
                        AND tmdct.amount_text > 0
                ), get_courses AS (
                    SELECT
                        gcg.course_id,
                        gcg.type_material_id
                    FROM get_courses_generic gcg
                    UNION ALL
                    SELECT
                        gcng.course_id,
                        gcng.type_material_id
                    FROM get_courses_not_generic gcng
                ), get_courses_text AS (
                    SELECT
                        gcg.course_id,
                        gcg.type_material_id
                    FROM get_courses_text_generic gcg
                    UNION ALL
                    SELECT
                        gcng.course_id,
                        gcng.type_material_id
                    FROM get_courses_text_not_generic gcng
                )
                SELECT
                    io.id,
                    ( SELECT z.id FROM insert_material_per_period_ballot AS z ) AS material_per_period_ballot_id,
                    io.week,
                    m.cycle_id,
                    c.start_date,
                    io.type_material_id,
                    tm.description AS type_material,
                    FALSE AS exists_per_period,
                    FALSE AS has_questions,
                    io.parent_type_material_id,
                    FALSE AS fl_exam,
                    COALESCE((
                        SELECT jsonb_agg(gc.course_id ORDER BY gc.course_id ASC)
                        FROM get_courses gc
                        WHERE gc.type_material_id = io.type_material_id
                    ), '[]'::JSONB) AS courses,
                    COALESCE((
                        SELECT jsonb_agg(gc.course_id ORDER BY gc.course_id ASC)
                        FROM get_courses_text gc
                        WHERE gc.type_material_id = io.type_material_id
                    ), '[]'::JSONB) AS courses_for_text,
                    m.university_id,
                    m.headquarte_id
                FROM insert_or_update_detail_week_type io
                LEFT JOIN material m ON m.id = p_material_id
                LEFT JOIN type_material tm ON io.type_material_id = tm.id
                LEFT JOIN cycle c ON c.id = m.cycle_id
                ORDER BY LEFT(tm.description, 1);
            END;
            $$;


ALTER FUNCTION odiseo.fn_reset_material_per_period_ballot(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint, p_fl_config_type boolean, p_lower_level_limit smallint, p_upper_level_limit smallint, p_created_by bigint) OWNER TO postgres;

--
