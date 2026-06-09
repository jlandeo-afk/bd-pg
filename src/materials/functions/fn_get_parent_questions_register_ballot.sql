-- Function: materials.fn_get_parent_questions_register_ballot(bigint, smallint, smallint, smallint)

--

CREATE FUNCTION materials.fn_get_parent_questions_register_ballot(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint) RETURNS TABLE(subquestion jsonb, parent_id bigint, category_id bigint, category character varying, subcategory_id bigint, subcategory character varying, level_id bigint, course_id smallint, history jsonb, code character varying)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                    WITH get_config_syllabus AS ( -- Se trae la configuración de sílabos
                        SELECT
                            DISTINCT
                            csrb.category_id,
                            csrb.subcategory_id,
                            csrb.course_id
                        FROM fn_get_config_text_syllabus_register_ballot_period(
                            p_material_id,
                            p_type_material_id,
                            p_start_week,
                            p_end_week
                        ) csrb
                    ),
                    get_config_level AS ( -- Se trae la configuración de niveles
                        SELECT
                            DISTINCT
                            clrb.level_id,
                            clrb.course_id
                        FROM fn_get_config_text_level_register_ballot_period(
                            p_material_id,
                            p_type_material_id,
                            p_start_week,
                            p_end_week
                        ) clrb
                    ), limit_config_level AS ( -- Obtener los intervalos de niveles
                        SELECT 
                            dwtm.limit_lower_question,
                            dwtm.limit_upper_question 
                        FROM detail_week_type_mat dwtm
                        JOIN type_material tm on tm.id = dwtm.type_material_id 
                        WHERE dwtm.material_id = p_material_id
                        AND (tm.parent_id = p_type_material_id OR tm.id = p_type_material_id)
                        AND dwtm.fl_status = TRUE
                        AND dwtm.week BETWEEN p_start_week AND p_end_week
                        ORDER BY dwtm.id
                        LIMIT 1
                    ), course_ranges_by_level AS (
                        SELECT 
                            gcl.course_id,
                            MIN(gcl.level_id) as min_existing_level,
                            MAX(gcl.level_id) as max_existing_level
                        FROM get_config_level gcl
                        GROUP BY gcl.course_id
                    ), get_config_level_with_range AS (
                        SELECT
                            cr.course_id,
                            generate_series(
                                cr.min_existing_level - lcl.limit_lower_question,
                                cr.max_existing_level + lcl.limit_upper_question
                            ) AS level_id
                        FROM
                            course_ranges_by_level cr,
                            limit_config_level lcl
                        ORDER BY
                            cr.course_id,
                            level_id
                    )
                    SELECT -- Se obtienen los textos filtrados segun las configuraciones
                        fpqvm.subquestion,
                        fpqvm.parent_id,
                        fpqvm.category_id,
                        fpqvm.category,
                        fpqvm.subcategory_id,
                        fpqvm.subcategory,
                        fpqvm.level_id,
                        fpqvm.course_id,
                        fpqvm.history,
                        fpqvm.code
                    FROM fn_parent_question_verified_material(p_material_id, 'T') fpqvm
                    JOIN get_config_syllabus gcs ON
                        gcs.course_id = fpqvm.course_id AND
                        gcs.category_id = fpqvm.category_id AND
                        gcs.subcategory_id = fpqvm.subcategory_id
                    JOIN get_config_level_with_range gclwr ON
                        gclwr.course_id = fpqvm.course_id AND
                        gclwr.level_id = fpqvm.level_id;
            END;
        $$;


ALTER FUNCTION materials.fn_get_parent_questions_register_ballot(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint) OWNER TO postgres;

--
