-- Function: common.fn_update_set_massive_attributes(jsonb, bigint)

--

CREATE FUNCTION common.fn_update_set_massive_attributes(p_questions jsonb, f_user_id bigint) RETURNS TABLE(question_code character varying, question_status character varying, error text)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_question JSONB;
            v_row_question questions.question%ROWTYPE;
            v_result odiseo.massive_attribute_result;
            v_results odiseo.massive_attribute_result[];

            v_course_id academic.course.id%TYPE;
            v_question_ter questions.question.ter%TYPE;
            v_question_type questions.question.type%TYPE;
            v_topic_id academic.topic.id%TYPE;
            v_level_id academic.level.id%TYPE;
            v_subtopic_id academic.subtopic.id%TYPE;
            v_question_subtopic_id questions.question_subtopic.id%TYPE;
            v_alternative_id questions.alternative.id%TYPE;
            v_alternative_id_loop questions.alternative.id%TYPE;
            v_alternative_index_loop INTEGER := 0;
            v_alternative_letter_loop VARCHAR;
            v_history_status TEXT;
            v_history_process TEXT;
            v_history_description TEXT;
            v_user_name TEXT;
            v_ghost_teacher_id SMALLINT;
            v_ghost_didi_id INTEGER;
            v_is_question_assigned_to_teacher BOOLEAN;
            v_is_question_assigned_to_didi BOOLEAN;
        BEGIN
            SELECT  CASE WHEN e.id IS NOT NULL THEN CONCAT(e.first_name,' ', left(e.first_surname, 1), '. ',' ', e.second_surname) ELSE 'Administrador' END as user
            INTO v_user_name
            FROM  auth.users u
            LEFT JOIN organization.employees e
            ON u.id = e.user_id
            WHERE u.id = f_user_id;

            SELECT e.id
            INTO v_ghost_teacher_id
            FROM organization.employees e
            WHERE e."document" = '33333333' AND e.charge_id = 2;

            SELECT e.id
            INTO v_ghost_didi_id
            FROM organization.employees e
            WHERE e."document" = '44444444' AND e.charge_id = 3;


            FOR v_question IN SELECT * FROM jsonb_array_elements_text(p_questions)
            LOOP
                BEGIN
                    SELECT id INTO v_course_id FROM academic.course
                        WHERE code = (v_question->>'data')::JSONB->>'course_code'
                        AND fl_status AND deleted_at IS NULL;

                    IF v_course_id IS NOT NULL THEN
                        SELECT id INTO v_topic_id FROM academic.topic
                            WHERE code = (v_question->>'data')::JSONB->>'topic_code'
                                AND course_id = v_course_id
                                AND fl_status AND deleted_at IS NULL;
                    ELSE
                        RAISE EXCEPTION 'No se encontró ese curso';
                    END IF;

                    IF v_topic_id IS NULL THEN
                        RAISE EXCEPTION 'No se encontró ese tema de ese curso';
                    END IF;

                    SELECT * INTO v_row_question FROM questions.question
                    WHERE number_question = v_question->>'code'
                        AND status != 'ARCH'
                        AND fl_status
                        AND course_id = v_course_id
                        AND deleted_at IS NULL;

                    IF v_row_question IS NULL THEN
                        RAISE EXCEPTION 'No se encontró la pregunta con ese número de problema y curso';
                    END IF;

                    SELECT id INTO v_level_id FROM academic.level
                        WHERE name = (v_question->>'data')::JSONB->>'level_name'
                        AND fl_status AND deleted_at IS NULL;
                    v_question_ter := ((v_question->>'data')::JSONB->>'ter');
                    v_question_type := ((v_question->>'data')::JSONB->>'type');

                    FOR v_alternative_id_loop IN
                        SELECT * FROM questions.alternative
                        WHERE question_id = v_row_question.id AND fl_status AND deleted_at IS NULL
                        ORDER BY created_at
                    LOOP
                        v_alternative_index_loop := v_alternative_index_loop + 1;

                        IF (v_alternative_index_loop = 1) THEN
                            v_alternative_letter_loop := 'A';
                        ELSIF (v_alternative_index_loop = 2) THEN
                            v_alternative_letter_loop := 'B';
                        ELSIF (v_alternative_index_loop = 3) THEN
                            v_alternative_letter_loop := 'C';
                        ELSIF (v_alternative_index_loop = 4) THEN
                            v_alternative_letter_loop := 'D';
                        ELSIF (v_alternative_index_loop = 5) THEN
                            v_alternative_letter_loop := 'E';
                        END IF;

                        IF (v_alternative_letter_loop) = ((v_question->>'data')::JSONB->>'alternative_correct') THEN
                            v_alternative_id := v_alternative_id_loop;
                            EXIT;
                        END IF;
                    END LOOP;


                    IF v_row_question.status <> 'DUPL' THEN
                        -- Verificar si ya se asigno la pregunta a un docente
                        SELECT CASE WHEN count(*) > 0 THEN true ELSE false END  AS is_question_assigned_to_teacher
                        INTO v_is_question_assigned_to_teacher
                        FROM questions.employee_question eq
                        WHERE eq.question_id = v_row_question.id
                        AND eq.fl_status = true;

                        IF v_is_question_assigned_to_teacher = false THEN
                            -- Asignando la pregunta a un docente Ghost
                            INSERT INTO questions.employee_question (teacher_id, question_id, created_by, created_at)
                            VALUES (v_ghost_teacher_id, v_row_question.id, f_user_id, NOW());

                            -- Guardar en el historial
                            INSERT INTO questions.question_status (question_id, status, process, description, created_by, created_at)
                            VALUES (v_row_question.id, 'ASIG', 'ASIGNACIÓN', 'La pregunta fue asignada al docente <span class=''text-teacher''>Docente Ghost</span> por el usuario <span class=''text-user''> ' || v_user_name || '</span>', f_user_id, NOW());
                        END IF;

                        -- Verificar si ya se asigno la pregunta a un DIDI
                        SELECT CASE WHEN count(*) > 0 THEN true ELSE false END  AS is_question_assigned_to_didi
                        INTO v_is_question_assigned_to_didi
                        FROM questions.employee_didi_question edq
                        WHERE edq.question_id = v_row_question.id
                        AND edq.fl_status = true;

                        IF v_is_question_assigned_to_didi = false THEN
                            -- Asignando la pregunta a un DIDI
                            INSERT INTO questions.employee_didi_question (employee_id, question_id, created_by, created_at)
                            VALUES (v_ghost_didi_id, v_row_question.id, f_user_id, NOW());

                            -- Guardar en el historial
                            INSERT INTO questions.question_status (question_id, status, process, description, created_by, created_at)
                            VALUES (v_row_question.id, 'DASI', 'ASIGNADO', 'La pregunta fue asignada al DiDi <span class=''text-teacher''>DIDI GHOST</span> por el usuario <span class=''text-user''> ' || v_user_name || '</span>', f_user_id, NOW());
                        END IF;

                    END IF;


                    UPDATE questions.question
                    SET
                        ter = COALESCE(v_question_ter, v_row_question.ter),
                        topic_id = COALESCE(v_topic_id, v_row_question.topic_id),
                        level_id = COALESCE(v_level_id, v_row_question.level_id),
                        answer_id = COALESCE(v_alternative_id, v_row_question.answer_id),
                        type = COALESCE(v_question_type, v_row_question.type)
                    WHERE id = v_row_question.id;


                    IF v_topic_id IS NOT NULL THEN
                        SELECT id INTO v_subtopic_id FROM academic.subtopic
                            WHERE code = (v_question->>'data')::JSONB->>'subtopic_code'
                                AND topic_id = v_topic_id
                                AND fl_status AND deleted_at IS NULL;
                    ELSE
                        RAISE NOTICE 'No existe ese tema %', (v_question->>'data')::JSONB->>'topic_code';
                    END IF;

                    RAISE NOTICE 'v_subtopic_id: %', v_subtopic_id;

                    IF v_subtopic_id IS NOT NULL THEN
                        UPDATE questions.question_subtopic
                        SET fl_status = FALSE, deleted_at = NOW()
                        WHERE question_id = v_row_question.id;

                        SELECT id INTO v_question_subtopic_id FROM questions.question_subtopic
                        WHERE question_id = v_row_question.id AND subtopic_id = v_subtopic_id;

                        IF v_question_subtopic_id IS NOT NULL THEN
                            UPDATE questions.question_subtopic
                            SET fl_status = TRUE, deleted_at = NULL,
                                updated_by = f_user_id, updated_at = NOW()
                            WHERE id = v_question_subtopic_id;
                        ELSE
                            INSERT INTO questions.question_subtopic
                                (question_id, subtopic_id, fl_status, created_at, created_by)
                            VALUES
                                (v_row_question.id, v_subtopic_id, TRUE, NOW(), f_user_id);
                        END IF;
                    ELSE
                        RAISE NOTICE 'No existe el subtema % del tema %', (v_question->>'data')::JSONB->>'subtopic_code', (v_question->>'data')::JSONB->>'topic_code';
                    END IF;

                    IF v_course_id IS NULL THEN
                        RAISE NOTICE 'No existe el curso %', (v_question->>'data')::JSONB->>'course_code';
                    END IF;

                    IF v_level_id IS NULL THEN
                        RAISE NOTICE 'No existe el nivel %', (v_question->>'data')::JSONB->>'level_name';
                    END IF;

                    IF v_alternative_id IS NULL THEN
                        RAISE NOTICE 'No existe la alternativa  %', (v_question->>'data')::JSONB->>'alternative_correct';
                    END IF;

                    -- Actualizamos la variable v_row_question para traer los datos actualizados
                    SELECT * INTO v_row_question FROM questions.question q WHERE q.id = v_row_question.id LIMIT 1;


                    IF(
                        1 = 1
                        AND v_row_question.status NOT IN ('VERI','DUPL', 'ARCH')
                    ) THEN -- si la pregunta ya esta verificada no es necesario actualizar su estado a verificada
                        IF (
                            1 = 1
                            AND v_row_question.topic_id IS NOT NULL
                            AND EXISTS (
                                SELECT 1 FROM questions.question_subtopic qs1
                                WHERE qs1.question_id = v_row_question.id AND qs1.fl_status AND qs1.deleted_at IS NULL
                            )
                            AND v_row_question.level_id IS NOT NULL
                            AND v_row_question.answer_id IS NOT NULL
                            AND v_row_question.type IS NOT NULL
                            AND v_row_question.ter IS NOT NULL
                            AND v_row_question.status NOT IN ('DUPL', 'ARCH')
                        ) THEN
                            v_history_status := 'VERI';
                            v_history_process := 'VERIFICADO';
                            v_history_description :=  'La pregunta se cambió al estado verificado  por el usuario <span class=''text-user''>' || v_user_name || '</span>';

                            UPDATE questions.question
                            SET status = 'VERI'
                            WHERE id = v_row_question.id;
                        ELSE
                            v_history_status := 'PEND';
                            v_history_process := 'PENDIENTE';
                            v_history_description :=  'La pregunta se cambió al estado pendiente  por el usuario <span class=''text-user''>' || v_user_name || '</span>';

                            UPDATE questions.question
                            SET status = 'PEND'
                            WHERE id = v_row_question.id;
                        END IF;

                        UPDATE questions.question_status
                        SET fl_active = false
                        WHERE question_id = v_row_question.id;

                        INSERT INTO questions.question_status (question_id, status, process, description, created_by, created_at,fl_active)
                        VALUES (v_row_question.id, v_history_status, v_history_process, v_history_description, f_user_id, NOW(), true);
                    END IF;

                    SELECT * INTO v_row_question FROM questions.question q WHERE q.id = v_row_question.id LIMIT 1;

                    v_result := ROW(v_question->>'code', v_row_question.status, NULL);

                    v_results := array_append(v_results, v_result);

                    v_course_id := NULL;
                    v_question_ter := NULL;
                    v_question_type := NULL;
                    v_topic_id := NULL;
                    v_level_id := NULL;
                    v_subtopic_id := NULL;
                    v_question_subtopic_id := NULL;
                    v_alternative_id := NULL;
                    v_alternative_id_loop := NULL;
                    v_alternative_index_loop := 0;
                    v_alternative_letter_loop := NULL;
                    v_history_status := NULL;
                    v_history_process := NULL;
                    v_history_description := NULL;
                EXCEPTION
                    WHEN no_data_found THEN
                        v_result := ROW(v_question->>'code', NULL, 'No se encontró la pregunta con ese number_question');
                    WHEN OTHERS THEN
                        v_result := ROW(v_question->>'code', NULL, SQLERRM);

                    v_results := array_append(v_results, v_result);
                    v_course_id := NULL;
                    v_question_ter := NULL;
                    v_question_type := NULL;
                    v_topic_id := NULL;
                    v_level_id := NULL;
                    v_subtopic_id := NULL;
                    v_question_subtopic_id := NULL;
                    v_alternative_id := NULL;
                    v_alternative_id_loop := NULL;
                    v_alternative_index_loop := 0;
                    v_alternative_letter_loop := NULL;
                    v_history_status := NULL;
                    v_history_process := NULL;
                    v_history_description := NULL;
                END;
            END LOOP;

            RETURN QUERY SELECT * FROM unnest(v_results);
        END;
        $$;


ALTER FUNCTION common.fn_update_set_massive_attributes(p_questions jsonb, f_user_id bigint) OWNER TO postgres;

--
