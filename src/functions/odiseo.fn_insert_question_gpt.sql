-- Function: odiseo.fn_insert_question_gpt(text, text, smallint, jsonb, jsonb, smallint, smallint, smallint, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_insert_question_gpt(p_question_text text, p_question_short text, p_course_id smallint, p_alternatives jsonb, p_solutions jsonb, p_topic_id smallint, p_subtopic_id smallint, p_level_id smallint, p_config_alternative_id bigint, p_created_by bigint) RETURNS TABLE(question_id bigint, question_code character varying)
    LANGUAGE plpgsql
    AS $$
			DECLARE
                v_question_id BIGINT;
                v_teacher_id BIGINT;
                v_didi_id BIGINT;
                v_number TEXT;
                v_code_course TEXT;
                v_alternative JSONB;
                v_alternative_id BIGINT;
                v_answer_id BIGINT;
                v_week INT;
                v_year INT;
                v_employee_question_id BIGINT;
                v_employee_didi_question_id BIGINT;
                v_solution JSONB;
            BEGIN
                -- Almacenar semana y año
                v_week := EXTRACT(WEEK FROM CURRENT_DATE);
                v_year := EXTRACT(YEAR FROM CURRENT_DATE);

                -- Obtener datos del docente
                SELECT id INTO v_teacher_id FROM odiseo.employees WHERE document = '11111111' AND charge_id = 2 LIMIT 1;

                -- Obtener datos del didi
                SELECT id INTO v_didi_id FROM odiseo.employees WHERE document = '22222222' AND charge_id = 3 LIMIT 1;

                -- Obtener código de curso
                SELECT code INTO v_code_course FROM odiseo.course WHERE id = p_course_id LIMIT 1;

                -- Obtener numero de pregunta
                SELECT LPAD(CAST(COALESCE(CAST(MAX(number) AS INTEGER) + 1, 1) AS TEXT), 7, '0') INTO v_number FROM odiseo.question WHERE course_id = p_course_id AND fl_status = true LIMIT 1;

                -- Insertar pregunta
                INSERT INTO odiseo.question
                (code, description, short_description, course_id, topic_id, level_id, type, ter, status, number, fl_diagrammed, config_alternative_id, created_by, created_at)
                VALUES (CONCAT(v_code_course::VARCHAR, '-', v_number)::VARCHAR, p_question_text, p_question_short, p_course_id, p_topic_id, p_level_id, 'T', 0, 'VERI', v_number, false, p_config_alternative_id, p_created_by, now())
                RETURNING id INTO v_question_id;

                -- Insertar subtema de la pregunta
                INSERT INTO odiseo.question_subtopic (question_id, subtopic_id, created_by, created_at)
                VALUES (v_question_id, p_subtopic_id, p_created_by, now());

                -- Se almacenan las alternativas
                FOR v_alternative IN SELECT jsonb_array_elements(p_alternatives) LOOP
                    INSERT INTO odiseo.alternative (description, question_id, created_by, created_at) VALUES ((v_alternative->>'text')::TEXT, v_question_id, p_created_by, now())
                    RETURNING id INTO v_alternative_id;

                    -- Si encuentra la alternativa correcta se actualiza ese registro
                    IF ((v_alternative->>'answer')::BOOLEAN IS TRUE) THEN
                        v_answer_id := v_alternative_id;

                        UPDATE odiseo.question SET answer_id = v_answer_id WHERE id = v_question_id;
                    END IF;
                END LOOP;

                -- Insertar estado de pregunta
                INSERT INTO odiseo.question_status (question_id, status, process, description, created_by, created_at)
                VALUES (v_question_id, 'VERI', 'VERIFICADO', 'La pregunta ha sido verificada por el usuario <span class="text-teacher">Didi</span> por GPT', p_created_by, now());

                -- Insertar relación de docente
                INSERT INTO odiseo.employee_question (teacher_id, question_id, alternative_id, type, week, year, solved, created_by, created_at)
                VALUES (v_teacher_id, v_question_id, v_answer_id, 'MANUAL', v_week, v_year, true, p_created_by, now())
                RETURNING id INTO v_employee_question_id;

                -- Insertar relación con el didi
                INSERT INTO odiseo.employee_didi_question (employee_id, question_id, week, year, diagrammed, created_by, created_at)
                VALUES (v_didi_id, v_question_id, v_week, v_year, true, p_created_by, now())
                RETURNING id INTO v_employee_didi_question_id;

                -- Insertar solución
                FOR v_solution IN SELECT jsonb_array_elements(p_solutions) LOOP
                    INSERT INTO odiseo.employee_didi_question_field (employee_didi_question_id, setting_diagrammed_course_id, value, created_by, created_at)
                    VALUES (v_employee_didi_question_id, (v_solution->>'setting_diagrammed_id')::BIGINT, (v_solution->>'text')::TEXT, p_created_by, now());
                END LOOP;

                RETURN QUERY SELECT v_question_id, CONCAT(v_code_course::VARCHAR, '-', v_number)::VARCHAR;
            END;
            $$;


ALTER FUNCTION odiseo.fn_insert_question_gpt(p_question_text text, p_question_short text, p_course_id smallint, p_alternatives jsonb, p_solutions jsonb, p_topic_id smallint, p_subtopic_id smallint, p_level_id smallint, p_config_alternative_id bigint, p_created_by bigint) OWNER TO postgres;

--
