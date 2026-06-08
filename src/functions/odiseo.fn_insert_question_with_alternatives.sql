-- Function: odiseo.fn_insert_question_with_alternatives(character varying, character varying, character varying, character varying, smallint, text, text, integer, jsonb, jsonb, jsonb, bigint, character varying, text, character varying, character varying, integer, character varying, integer, integer, character varying, character varying, character varying, boolean, bigint, integer, integer, integer)

--

CREATE FUNCTION odiseo.fn_insert_question_with_alternatives(p_code character varying, p_code_course character varying, p_num_problem character varying, p_num character varying, p_topic_id smallint, p_question_text text, p_question_short text, p_parent_id integer, p_question_images jsonb, p_alternatives jsonb, p_alternative_images jsonb, p_config_alternative_id bigint, p_observation character varying, p_similary text, p_status character varying, p_region character varying, p_university integer, p_year character varying, p_option integer, p_modality integer, p_version character varying, p_area character varying, p_authorship character varying, p_diagrammed boolean, p_created_by bigint, p_cycle_id integer, p_week_id integer, p_type_material_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
            DECLARE
                question_id bigint;
                alternative_id bigint;
                course_id bigint;
                image_question JSONB;
                image_alternative JSONB;
                alternative JSONB;
            BEGIN
                -- Obteniendo el id del curso
                SELECT id
                INTO course_id
                FROM odiseo.course c
                WHERE c.code = p_code_course;
                -- Insertar la pregunta
                INSERT INTO odiseo.question (code, description, short_description, number_question, number, course_id, topic_id, parent_id, status, region, university_id, year, option_id, modality_id, config_alternative_id, version, area, authorship, fl_diagrammed, created_by, created_at)
                VALUES (p_code, p_question_text, p_question_short, p_num_problem, p_num, course_id, p_topic_id, p_parent_id, p_status, p_region, p_university, p_year, p_option,  p_modality, p_config_alternative_id, p_version, p_area, p_authorship, p_diagrammed, p_created_by, now())
                RETURNING id INTO question_id;
                -- Insertar las imágenes de la pregunta
                FOR image_question IN SELECT * FROM jsonb_array_elements(p_question_images) LOOP
                    INSERT INTO odiseo.question_image (code, extension, image, question_id, created_by, created_at)
                    VALUES (image_question->>'code', image_question->>'extension', image_question->>'image', question_id, p_created_by, now());
                END LOOP;
                -- Insertar las imágenes de alternativas
                FOR image_alternative IN SELECT * FROM jsonb_array_elements(p_alternative_images) LOOP
                    INSERT INTO odiseo.question_image (code, extension, image, question_id, created_by, created_at)
                    VALUES (image_alternative->>'code', image_alternative->>'extension', image_alternative->>'image', question_id, p_created_by, now());
                END LOOP;

                -- Insertar las alternativas y actualizar el ID de la respuesta si es 100
                FOR alternative IN SELECT * FROM jsonb_array_elements(p_alternatives) LOOP
                    INSERT INTO odiseo.alternative (description, question_id, created_by, created_at)
                    VALUES (alternative->>'value', question_id, p_created_by, now())
                    RETURNING id INTO alternative_id;

                    -- Si el answer es igual a 100, almacenar el ID de la alternativa en la pregunta
                    IF alternative->>'answer' = '100' THEN
                        UPDATE odiseo.question
                        SET answer_id = alternative_id
                        WHERE id = question_id;
                    END IF;
                END LOOP;

                -- Insertar observación si p_observation no es NULL ni vacío
                IF p_observation IS NOT NULL AND p_observation <> '' THEN
                    INSERT INTO odiseo.question_observation (description, similitaries, question_id, type, fl_status, created_by, created_at)
                    VALUES (p_observation, p_similary, question_id, 'DUPL', true, p_created_by, now());
                END IF;

                -- Insertar data temporal cycly, week and type_material
                IF p_cycle_id IS NOT NULL OR p_week_id IS NOT NULL OR p_type_material_id IS NOT NULL THEN
                    INSERT INTO odiseo.question_temporary (question_id, cycle_id, week_id, type_material_id, created_by, created_at)
                    VALUES (question_id, p_cycle_id, p_week_id, p_type_material_id, p_created_by, now());
                END IF;

                RETURN question_id;
            END;
            $$;


ALTER FUNCTION odiseo.fn_insert_question_with_alternatives(p_code character varying, p_code_course character varying, p_num_problem character varying, p_num character varying, p_topic_id smallint, p_question_text text, p_question_short text, p_parent_id integer, p_question_images jsonb, p_alternatives jsonb, p_alternative_images jsonb, p_config_alternative_id bigint, p_observation character varying, p_similary text, p_status character varying, p_region character varying, p_university integer, p_year character varying, p_option integer, p_modality integer, p_version character varying, p_area character varying, p_authorship character varying, p_diagrammed boolean, p_created_by bigint, p_cycle_id integer, p_week_id integer, p_type_material_id integer) OWNER TO postgres;

--
