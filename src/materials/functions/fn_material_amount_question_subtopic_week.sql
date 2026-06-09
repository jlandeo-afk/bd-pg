-- Function: materials.fn_material_amount_question_subtopic_week(bigint, smallint, smallint, jsonb)

--

CREATE FUNCTION materials.fn_material_amount_question_subtopic_week(p_material_id bigint, p_type_material_id smallint, p_week smallint, p_courses jsonb) RETURNS TABLE(id bigint, type_material_id smallint, amount_type_mat smallint, subtopic_id smallint, code_subtopic character varying, subtopic character varying, week smallint, topic_id smallint, code_topic character varying, topic character varying, course_id bigint, code_course character varying, course character varying, syllabus_id bigint)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_cycle_id BIGINT;
            v_university_id SMALLINT;
        BEGIN
            -- Obtener ciclo y universidad del material mandado
            SELECT m.cycle_id, m.university_id INTO v_cycle_id, v_university_id FROM material m WHERE m.id = p_material_id LIMIT 1;

            RETURN QUERY
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
            WHERE stm.fl_status = true
            AND s.fl_status = true
            AND s.course_id IN (SELECT jsonb_array_elements_text(p_courses)::BIGINT)
            AND stm.type_material_id = p_type_material_id
            AND s.university_id = v_university_id
            AND s.cycle_id = v_cycle_id
            AND stw.week = p_week
            AND stm.questions_amount > 0
            ORDER BY s.course_id ASC, st.topic_id ASC, sds.subtopic_id ASC;
        END;
        $$;


ALTER FUNCTION materials.fn_material_amount_question_subtopic_week(p_material_id bigint, p_type_material_id smallint, p_week smallint, p_courses jsonb) OWNER TO postgres;

--
