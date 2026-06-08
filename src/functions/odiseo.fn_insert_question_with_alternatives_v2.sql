-- Function: odiseo.fn_insert_question_with_alternatives_v2(character varying, character varying, smallint, smallint, text, text, integer, jsonb, jsonb, jsonb, bigint, jsonb, character varying, boolean, bigint, integer, integer, smallint)

--

CREATE FUNCTION odiseo.fn_insert_question_with_alternatives_v2(p_code_course character varying, p_num_problem character varying, p_topic_id smallint, p_question_columns smallint, p_question_text text, p_question_short text, p_parent_id integer, p_question_images jsonb, p_alternatives jsonb, p_alternative_images jsonb, p_config_alternative_id bigint, p_origin jsonb, p_authorship character varying, p_diagrammed boolean, p_created_by bigint, p_week_id integer, p_type_material_template_id integer, p_priority smallint) RETURNS TABLE(question_id bigint, description text, short_description text, code character varying, status character varying, course_id smallint, parent_id bigint, alternatives jsonb)
    LANGUAGE plpgsql
    AS $$
                    DECLARE
                        v_question_id bigint;
                        alternative_id bigint;
                        v_course_id bigint;
                        image_question JSONB;
                        image_alternative JSONB;
                        alternative JSONB;
                        origin JSONB;
                        v_last_number TEXT;
                        v_new_number TEXT;
                        v_new_code TEXT;
                        v_similary_text TEXT;
                        v_final_status CHAR(4);
                        v_codes_list TEXT;
                        v_obs_desc TEXT;
                        v_status_parent CHAR(4);
                    BEGIN
                        -- Obteniendo el id del curso
                        SELECT id
                        INTO v_course_id
                        FROM course c
                        WHERE c.code = p_code_course LIMIT 1;

                        -- 1.1 GENERAR CÓDIGO NUEVO
                        -- *********************************************************
                        SELECT full_code, number_str 
                        INTO v_new_code, v_new_number
                        FROM fn_generate_question_code(v_course_id::INTEGER,'P'::VARCHAR);
                        -- *********************************************************

                        --	Verificar si la pregunta tiene duplicados
                        WITH similarity_question AS (
                            SELECT fsq.id, (fsq.score * 100)::NUMERIC(10,2) as percentage, fsq.code
                            FROM fn_search_similar_questions(p_question_short, v_course_id) fsq
                        )
                        SELECT
                            COALESCE(jsonb_agg(jsonb_build_object('id', sq.id, 'percentage', percentage))::TEXT, '[]'),
                            CASE WHEN EXISTS (SELECT 1 FROM similarity_question) THEN 'DUPL' ELSE 'SASI' END,
                            string_agg(sq.code, ', ' ORDER BY sq.code ASC)
                        INTO v_similary_text, v_final_status, v_codes_list
                        FROM similarity_question sq;

                        IF v_final_status = 'DUPL' THEN
                            v_obs_desc := 'Tiene similitud con una o varias preguntas: ' || v_codes_list;
                        END IF;

                        -- Insertar la pregunta
                        INSERT INTO question (
                            code,
                            description,
                            short_description,
                            number_question,
                            number,
                            course_id,
                            topic_id,
                            columns,
                            parent_id,
                            status,
                            config_alternative_id,
                            authorship,
                            fl_diagrammed,
                            priority,
                            created_by,
                            created_at
                        )
                        VALUES (
                            v_new_code,
                            p_question_text,
                            p_question_short,
                            p_num_problem,
                            v_new_number,
                            v_course_id,
                            p_topic_id,
                            p_question_columns,
                            p_parent_id,
                            v_final_status,
                            p_config_alternative_id,
                            p_authorship,
                            p_diagrammed,
                            p_priority,
                            p_created_by,
                            now()
                        )
                        RETURNING id INTO v_question_id;

                        IF p_parent_id IS NOT NULL THEN
                            -- Si el estado del padre ya es duplicado ya no es necesario validar las subpreguntas
                            SELECT pq.status INTO v_status_parent FROM parent_question pq WHERE pq.id = p_parent_id;

                            IF v_status_parent = 'DUPL' THEN
                                UPDATE question set status = v_status_parent WHERE id = v_question_id;
                            ELSE --	Verificar si la subpregunta tiene duplicados
                                WITH similarity_question AS (
                                    SELECT fsq.id, (fsq.score * 100)::NUMERIC(10,2) as percentage, fsq.code
                                    FROM fn_search_similar_sub_question(p_question_short, p_parent_id, v_question_id) fsq
                                )
                                SELECT 
                                    COALESCE(jsonb_agg(jsonb_build_object('id', sq.id, 'percentage', percentage))::TEXT, '[]'),
                                    CASE WHEN EXISTS (SELECT 1 FROM similarity_question) THEN 'DUPL' ELSE 'SASI' END,
                                    string_agg(sq.code, ', ' ORDER BY sq.code ASC)
                                INTO v_similary_text, v_final_status, v_codes_list
                                FROM similarity_question sq;

                                IF v_final_status = 'DUPL' THEN
                                    v_obs_desc := 'Tiene similitud con una o varias preguntas: ' || v_codes_list;
                                    -- Si existen subpreguntas duplicadas entonces el texto tambien pasa a duplicado
                                    UPDATE parent_question SET status = v_final_status WHERE id = p_parent_id;
                                    -- Tambien actualizar la pregunta actual
                                    UPDATE question set status = v_final_status WHERE id = v_question_id;	
                                ELSE
                                    UPDATE question set status = v_final_status WHERE id = v_question_id;
                                END IF;
                            END IF;

                        END IF;

                        -- Insertar las imágenes de la pregunta
                        FOR image_question IN SELECT * FROM jsonb_array_elements(p_question_images) LOOP
                            INSERT INTO question_image (
                                code,
                                extension,
                                image,
                                question_id,
                                created_by,
                                created_at
                            )
                            VALUES (
                                image_question->>'code',
                                image_question->>'extension',
                                image_question->>'image',
                                v_question_id,
                                p_created_by,
                                now()
                            );
                        END LOOP;

                        -- Insertar las imágenes de alternativas
                        FOR image_alternative IN SELECT * FROM jsonb_array_elements(p_alternative_images) LOOP
                            INSERT INTO question_image (
                                code,
                                extension,
                                image,
                                question_id,
                                created_by,
                                created_at
                            )
                            VALUES (
                                image_alternative->>'code',
                                image_alternative->>'extension',
                                image_alternative->>'image',
                                v_question_id,
                                p_created_by,
                                now()
                            );
                        END LOOP;

                        -- Insertar las alternativas y actualizar el ID de la respuesta si es 100
                        FOR alternative IN SELECT * FROM jsonb_array_elements(p_alternatives) LOOP
                            INSERT INTO alternative (
                                description,
                                question_id,
                                created_by,
                                created_at
                            )
                            VALUES (
                                alternative->>'value',
                                v_question_id,
                                p_created_by,
                                now()
                            )
                            RETURNING id INTO alternative_id;

                            -- Si el answer es igual a 100, almacenar el ID de la alternativa en la pregunta
                            IF alternative->>'answer' = '100' THEN
                                UPDATE question
                                SET answer_id = alternative_id
                                WHERE id = v_question_id;
                            END IF;
                        END LOOP;

                        -- Insertar observación si p_observation no es NULL ni vacío
                        IF v_final_status = 'DUPL' THEN
                            INSERT INTO question_observation (
                                description,
                                similitaries,
                                question_id,
                                type,
                                fl_status,
                                created_by,
                                created_at
                            )
                            VALUES (
                                v_obs_desc,
                                v_similary_text,
                                v_question_id,
                                'DUPL',
                                true,
                                p_created_by, now()
                            );
                        END IF;
               
                        -- Insertar los origenes de la pregunta
                        FOR origin IN SELECT * FROM jsonb_array_elements(p_origin) LOOP
                            INSERT INTO origin_question (
                                question_id,
                                year,
                                region_id,
                                modality_option_id,
                                areas,
                                version,
                                created_by,
                                created_at
                            )
                            VALUES (
                                v_question_id,
                                (origin->>'year')::VARCHAR,
                                (origin->>'region_id')::BIGINT,
                                (origin->>'modality_id')::SMALLINT,
                                (origin->>'areas')::VARCHAR,
                                (origin->>'version')::SMALLINT,
                                p_created_by,
                                now()
                            );
                        END LOOP;

                        RETURN QUERY
                        SELECT
                            q.id AS question_id,
                            q.description,
                            q.short_description,
                            q.code,
                            q.status,
                            q.course_id,
                            q.parent_id,
                            COALESCE(
                                (SELECT JSONB_AGG(
                                    JSONB_BUILD_OBJECT(
                                        'id', a.id,
                                        'description', a.description,
                                        'question_id', a.question_id
                                    )
                                )
                                FROM alternative a
                                WHERE a.question_id = q.id
                                    AND a.fl_status = true),
                                '[]'::JSONB
                            ) as alternatives
                        FROM question q
                        WHERE q.id = v_question_id;
                    END;
                    $$;


ALTER FUNCTION odiseo.fn_insert_question_with_alternatives_v2(p_code_course character varying, p_num_problem character varying, p_topic_id smallint, p_question_columns smallint, p_question_text text, p_question_short text, p_parent_id integer, p_question_images jsonb, p_alternatives jsonb, p_alternative_images jsonb, p_config_alternative_id bigint, p_origin jsonb, p_authorship character varying, p_diagrammed boolean, p_created_by bigint, p_week_id integer, p_type_material_template_id integer, p_priority smallint) OWNER TO postgres;

--
