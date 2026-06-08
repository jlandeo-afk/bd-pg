-- Function: odiseo.fn_get_config_text_syllabus_register_ballot_period(bigint, smallint, smallint, smallint)

--

CREATE FUNCTION odiseo.fn_get_config_text_syllabus_register_ballot_period(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint) RETURNS TABLE(category_id bigint, subcategory_id bigint, type_material_id smallint, course_id bigint, course_name character varying, material character varying, category character varying, subcategory character varying, topic_subquestions jsonb, position_initial bigint, position_text smallint, week smallint)
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
                        JOIN type_material_detail_course_texts tmdc ON tmc.id = tmdc.type_material_course_id
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
                        tt.id AS category_id,
                        tts.id AS subcategory_id,
                        tm.id AS type_material_id,
                        s.course_id,
                        c."name" AS course_name,
                        tm.description AS material,
                        tt.name AS category,
                        tts.name AS subcategory,
                        (
                            SELECT jsonb_agg(
                                jsonb_build_object(
                                    'topic_id', t.id,
                                    'code_topic', t.code,
                                    'subtopic_id', stc.subtopic_id,
                                    'code_subtopic', sub.code,
                                    'quantity', stc.quantity
                                )
                                ORDER BY t.code, sub.code
                            ) AS topic_subquestions
                            FROM syllabus_text_content stc
                            JOIN subtopic sub ON sub.id = stc.subtopic_id
                            JOIN topic t ON t.id = sub.topic_id
                            WHERE stc.syllabus_text_id = st.id
                                AND stc.fl_status = true
                        ) AS topic_subquestions,
                        (ROW_NUMBER() OVER (ORDER BY tt.position, tts.id) - 1) AS position_initial,
                        tt.position position_text,
                        stw.week
                    FROM syllabus s
                    JOIN course c ON c.id = s.course_id
                    JOIN syllabus_text_weeks stw ON stw.syllabus_id = s.id
                        AND stw.fl_status = true
                    JOIN syllabus_text_distributions std ON std.syllabus_text_week_id = stw.id
                        AND std.fl_status = true
                    JOIN type_material tm ON tm.id = std.type_material_id
                    JOIN syllabus_texts st ON st.syllabus_text_distribution_id = std.id
                        AND st.fl_status = true
                    JOIN type_text tt ON tt.id = st.type_text_id
                    JOIN type_text_subcategories tts ON tts.id = st.type_text_subcategory_id
                    WHERE std.type_material_id IN (SELECT gtm.type_material_id FROM get_type_materias gtm)
                        AND s.university_id IN (SELECT tm.university_id FROM tbl_material tm)
                        AND s.cycle_id IN (SELECT tm.cycle_id FROM tbl_material tm)
                        AND stw.week IN (SELECT gtmw.week FROM get_type_material_week gtmw)
                        AND s.course_id IN (SELECT gtmc.course_id FROM get_type_material_courses gtmc)
                    ORDER BY tt.id, tts.id;
                END;
                $$;


ALTER FUNCTION odiseo.fn_get_config_text_syllabus_register_ballot_period(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint) OWNER TO postgres;

--
