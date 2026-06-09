-- Function: academic.fn_change_topic_subtopics(smallint, smallint, bigint)

--

CREATE FUNCTION academic.fn_change_topic_subtopics(p_topic_id smallint, p_subtopic_id smallint, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_code VARCHAR;
                v_before_topic_id SMALLINT;
                v_question RECORD;
                v_case_subtopic SMALLINT;
                v_total INTEGER;
                v_max_code_item RECORD;
            BEGIN
                SELECT s.topic_id INTO v_before_topic_id FROM academic.subtopic s
                WHERE s.id = p_subtopic_id  AND s.fl_status = true LIMIT 1;

                IF p_topic_id <> v_before_topic_id THEN

                -- Obtener todas las preguntas que tienen este subtema
                    FOR v_question IN
                        SELECT * FROM odiseo.fn_get_question_by_subtopic(p_subtopic_id)
                    LOOP

                        -- Comprobar si 'subtopics' está vacío o es NULL
                        IF v_question.subtopics IS NULL OR jsonb_array_length(v_question.subtopics) = 0 THEN
                            -- Si no hay subtemas, saltar a la siguiente pregunta
                            CONTINUE;
                        END IF;

                        -- Obtener los subtemas asociados a la pregunta
                        v_total := jsonb_array_length(v_question.subtopics);

                        -- Caso 1: Pregunta con un solo subtema
                        IF v_total = 1 THEN
                            v_case_subtopic := 1;

                        -- Modificando el tema de la pregunta
                        UPDATE odiseo.question  SET topic_id = p_topic_id  WHERE id =  v_question.id AND fl_status = TRUE;

                        -- Caso 2: Pregunta con varios subtemas
                        ELSE
                            -- Extraer y analizar los códigos dentro de 'subtopics' (arreglo JSON)
                            -- Asumimos que v_question.subtopics es un JSON
                            WITH subtopics_data AS (
                                SELECT jsonb_array_elements(v_question.subtopics) AS subtopic
                            )
                            -- Encontrar el subtema con el código más alto
                            SELECT subtopic->>'code' AS code, subtopic->>'id' AS id
                            INTO v_max_code_item
                            FROM subtopics_data
                            ORDER BY CAST(subtopic->>'code' AS INTEGER) DESC
                            LIMIT 1;

                            RAISE NOTICE 'Comparando v_max_code_item.id: %, p_subtopic_id: %', v_max_code_item.id, p_subtopic_id;

                            -- Si el subtema actual tiene el código más alto, es el mayor
                            IF v_max_code_item.id = CAST(p_subtopic_id AS TEXT) THEN

                                RAISE NOTICE 'El tema es mayor';
                                -- Modificando el tema de la pregunta
                                UPDATE odiseo.question  SET topic_id = p_topic_id  WHERE id =  v_question.id AND fl_status = TRUE;

                                -- Modificando el subtema de la pregunta en la tabla question_subtopic
                                UPDATE odiseo.question_subtopic  SET fl_status = false, deleted_by = p_updated_by, deleted_at = now() WHERE question_id =  v_question.id AND subtopic_id != p_subtopic_id; 

                                v_case_subtopic := 3;  -- Es el subtema mayor
                            ELSE
                                RAISE NOTICE 'El tema es menor %,p_question_id : %, p_topic_id', v_question.id, p_topic_id ;
                                -- Modificando el subtema de la pregunta en la tabla question_subtopic
                                UPDATE odiseo.question_subtopic  SET fl_status = false, deleted_by = p_updated_by, deleted_at = now() WHERE question_id =  v_question.id AND subtopic_id = p_subtopic_id; 
                                v_case_subtopic := 2;  -- No es el subtema mayor
                            END IF;
                        END IF;
                    END LOOP;

                    -- Generar codigo para el subtema
                    SELECT LPAD(CAST(COALESCE(MAX(CAST(su.code AS INTEGER)), 0) + 1 AS TEXT), 2, '0')::VARCHAR INTO v_code FROM academic.subtopic su WHERE su.topic_id = p_topic_id LIMIT 1;

                    -- Actualiza el tema a al subtema seleccionado
                    UPDATE academic.subtopic SET code = v_code, topic_id = p_topic_id, updated_by = p_updated_by, updated_at = now()
                    WHERE id = p_subtopic_id;

                -- Llamar al procedimiento para actualizar los subtemas en los templates del syllabus
                    CALL academic.sp_change_syllabus_template_subtopics(p_topic_id, p_subtopic_id, p_updated_by);

                    -- Actualiza el subtema del syllabus
                    UPDATE academic.syllabus_detail_subtopic SET is_topic_modified = TRUE WHERE subtopic_id = p_subtopic_id AND fl_status = true;

                -- Registrar el cambio en el historial
                    INSERT INTO academic.subtopic_history (subtopic_id, topic_id, created_by, created_at)
                    VALUES (p_subtopic_id, v_before_topic_id, p_updated_by, now());
                END IF;
            END;
        $$;


ALTER FUNCTION academic.fn_change_topic_subtopics(p_topic_id smallint, p_subtopic_id smallint, p_updated_by bigint) OWNER TO postgres;

--
