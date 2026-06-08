-- Function: odiseo.fn_get_parent_questions_missing_ballot(bigint, smallint, smallint, smallint, boolean, integer)

--

CREATE FUNCTION odiseo.fn_get_parent_questions_missing_ballot(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint, p_has_permission_filter_per_course boolean, p_employee_id integer) RETURNS TABLE(subquestion jsonb, parent_id bigint, category_id bigint, category character varying, subcategory_id bigint, subcategory character varying, level_id bigint, course_id smallint, history jsonb, code character varying, registered boolean)
    LANGUAGE plpgsql
    AS $$
                DECLARE
                    v_ids_children INT[];
                    v_course_ids INT[];
                BEGIN
                    /*
                        ------------------------------------------------------------------------------------
                        -- HISTORIAL DE CAMBIOS
                        ------------------------------------------------------------------------------------
                        Versión: 1.1
                        Fecha: 2025-11-28
                        Autor: Junior Alcarraz
                        Descripción:
                            Trae preguntas texto de la distribucion de un rango por periodo
                            Se modifica para que traiga preguntas que esten registradas
                    */

                    -- Obtener todos los IDs de los hijos en un array
                    SELECT CASE
                        WHEN EXISTS (SELECT 1 FROM type_material tm WHERE tm.parent_id = p_type_material_id)
                        THEN ARRAY(SELECT tm.id FROM type_material tm WHERE tm.parent_id = p_type_material_id)
                        ELSE ARRAY[p_type_material_id]
                    END INTO v_ids_children;

                    IF p_has_permission_filter_per_course THEN
                        SELECT array_agg(DISTINCT ec.course_id) INTO v_course_ids
                        FROM employee_course ec
                        WHERE ec.teacher_id = p_employee_id
                        AND ec.deleted_by IS NULL
                        AND ec.fl_status = true;
                    END IF;

                    RETURN QUERY
                    WITH get_type_materias AS ( -- Se trae el id de tipo material hijo si los tiene, sino se manda el normal
                        SELECT unnest(v_ids_children) AS type_material_id
                    ), get_config_syllabus AS ( -- Se trae la configuración de sílabos
                        SELECT
                            DISTINCT
                            csrb.category_id,
                            csrb.subcategory_id,
                            csrb.course_id
                        FROM fn_get_config_text_syllabus_complete_ballot_period(
                            p_material_id,
                            p_type_material_id,
                            p_start_week,
                            p_end_week
                        ) csrb
                    ), get_config_level AS ( -- Se trae la configuración de niveles
                        SELECT
                            DISTINCT
                            clrb.level_id,
                            clrb.course_id
                        FROM fn_get_config_text_level_complete_ballot_period(
                            p_material_id,
                            p_type_material_id,
                            p_start_week,
                            p_end_week
                        ) clrb
                    ), get_courses_missing_ballot AS (
                        SELECT DISTINCT
                            mdbq.course_id,
                            mdbq.type_text_id AS category_id,
                            mdbq.type_text_subcategory_id AS subcategory_id,
                            mdbq.level_id
                        FROM detail_week_type_mat dwtm
                        JOIN material_ballot_question mdbq ON dwtm.id = mdbq.week_type_material_id
                        WHERE mdbq.material_id = p_material_id
                            AND dwtm.week BETWEEN p_start_week AND p_end_week
                            AND dwtm.type_material_id IN (SELECT gtm.type_material_id FROM get_type_materias gtm)
                            AND mdbq.fl_status = true
                            AND mdbq.parent_question_id IS NULL
                            AND mdbq.type_text_id IS NOT NULL
                            AND (NOT p_has_permission_filter_per_course OR mdbq.course_id = ANY(v_course_ids))
                    ), get_subcategories_search AS (
                        SELECT
                            gcs.course_id,
                            gcs.category_id,
                            gcs.subcategory_id
                        FROM get_config_syllabus gcs
                        UNION ALL
                        SELECT DISTINCT
                            gcmb.course_id,
                            gcmb.category_id,
                            gcmb.subcategory_id
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
                    ), limit_config_level AS ( -- Obtener los intervalos de niveles
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
                    ), subtopics_agg AS (
                        SELECT
                            qs.question_id,
                            JSONB_AGG(JSONB_BUILD_OBJECT('id', qs.subtopic_id)) AS subtopics_json
                        FROM question_subtopic qs
                        WHERE qs.fl_status = true
                        GROUP BY qs.question_id
                    ), get_questions_text_search AS (-- Se obtienen los textos filtrados segun las configuraciones
                        SELECT
                            fpqvm.subquestion,
                            fpqvm.parent_id,
                            fpqvm.category_id,
                            fpqvm.category,
                            fpqvm.subcategory_id,
                            fpqvm.subcategory,
                            fpqvm.level_id,
                            fpqvm.course_id,
                            fpqvm.history,
                            fpqvm.code,
                            FALSE AS registered
                        FROM fn_parent_question_verified_material(p_material_id, 'T') fpqvm
                        JOIN get_subcategories_search gss ON gss.course_id = fpqvm.course_id
                            AND gss.category_id = fpqvm.category_id
                            AND gss.subcategory_id = fpqvm.subcategory_id
                        JOIN get_config_level_with_range gclwr ON gclwr.course_id = fpqvm.course_id
                        AND gclwr.level_id = fpqvm.level_id
                    ), get_questions_register AS (
                        SELECT
                            JSONB_AGG(
                                JSONB_BUILD_OBJECT(
                                    'code', q.code,
                                    'question_id', q.id,
                                    'topic_id', q.topic_id,
                                    'course_id', q.course_id,
                                    'level_id', q.level_id,
                                    'subtopics', COALESCE(sa.subtopics_json, '[]'::jsonb)
                                )
                            ) AS subquestion,
                            mdbq.parent_question_id::BIGINT,
                            mdbq.type_text_id AS category_id,
                            tt.name AS category,
                            mdbq.type_text_subcategory_id AS subcategory_id,
                            tts.name AS subcategory,
                            mdbq.level_id,
                            mdbq.course_id,
                            '[]'::JSONB AS history,
                            pq.code,
                            TRUE AS registered
                        FROM material_ballot_question mdbq
                        JOIN question q ON q.parent_id = mdbq.parent_question_id
                        JOIN parent_question pq ON pq.id = mdbq.parent_question_id
                        JOIN detail_week_type_mat dwtm ON mdbq.week_type_material_id = dwtm.id
                        JOIN type_text tt ON mdbq.type_text_id = tt.id
                        JOIN type_text_subcategories tts ON mdbq.type_text_subcategory_id = tts.id
                        JOIN level l ON mdbq.level_id = l.id
                        LEFT JOIN subtopics_agg sa ON q.id = sa.question_id
                        WHERE 1 = 1
                            AND dwtm.fl_status IS TRUE
                            AND mdbq.fl_status IS TRUE
                            AND dwtm.material_id = p_material_id
                            AND dwtm.type_material_id IN (SELECT gtm.type_material_id FROM get_type_materias gtm)
                            AND mdbq.parent_question_id IS NOT NULL
                            AND mdbq.type_text_id IS NOT NULL
                        GROUP BY
                            mdbq.parent_question_id,
                            pq.code,
                            mdbq.type_text_id,
                            tt.name,
                            mdbq.type_text_subcategory_id,
                            tts.name,
                            mdbq.level_id,
                            mdbq.course_id
                    )
                    SELECT * FROM get_questions_text_search
                    UNION ALL
                    SELECT * FROM get_questions_register;
                END;
                $$;


ALTER FUNCTION odiseo.fn_get_parent_questions_missing_ballot(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint, p_has_permission_filter_per_course boolean, p_employee_id integer) OWNER TO postgres;

--
