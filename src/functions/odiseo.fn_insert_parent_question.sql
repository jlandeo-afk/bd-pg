-- Function: odiseo.fn_insert_parent_question(character varying, character varying, text, text, text, text, jsonb, jsonb, character varying, boolean, bigint, integer, text, text, integer, integer, character, smallint)

--

CREATE FUNCTION odiseo.fn_insert_parent_question(p_code_course character varying, p_num_problem character varying, p_question_text text, p_short_question_text text, p_question_traduction_text text, p_short_question_traduction_text text, p_question_images jsonb, p_origin jsonb, p_authorship character varying, p_diagrammed boolean, p_created_by bigint, p_type_text integer, p_description_b text, p_description_short_b text, p_level integer, p_type_text_subcategory_id integer, p_status character, p_priority smallint) RETURNS TABLE(parent_id bigint, description text, short_description text, code character varying, status character varying, course_id smallint)
    LANGUAGE plpgsql
    AS $$
                                DECLARE
                                    parent_question_id bigint;
                                    v_course_id bigint;
                                    v_last_number TEXT;
                                    v_new_number TEXT;
                                    v_new_code TEXT;
                                    origin JSONB;
                                    v_similary_text TEXT;
                                    v_final_status CHAR(4);
                                    v_codes_list TEXT;
                                    v_obs_desc TEXT;
                                BEGIN
                                    -- Obteniendo el id del curso
                                    SELECT id
                                    INTO v_course_id
                                    FROM course c
                                    WHERE c.code = p_code_course;

                                    -- 1.1 GENERAR CÓDIGO NUEVO
                                    -- *********************************************************
                                    SELECT full_code, number_str 
                                    INTO v_new_code, v_new_number
                                    FROM fn_generate_question_code(v_course_id::INTEGER,'T'::VARCHAR);
                                    -- *********************************************************

                                    --	Verificar si la pregunta tiene duplicados
                                    WITH similarity_question AS (
                                        SELECT fsp.id, (fsp.score * 100)::NUMERIC(10,2) as percentage, fsp.code
                                        FROM fn_search_similar_parent_questions(p_short_question_text, v_course_id) fsp
                                    )
                                    SELECT 
                                        COALESCE(jsonb_agg(jsonb_build_object('id', sq.id, 'percentage', sq.percentage))::TEXT, '[]'),
                                        CASE WHEN EXISTS (SELECT 1 FROM similarity_question) THEN 'DUPL' ELSE p_status END,
                                        string_agg(sq.code, ', ' ORDER BY sq.code ASC)
                                    INTO v_similary_text, v_final_status, v_codes_list
                                    FROM similarity_question sq;

                                    IF v_final_status = 'DUPL' THEN
                                        v_obs_desc := 'Tiene similitud con una o varias preguntas: ' || v_codes_list;
                                    END IF;

                                    -- Insertar la pregunta
                                    INSERT INTO parent_question (
                                        code,
                                        description,
                                        short_description,
                                        text_traduction,
                                        short_text_traduction,
                                        number_question,
                                        number,
                                        course_id,
                                        status,
                                        authorship,
                                        fl_diagrammed,
                                        created_by,
                                        created_at,
                                        type_text_id,
                                        description_b,
                                        short_description_b,
                                        level_id,
                                        type_text_subcategory_id,
                                        priority
                                    )
                                    VALUES (
                                        v_new_code,
                                        p_question_text,
                                        p_short_question_text,
                                        p_question_traduction_text,
                                        p_short_question_traduction_text,
                                        p_num_problem,
                                        v_new_number,
                                        v_course_id,
                                        v_final_status,
                                        p_authorship,
                                        p_diagrammed,
                                        p_created_by,
                                        now(),
                                        p_type_text,
                                        p_description_b,
                                        p_description_short_b,
                                        p_level,
                                        p_type_text_subcategory_id,
                                        p_priority
                                    )
                                    RETURNING id INTO parent_question_id;

                                    -- Insertar las imágenes de la pregunta
                                    INSERT INTO parent_image (code, extension, image, parent_id, created_by, created_at)
                                    SELECT image_question->>'code', image_question->>'extension', image_question->>'image', parent_question_id, p_created_by, now()
                                    FROM jsonb_array_elements(p_question_images) AS image_question;

                                    -- Insertar observación si p_observation no es NULL ni vacío
                                    IF v_final_status = 'DUPL' THEN
                                        INSERT INTO parent_observation (
                                            description,
                                            similitaries,
                                            parent_id,
                                            type,
                                            fl_status,
                                            created_by,
                                            created_at
                                        )
                                        VALUES (
                                            v_obs_desc,
                                            v_similary_text,
                                            parent_question_id,
                                            'DUPL',
                                            true,
                                            p_created_by, now()
                                        );
                                        --	Si es que el padre esta duplicado en este caso los hijos tambien
                                        UPDATE question set status = v_final_status WHERE question.parent_id = parent_question_id;
                                    END IF;

                                    -- Insertar los origenes de la pregunta
                                    FOR origin IN SELECT * FROM jsonb_array_elements(p_origin) LOOP
                                        INSERT INTO origin_parent_question (
                                            parent_id,
                                            year,
                                            region_id,
                                            modality_option_id,
                                            areas,
                                            version,
                                            created_by,
                                            created_at
                                        )
                                        VALUES (
                                            parent_question_id,
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
                                    SELECT pq.id parent_id, pq.description, pq.short_description, pq.code, pq.status, pq.course_id
                                    FROM parent_question pq WHERE pq.id = parent_question_id;
                                END;
                                $$;


ALTER FUNCTION odiseo.fn_insert_parent_question(p_code_course character varying, p_num_problem character varying, p_question_text text, p_short_question_text text, p_question_traduction_text text, p_short_question_traduction_text text, p_question_images jsonb, p_origin jsonb, p_authorship character varying, p_diagrammed boolean, p_created_by bigint, p_type_text integer, p_description_b text, p_description_short_b text, p_level integer, p_type_text_subcategory_id integer, p_status character, p_priority smallint) OWNER TO postgres;

--
