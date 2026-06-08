-- Function: odiseo.fn_get_config_syllabus_register_ballot_period(bigint, smallint, smallint, smallint)

--

CREATE FUNCTION odiseo.fn_get_config_syllabus_register_ballot_period(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint) RETURNS TABLE(id bigint, type_material_id smallint, amount_type_mat smallint, subtopic_id smallint, code_subtopic character varying, subtopic character varying, week smallint, topic_id smallint, code_topic character varying, topic character varying, course_id bigint, code_course character varying, course character varying, syllabus_id bigint)
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
                        stm.id,
                        stm.type_material_id,
                        stm.questions_amount AS amount_type_mat,
                        sds.subtopic_id,
                        su.code AS code_subtopic,
                        su.name AS subtopic,
                        stw.week,
                        st.topic_id,
                        top.code AS code_topic,
                        top.name AS topic,
                        s.course_id,
                        co.code AS code_course,
                        co.name AS course,
                        s.id AS syllabus_id
                    FROM syllabus_subtopic_type_material stm
                    INNER JOIN syllabus_detail_subtopic sds ON stm.syllabus_detail_subtopic_id = sds.id AND sds.fl_status = true
                    INNER JOIN syllabus_topic_week stw ON sds.syllabus_topic_week_id = stw.id AND stw.fl_status = true
                    INNER JOIN syllabus_topic st ON stw.syllabus_topic_id = st.id AND st.fl_status = true
                    INNER JOIN syllabus s ON st.syllabus_id = s.id
                    INNER JOIN course co ON s.course_id = co.id
                    INNER JOIN topic top ON st.topic_id = top.id
                    INNER JOIN subtopic su ON sds.subtopic_id = su.id
                    WHERE 1 = 1
                        AND stm.fl_status = true
                        AND s.fl_status = true
                        AND s.course_id IN (SELECT gtmc.course_id FROM get_type_material_courses gtmc)
                        AND stm.type_material_id IN (SELECT gtm.type_material_id FROM get_type_materias gtm)
                        AND s.university_id IN (SELECT tm.university_id FROM tbl_material tm)
                        AND s.cycle_id IN (SELECT tm.cycle_id FROM tbl_material tm)
                        AND stw.week IN (SELECT gtmw.week FROM get_type_material_week gtmw)
                        AND stm.questions_amount > 0
                    ORDER BY s.course_id ASC, st.topic_id ASC, sds.subtopic_id ASC, stw.week ASC;
                END;
                $$;


ALTER FUNCTION odiseo.fn_get_config_syllabus_register_ballot_period(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint) OWNER TO postgres;

--
