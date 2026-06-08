-- Function: odiseo.fn_get_config_level_register_ballot_period(bigint, smallint, smallint, smallint)

--

CREATE FUNCTION odiseo.fn_get_config_level_register_ballot_period(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint) RETURNS TABLE(id bigint, type_material_id bigint, amount_type_mat integer, level_id bigint, level_description character varying, level_name character varying, type_question character varying, week smallint, headquarter_id bigint, course_id bigint, code_course character varying, course character varying)
    LANGUAGE plpgsql
    AS $$
                DECLARE
                    v_ids_children INT[];
                BEGIN
                    -- Obtener todos los IDs de los hijos en un array
                    SELECT CASE
                        WHEN EXISTS (SELECT 1 FROM type_material tm WHERE tm.parent_id = p_type_material_id)
                        THEN ARRAY(SELECT tm.id FROM type_material tm WHERE tm.parent_id = p_type_material_id)
                        ELSE ARRAY[p_type_material_id]
                    END INTO v_ids_children;

                    RETURN QUERY
                    WITH tbl_material AS ( -- Se obtiene el ciclo y universidad del material
                        SELECT
                            m.cycle_id,
                            m.university_id
                        FROM material m
                        WHERE m.id = p_material_id
                    ), get_type_materias AS ( -- Se trae el id de tipo material hijo si los tiene, sino se manda el normal
                        SELECT unnest(v_ids_children) AS type_material_id
                    ), get_type_material_courses_generic AS ( -- Se trae los cursos de tipo material
                        SELECT
                            tmc.type_material_id,
                            tmc.course_id
                        FROM type_material_course tmc
                        WHERE tmc.type_material_id IN (SELECT gtm.type_material_id FROM get_type_materias gtm)
                            AND tmc.amount_question > 0
                            AND tmc.is_generic IS TRUE
                            AND tmc.fl_status = true
                    ), get_type_material_courses_not_generic AS (
                        SELECT DISTINCT
                            tmc.type_material_id,
                            tmc.course_id
                        FROM type_material_course tmc
                        JOIN type_material_detail_template tmdt ON tmc.type_material_id = tmdt.type_material_id
                            AND tmdt.fl_status = true
                        JOIN odiseo.type_material_detail_courses tmdc ON tmc.id = tmdc.type_material_course_id
                            AND tmdt.id = tmdc.type_material_detail_template_id
                            AND tmdc.fl_status = true
                        WHERE tmc.type_material_id IN (SELECT gtm.type_material_id FROM get_type_materias gtm)
                            AND tmdc.amount_question > 0
                            AND tmc.is_generic IS FALSE
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
                        dlsw.id,
                        dlsw.type_material_id,
                        dlsw.number_questions AS amount_type_mat,
                        dlsw.level_id,
                        l.description AS level_description,
                        l.name AS level_name,
                        dlsw.type_question,
                        lsw.week,
                        ls.headquarter_id,
                        ls.course_id,
                        c.code AS code_course,
                        c.name AS course
                    FROM detail_level_syllabus_weeks dlsw
                    INNER JOIN level_syllabus_weeks lsw ON dlsw.level_syllabus_weeks_id = lsw.id
                        AND lsw.fl_status = true
                    INNER JOIN level_syllabus ls ON lsw.level_syllabus_id = ls.id
                    INNER JOIN course c ON ls.course_id = c.id
                    INNER JOIN level l ON dlsw.level_id = l.id
                    WHERE 1 = 1
                        AND dlsw.fl_status = true
                        AND ls.fl_status = true
                        AND dlsw.type_material_id IN (SELECT gtm.type_material_id FROM get_type_materias gtm)
                        AND ls.cycle_id IN (SELECT tm.cycle_id FROM tbl_material tm)
                        AND ls.university_id IN (SELECT tm.university_id FROM tbl_material tm)
                        AND ls.course_id IN (SELECT gtmc.course_id FROM get_type_material_courses gtmc)
                        AND lsw.week IN (SELECT gtmw.week FROM get_type_material_week gtmw)
                    ORDER BY ls.course_id ASC, dlsw.level_id ASC, dlsw.type_question ASC, lsw.week ASC;
                END;
                $$;


ALTER FUNCTION odiseo.fn_get_config_level_register_ballot_period(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint) OWNER TO postgres;

--
