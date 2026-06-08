-- Function: odiseo.fn_get_questions_missing_ballot(bigint, boolean, smallint, smallint, smallint, boolean, integer)

--

CREATE FUNCTION odiseo.fn_get_questions_missing_ballot(p_material_id bigint, p_fl_validate_code boolean, p_type_material_id smallint, p_start_week smallint, p_end_week smallint, p_has_permission_filter_per_course boolean, p_employee_id integer) RETURNS TABLE(id bigint, code character varying, course_id smallint, topic_id smallint, level_id smallint, level smallint, type character varying, status character varying, subtopic_id integer, frequent_subtopic boolean, cycle_id integer, week smallint, type_material_id smallint, history jsonb)
    LANGUAGE plpgsql
    AS $$
                DECLARE
                    v_course_ids INT[];
                BEGIN
                    /*
                        ------------------------------------------------------------------------------------
                        -- HISTORIAL DE CAMBIOS
                        ------------------------------------------------------------------------------------
                        Versión: 1.0
                        Fecha: 2025-10-28
                        Autor: Junior Alcarraz
                        Descripción:
                            Trae preguntas de la distribucion de un rango por periodo
                    */

                    IF p_has_permission_filter_per_course THEN
                        SELECT array_agg(DISTINCT ec.course_id) INTO v_course_ids
                        FROM employee_course ec
                        WHERE ec.teacher_id = p_employee_id
                        AND ec.deleted_by IS NULL
                        AND ec.fl_status = true;
                    END IF;

                    RETURN QUERY
                    WITH type_materias AS (
                        SELECT
                            CASE
                                WHEN EXISTS ( SELECT 1 FROM type_material tmx WHERE tmx.parent_id = p_type_material_id )
                                THEN ARRAY( SELECT tmy.id FROM type_material tmy WHERE tmy.parent_id = p_type_material_id )
                                ELSE ARRAY[p_type_material_id]
                            END AS ids
                    ), get_type_materias AS ( -- Se trae el id de tipo material hijo si los tiene, sino se manda el normal
                        SELECT unnest(tm.ids) AS type_material_id FROM type_materias tm
                    ), get_config_syllabus AS ( -- Se trae la configuración de niveles
                        SELECT
                            csrb.subtopic_id,
                            csrb.course_id
                        FROM fn_get_config_syllabus_complete_ballot_period(
                            p_material_id,
                            p_type_material_id,
                            p_start_week,
                            p_end_week
                        ) csrb
                    ), get_config_level AS ( -- Se trae la configuración de niveles
                        SELECT
                            clrb.level_id,
                            clrb.course_id
                        FROM fn_get_config_level_complete_ballot_period(
                            p_material_id,
                            p_type_material_id,
                            p_start_week,
                            p_end_week
                        ) clrb
                    ), get_courses_missing_ballot AS (
                        SELECT DISTINCT
                            mdbq.course_id,
                            mdbq.subtopic_id,
                            mdbq.level_id
                        FROM detail_week_type_mat dwtm
                        JOIN material_ballot_question mdbq ON dwtm.id = mdbq.week_type_material_id
                        WHERE mdbq.material_id = p_material_id
                            AND dwtm.week BETWEEN p_start_week AND p_end_week
                            AND dwtm.type_material_id IN (SELECT gtm.type_material_id FROM get_type_materias gtm)
                            AND mdbq.fl_status = true
                            AND mdbq.question_id IS NULL
                            AND mdbq.type_text_id IS NULL
                    ), get_subtopics_search AS (
                        SELECT
                            gcs.course_id,
                            gcs.subtopic_id
                        FROM get_config_syllabus gcs
                        UNION ALL
                        SELECT DISTINCT
                            gcmb.course_id,
                            gcmb.subtopic_id
                        FROM get_courses_missing_ballot gcmb
                    ), get_levels_search AS (
                        SELECT
                            gcl.course_id,
                            gcl.level_id
                        FROM get_config_level gcl
                        UNION ALL
                        SELECT DISTINCT
                            gcmb.course_id,
                            gcmb.level_id
                        FROM get_courses_missing_ballot gcmb
                    ), limit_config_level AS (
                        SELECT
                            mppb.lower_level_limit,
                            mppb.upper_level_limit
                        FROM material_per_period mpp
                        INNER JOIN material_per_period_ballot mppb ON mpp.id = mppb.material_per_period_id
                            AND mppb.deleted_by IS NULL
                        WHERE mpp.material_id = p_material_id
                            AND mpp.type_material_id = p_type_material_id
                            AND mppb.start_week = p_start_week
                            AND mppb.end_week = p_end_week
                    ), course_ranges_by_level AS (
                        SELECT
                            gls.course_id,
                            MIN(gls.level_id) as min_existing_level,
                            MAX(gls.level_id) as max_existing_level
                        FROM get_levels_search gls
                        GROUP BY gls.course_id
                    ), get_config_level_with_range AS (
                        SELECT
                            cr.course_id,
                            generate_series(
                                cr.min_existing_level - lcl.lower_level_limit,
                                cr.max_existing_level + lcl.upper_level_limit
                            ) AS level_id
                        FROM
                            course_ranges_by_level cr,
                            limit_config_level lcl
                        ORDER BY
                            cr.course_id,
                            level_id
                    )
                    SELECT
                        fqvm.id,
                        fqvm.code,
                        fqvm.course_id,
                        fqvm.topic_id,
                        fqvm.level_id,
                        fqvm.level,
                        fqvm.type,
                        fqvm.status,
                        fqvm.subtopic_id,
                        fqvm.frequent_subtopic,
                        fqvm.cycle_id,
                        fqvm.week,
                        fqvm.type_material_id,
                        fqvm.history
                    FROM fn_question_verified_material(p_material_id, p_fl_validate_code) fqvm
                    JOIN get_subtopics_search gss ON fqvm.course_id = gss.course_id
                        AND fqvm.subtopic_id = gss.subtopic_id
                    JOIN get_config_level_with_range gclwr ON fqvm.course_id = gclwr.course_id
                        AND fqvm.level_id = gclwr.level_id
                    WHERE 1 = 1
                    AND (p_has_permission_filter_per_course = false OR fqvm.course_id = ANY(v_course_ids))
                    ORDER BY fqvm.id DESC, fqvm.topic_id ASC, fqvm.subtopic_id ASC;
                END;
                $$;


ALTER FUNCTION odiseo.fn_get_questions_missing_ballot(p_material_id bigint, p_fl_validate_code boolean, p_type_material_id smallint, p_start_week smallint, p_end_week smallint, p_has_permission_filter_per_course boolean, p_employee_id integer) OWNER TO postgres;

--
