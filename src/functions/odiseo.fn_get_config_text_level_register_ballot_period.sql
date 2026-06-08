-- Function: odiseo.fn_get_config_text_level_register_ballot_period(bigint, smallint, smallint, smallint)

--

CREATE FUNCTION odiseo.fn_get_config_text_level_register_ballot_period(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint) RETURNS TABLE(number_of_passages integer, level_id bigint, level_name character varying, description character varying, course_id bigint, week smallint, type_material_id bigint)
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    RETURN QUERY
                    WITH type_materials AS (
                        SELECT CASE
                            WHEN EXISTS (SELECT 1 FROM type_material tm WHERE tm.parent_id = p_type_material_id)
                            THEN ARRAY(SELECT tm.id FROM type_material tm WHERE tm.parent_id = p_type_material_id)
                            ELSE ARRAY[p_type_material_id]
                        END v_ids_children
                    ), tbl_material AS ( -- Se obtiene el ciclo y universidad del material
                        SELECT
                            m.cycle_id,
                            m.university_id
                        FROM material m
                        WHERE m.id = p_material_id
                    ), get_type_materias AS ( -- Se trae el id de tipo material hijo si los tiene, sino se manda el normal
                        SELECT unnest(tm.v_ids_children) AS type_material_id FROM type_materials tm
                    ), get_type_material_courses_generic AS ( -- Se trae los cursos de tipo material
                        SELECT
                            tmc.type_material_id,
                            tmc.course_id
                        FROM type_material_course tmc
                        WHERE tmc.type_material_id IN (SELECT gtm.type_material_id FROM get_type_materias gtm)
                            AND tmc.amount_text > 0
                            AND tmc.is_generic_text IS TRUE
                            AND tmc.fl_status = true
                    ), get_type_material_courses_not_generic AS (
                        SELECT DISTINCT
                            tmc.type_material_id,
                            tmc.course_id
                        FROM type_material_course tmc
                        JOIN type_material_detail_template tmdt ON tmc.type_material_id = tmdt.type_material_id
                            AND tmdt.fl_status = true
                        JOIN odiseo.type_material_detail_course_texts tmdc ON tmc.id = tmdc.type_material_course_id
                            AND tmdt.id = tmdc.type_material_detail_template_id
                            AND tmdc.fl_status = true
                        WHERE tmc.type_material_id IN (SELECT gtm.type_material_id FROM get_type_materias gtm)
                            AND tmdc.amount_text > 0
                            AND tmc.is_generic_text IS FALSE
                            AND tmc.fl_status = true
                            AND tmdt.week BETWEEN p_start_week AND p_end_week
                    ), get_type_material_courses AS (
                        SELECT * FROM get_type_material_courses_generic
                        UNION
                        SELECT * FROM get_type_material_courses_not_generic
                    ), get_type_material_week AS ( -- Se trae las semanas del tipo material
                        SELECT
                            tmdt.week
                        FROM type_material_detail_template tmdt
                        WHERE tmdt.type_material_id = p_type_material_id
                            AND tmdt.week BETWEEN p_start_week AND p_end_week
                            AND tmdt.fl_status = true
                        ORDER BY tmdt.week ASC
                    )
                    SELECT
                        dlswp.number_of_passages,
                        dlswp.level_id,
                        l.name level_name,
                        l.description,
                        ls.course_id,
                        lsw.week,
                        dlswp.type_material_id
                    FROM detail_level_syllabus_weeks_parents dlswp
                    JOIN level_syllabus_weeks lsw ON lsw.id = dlswp.level_syllabus_weeks_id
                    JOIN level_syllabus ls on ls.id = lsw.level_syllabus_id
                    JOIN level l ON l.id = dlswp.level_id
                    WHERE dlswp.fl_status = TRUE
                    AND dlswp.type_material_id IN (SELECT gtm.type_material_id FROM get_type_materias gtm)
                    AND ls.fl_status = TRUE
                    AND ls.cycle_id IN (SELECT tm.cycle_id FROM tbl_material tm)
                    AND ls.university_id IN (SELECT tm.university_id FROM tbl_material tm)
                    AND ls.course_id IN (SELECT gtmc.course_id FROM get_type_material_courses gtmc)
                    AND lsw.week IN (SELECT gtmw.week FROM get_type_material_week gtmw);
                END;
                $$;


ALTER FUNCTION odiseo.fn_get_config_text_level_register_ballot_period(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint) OWNER TO postgres;

--
