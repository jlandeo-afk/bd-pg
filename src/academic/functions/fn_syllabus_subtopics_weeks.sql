-- Function: academic.fn_syllabus_subtopics_weeks(bigint, smallint, smallint, bigint)

--

CREATE FUNCTION academic.fn_syllabus_subtopics_weeks(p_material_id bigint, p_type_material_id smallint, p_week smallint, p_company_id bigint) RETURNS TABLE(id bigint, type_material_id smallint, amount_type_mat smallint, subtopic_id smallint, code_subtopic character varying, subtopic character varying, week smallint, topic_id smallint, code_topic character varying, topic character varying, course_id bigint, code_course character varying, course character varying, syllabus_id bigint)
    LANGUAGE plpgsql
    AS $$
                    DECLARE
                        v_cycle_id BIGINT;
                        v_university_id SMALLINT;
                        v_fl_exam BOOLEAN;
                        v_type_exam_id BIGINT;
                        v_weeks JSONB;
                        v_type_material_ids JSONB;
                    BEGIN
                        -- Obtener ciclo y universidad del material mandado
                        SELECT
                            m.cycle_id, m.university_id INTO v_cycle_id, v_university_id
                        FROM material m
                        LEFT JOIN cycle c ON m.cycle_id = c.id
                        WHERE m.id = p_material_id
                        LIMIT 1;

                        -- Obtener data del tipo material
                        SELECT
                            tmt.fl_exam, tmt.type_exam_id INTO v_fl_exam, v_type_exam_id
                        FROM type_material tm
                        INNER JOIN type_material_template tmt ON tm.type_material_template_id = tmt.id
                        WHERE tm.id = p_type_material_id
                        LIMIT 1;

                        IF v_fl_exam IS FALSE THEN
                            SELECT
                                material_ids INTO v_type_material_ids
                            FROM fn_get_children_material_type_ids(p_type_material_id, v_cycle_id)
                            LIMIT 1;
                        END IF;

                        IF v_fl_exam IS TRUE AND v_type_exam_id = 3 THEN
                            v_weeks := '[]'::jsonb;
                            FOR i IN 1..p_week LOOP
                                v_weeks := v_weeks || to_jsonb(i);
                            END LOOP;
                        ELSIF v_fl_exam IS TRUE AND v_type_exam_id = 4 THEN
                            v_weeks := NULL;
                        ELSE
                            v_weeks := jsonb_build_array(p_week);
                        END IF;

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
                        INNER JOIN syllabus_detail_subtopic sds ON stm.syllabus_detail_subtopic_id = sds.id
                            AND sds.fl_status = true
                            AND sds.company_id = p_company_id
                        INNER JOIN syllabus_topic_week stw ON sds.syllabus_topic_week_id = stw.id
                            AND stw.fl_status = true
                            AND stw.company_id = p_company_id
                        INNER JOIN syllabus_topic st ON stw.syllabus_topic_id = st.id
                            AND st.fl_status = true
                            AND st.company_id = p_company_id
                        INNER JOIN syllabus s ON st.syllabus_id = s.id
                            AND s.company_id = p_company_id
                        INNER JOIN course co ON s.course_id = co.id
                        INNER JOIN topic top ON st.topic_id = top.id
                        INNER JOIN subtopic su ON sds.subtopic_id = su.id
                        WHERE stm.fl_status = true
                            AND s.fl_status = true
                            AND (
                                v_type_material_ids IS NULL
                                OR stm.type_material_id IN (
                                    SELECT jsonb_array_elements_text(v_type_material_ids)::SMALLINT
                                )
                            )
                            AND s.university_id = v_university_id
                            AND s.cycle_id = v_cycle_id
                            AND (
                                v_weeks IS NULL
                                OR stw.week IN (
                                    SELECT jsonb_array_elements_text(v_weeks)::SMALLINT
                                )
                            )
                            AND stm.questions_amount > 0
                            AND stm.company_id = p_company_id
                        ORDER BY s.course_id ASC, st.topic_id ASC, sds.subtopic_id ASC;
                    END;
                    $$;


ALTER FUNCTION academic.fn_syllabus_subtopics_weeks(p_material_id bigint, p_type_material_id smallint, p_week smallint, p_company_id bigint) OWNER TO postgres;

--
