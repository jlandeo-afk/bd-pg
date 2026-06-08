-- Function: odiseo.fn_get_config_syllabus_complete_ballot_period(bigint, smallint, smallint, smallint)

--

CREATE FUNCTION odiseo.fn_get_config_syllabus_complete_ballot_period(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint) RETURNS TABLE(id bigint, type_material_id smallint, amount_type_mat smallint, subtopic_id smallint, code_subtopic character varying, subtopic character varying, week smallint, topic_id smallint, code_topic character varying, topic character varying, course_id bigint, code_course character varying, course character varying, course_position smallint, syllabus_id bigint)
    LANGUAGE plpgsql
    AS $$
                DECLARE
                    v_ids_children INT[];
                    v_university_id INT;
                BEGIN
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
                    ), template_type_material AS (
                        SELECT
                            tm.type_material_template_id
                        FROM type_material tm
                        WHERE tm.id = p_type_material_id
                    ), courses_ordering AS (
                        SELECT
                            cor.course_id,
                            cor.position AS course_position
                        FROM template_type_material_courses_order cor
                        WHERE 1 = 1
                        AND cor.deleted_at IS NULL
                        AND cor.template_type_material_id IN (SELECT tmt.type_material_template_id FROM template_type_material tmt)
                        AND cor.university_id IS NULL
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
                        UNION ALL
                        SELECT * FROM get_type_material_courses_not_generic
                    ), get_type_material_week AS ( -- Se trae las semanas del tipo material
                        SELECT
                            tmdt.week
                        FROM type_material_detail_template tmdt
                        WHERE tmdt.type_material_id = p_type_material_id
                            AND tmdt.week BETWEEN p_start_week AND p_end_week
                            AND tmdt.fl_status = true
                        ORDER BY tmdt.week ASC
                    ), get_courses_not_register_ballot AS (
                        SELECT DISTINCT
                            gtmc.course_id
                        FROM get_type_material_courses gtmc
                        LEFT JOIN (
                            SELECT DISTINCT
                                mdbq.course_id
                            FROM detail_week_type_mat dwtm
                            JOIN material_ballot_question mdbq
                                ON dwtm.id = mdbq.week_type_material_id
                            WHERE mdbq.material_id = p_material_id
                                AND dwtm.week BETWEEN p_start_week AND p_end_week
                                AND dwtm.type_material_id IN (SELECT gtm.type_material_id FROM get_type_materias gtm)
                                AND mdbq.fl_status = true
                                AND mdbq.type_text_id IS NULL
                        ) AS existing_courses
                        ON gtmc.course_id = existing_courses.course_id
                        WHERE existing_courses.course_id IS NULL
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
                        ccor.course_position,
                        s.id AS syllabus_id
                    FROM syllabus_subtopic_type_material stm
                    INNER JOIN syllabus_detail_subtopic sds ON stm.syllabus_detail_subtopic_id = sds.id AND sds.fl_status = true
                    INNER JOIN syllabus_topic_week stw ON sds.syllabus_topic_week_id = stw.id AND stw.fl_status = true
                    INNER JOIN syllabus_topic st ON stw.syllabus_topic_id = st.id AND st.fl_status = true
                    INNER JOIN syllabus s ON st.syllabus_id = s.id
                    INNER JOIN course co ON s.course_id = co.id
                    INNER JOIN topic top ON st.topic_id = top.id
                    INNER JOIN subtopic su ON sds.subtopic_id = su.id
                    LEFT JOIN courses_ordering ccor ON s.course_id = ccor.course_id
                    WHERE 1 = 1
                        AND stm.fl_status = true
                        AND s.fl_status = true
                        AND s.course_id IN (SELECT gcnrb.course_id FROM get_courses_not_register_ballot gcnrb)
                        AND stm.type_material_id IN (SELECT gtm.type_material_id FROM get_type_materias gtm)
                        AND s.university_id IN (SELECT tm.university_id FROM tbl_material tm)
                        AND s.cycle_id IN (SELECT tm.cycle_id FROM tbl_material tm)
                        AND stw.week IN (SELECT gtmw.week FROM get_type_material_week gtmw)
                        AND stm.questions_amount > 0
                    ORDER BY ccor.course_position ASC, s.course_id ASC, st.topic_id ASC, sds.subtopic_id ASC, stw.week ASC;
                END;
                $$;


ALTER FUNCTION odiseo.fn_get_config_syllabus_complete_ballot_period(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint) OWNER TO postgres;

--
