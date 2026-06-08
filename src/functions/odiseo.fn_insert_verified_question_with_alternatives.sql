-- Function: odiseo.fn_insert_verified_question_with_alternatives(integer, character varying, jsonb, integer, integer, character varying, boolean, smallint, smallint, jsonb, integer, integer, integer, character varying, numeric, text, text, jsonb, jsonb, jsonb, bigint, bigint, integer, boolean, jsonb, smallint)

--

CREATE FUNCTION odiseo.fn_insert_verified_question_with_alternatives(pf_course_id integer, p_authorship character varying, p_origin jsonb, p_year integer, pf_parent_id integer, p_question_number character varying, p_diagrammed boolean, pf_topic_id smallint, pf_question_columns smallint, pf_subtopic_ids jsonb, p_type_material_template_id integer, p_week_id integer, pf_level_id integer, p_type_id character varying, p_ter numeric, p_question_text text, p_question_short text, p_question_images jsonb, p_alternatives jsonb, p_alternative_images jsonb, pf_config_alternative_id bigint, pf_created_by bigint, p_teacher_id integer, p_is_from_text boolean, p_question_attributes jsonb, p_priority smallint) RETURNS odiseo.question
    LANGUAGE plpgsql
    AS $$
                            DECLARE
                                v_teacher_id BIGINT;
                                v_question_id question.id%TYPE;
                                v_alternative_id bigint;
                                v_image_question JSONB;
                                v_image_alternative JSONB;
                                v_alternative JSONB;
                                v_subtopic_id INT;
                                v_employee_didi_question_id BIGINT;
                                v_employee_id INT;
                                v_last_number TEXT;
                                v_new_number TEXT;
                                v_new_code TEXT;
                                v_code_course TEXT;
                                v_fl_status TEXT;
                                result question%ROWTYPE;
                                origin JSONB;
                                v_modality_ids SMALLINT[] := ARRAY[]::SMALLINT[]; 
                                v_university_ids SMALLINT[] := ARRAY[]::SMALLINT[]; 
                                v_similary_text TEXT;
                                v_final_status CHAR(4);
                                v_codes_list TEXT;
                                v_obs_desc TEXT;
                                v_status_parent CHAR(4);
                            BEGIN

                                -- Asignación a VARIABLES
                                SELECT code INTO v_code_course FROM course
                                WHERE id = pf_course_id;

                                SELECT e.id INTO v_employee_id
                                FROM employees e
                                INNER JOIN users u
                                ON e.user_id = u.id
                                WHERE u.id = pf_created_by;

                                -- 1.1 GENERAR CÓDIGO NUEVO
                                -- *********************************************************
                                SELECT full_code, number_str 
                                INTO v_new_code, v_new_number
                                FROM fn_generate_question_code(pf_course_id,'P'::VARCHAR);
                                -- *********************************************************

                                --	Verificar si la pregunta tiene duplicados
                                WITH similarity_question AS (
                                    SELECT fsq.id, (fsq.score * 100)::NUMERIC(10,2) as percentage, fsq.code
                                    FROM fn_search_similar_questions(p_question_short, pf_course_id) fsq
                                )
                                SELECT 
                                    COALESCE(jsonb_agg(jsonb_build_object('id', sq.id, 'percentage', percentage))::TEXT, '[]'),
                                    CASE WHEN EXISTS (SELECT 1 FROM similarity_question) THEN 'DUPL' ELSE 'PEND' END,
                                    string_agg(sq.code, ', ' ORDER BY sq.code ASC)
                                INTO v_similary_text, v_final_status, v_codes_list
                                FROM similarity_question sq;

                                IF v_final_status = 'DUPL' THEN
                                    v_obs_desc := 'Tiene similitud con una o varias preguntas: ' || v_codes_list;
                                END IF;

                                IF v_final_status <> 'DUPL' AND v_final_status <> 'PEND' THEN
                                    RAISE EXCEPTION 'Estado inválido. Debe ser PEND o DUPL. Recibió %', v_final_status;
                                END IF;

                                -- Insertar la pregunta
                                INSERT INTO question (
                                    code,
                                    number,
                                    description,
                                    short_description,
                                    number_question,
                                    course_id,
                                    topic_id,
                                    columns,
                                    level_id,
                                    type,
                                    ter,
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
                                    v_new_number,
                                    p_question_text,
                                    p_question_short,
                                    p_question_number,
                                    pf_course_id,
                                    pf_topic_id,
                                    pf_question_columns,
                                    pf_level_id,
                                    p_type_id,
                                    p_ter,
                                    pf_parent_id,
                                    v_final_status,
                                    pf_config_alternative_id,
                                    p_authorship,
                                    p_diagrammed,
                                    p_priority,
                                    pf_created_by,
                                    NOW()
                                )
                                RETURNING id INTO v_question_id;

                                -- Asignar a Employee (Didi, GM o Admin)
                                INSERT INTO employee_didi_question (employee_id, question_id, week, year, created_by, created_at, diagrammed)
                                VALUES (v_employee_id, v_question_id, p_week_id, p_year,
                                        pf_created_by, NOW(), true)
                                RETURNING id INTO v_employee_didi_question_id;

                                -- Asignación a Docente Ghost
                                INSERT INTO employee_question (teacher_id, question_id, week, year, created_by, created_at, solved)
                                VALUES (p_teacher_id, v_question_id, p_week_id, p_year, pf_created_by, NOW(), true);

                                -- Insertar origines de preguntas
                                FOR origin IN SELECT * FROM jsonb_array_elements(p_origin) LOOP

                                    v_modality_ids := array_append(
                                        v_modality_ids,
                                        (origin->>'modality_id')::SMALLINT
                                    );

                                    v_university_ids := array_append(
                                        v_university_ids,
                                        (origin->>'university_id')::SMALLINT
                                    );


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
                                        pf_created_by,
                                        now()
                                    );
                                END LOOP;

                                -- SubTopics
                                FOR v_subtopic_id IN SELECT * FROM jsonb_array_elements(pf_subtopic_ids)
                                LOOP
                                    INSERT INTO question_subtopic (question_id, subtopic_id, created_by, created_at)
                                    VALUES (v_question_id, v_subtopic_id, pf_created_by, now());
                                END LOOP;
                                -- remover duplicados
                                v_modality_ids   := (SELECT ARRAY(SELECT DISTINCT unnest(v_modality_ids)));
                                v_university_ids := (SELECT ARRAY(SELECT DISTINCT unnest(v_university_ids)));

                                PERFORM odiseo.fn_change_subtopic_frequent_status(
                                    uc.university_id::int,
                                    uc.subtopic_id::int,
                                    pf_created_by::int,
                                    true,
                                    'system'
                                )
                                FROM (
                                    SELECT DISTINCT 
                                        u.university_id,
                                        s.subtopic_id::INTEGER AS subtopic_id
                                    FROM unnest(v_modality_ids) AS m(modality_id)  
                                    JOIN modality mo 
                                        ON mo.id = m.modality_id
                                    AND mo.fl_allows_mark_frequent_topic = TRUE
                                    CROSS JOIN unnest(v_university_ids) AS u(university_id)
                                    CROSS JOIN jsonb_array_elements(pf_subtopic_ids) AS s(subtopic_id)
                                ) AS uc;

                                -- Insertar las imágenes de la pregunta
                                FOR v_image_question IN SELECT * FROM jsonb_array_elements(p_question_images) LOOP
                                    INSERT INTO question_image (code, extension, image, question_id, created_by, created_at)
                                    VALUES (
                                        v_image_question->>'code',
                                        v_image_question->>'extension',
                                        v_image_question->>'image',
                                        v_question_id,
                                        pf_created_by,
                                        NOW()
                                    );
                                END LOOP;
                                --
                                -- Insertar las imágenes de alternativas
                                FOR v_image_alternative IN SELECT * FROM jsonb_array_elements(p_alternative_images) LOOP
                                    INSERT INTO question_image (code, extension, image, question_id, created_by, created_at)
                                    VALUES (
                                        v_image_alternative->>'code',
                                        v_image_alternative->>'extension',
                                        v_image_alternative->>'image',
                                        v_question_id,
                                        pf_created_by,
                                        NOW()
                                    );
                                END LOOP;
                                --
                                -- Insertar las alternativas y actualizar el ID de la respuesta si es 100
                                FOR v_alternative IN SELECT * FROM jsonb_array_elements(p_alternatives) LOOP
                                    INSERT INTO alternative (description, question_id, created_by, created_at)
                                    VALUES (v_alternative->>'value', v_question_id, pf_created_by, now())
                                    RETURNING id INTO v_alternative_id;

                                    -- Si el answer es igual a 100, almacenar el ID de la alternativa en la pregunta
                                    IF v_alternative->>'answer' = '100' THEN
                                        UPDATE question
                                        SET answer_id = v_alternative_id
                                        WHERE id = v_question_id;
                                    END IF;
                                END LOOP;
                                --
                                IF pf_parent_id IS NOT NULL THEN
                                    -- Si el estado del padre ya es duplicado ya no es necesario validar las subpreguntas
                                    SELECT pq.status INTO v_status_parent FROM parent_question pq WHERE pq.id = pf_parent_id;
                                        IF v_status_parent = 'DUPL' THEN	
                                            UPDATE question set status = v_status_parent WHERE id = v_question_id;
                                        ELSE
                                            --	Verificar si la subpregunta tiene duplicados
                                            WITH similarity_question AS (
                                                SELECT fsq.id, (fsq.score * 100)::NUMERIC(10,2) as percentage, fsq.code
                                                FROM fn_search_similar_sub_question(p_question_short, pf_parent_id, v_question_id) fsq
                                            )
                                            SELECT 
                                                COALESCE(jsonb_agg(jsonb_build_object('id', sq.id, 'percentage', percentage))::TEXT, '[]'),
                                                CASE WHEN EXISTS (SELECT 1 FROM similarity_question) THEN 'DUPL' ELSE 'PEND' END,
                                                string_agg(sq.code, ', ' ORDER BY sq.code ASC)
                                            INTO v_similary_text, v_final_status, v_codes_list
                                            FROM similarity_question sq;
                            
                                            IF v_final_status = 'DUPL' THEN
                                                v_obs_desc := 'Tiene similitud con una o varias preguntas: ' || v_codes_list;
                                                -- Si existen subpreguntas duplicadas entonces el texto tambien pasa a duplicado
                                                UPDATE parent_question SET status = v_final_status WHERE id = pf_parent_id;	
                                                -- Tambien actualizar la pregunta actual
                                                UPDATE question set status = v_final_status WHERE id = v_question_id;	
                                            ELSE
                                                UPDATE question set status = v_final_status WHERE id = v_question_id;
                                            END IF;
                                        END IF;
                                END IF;

                                IF p_question_attributes IS NOT NULL THEN
                                    p_question_attributes := COALESCE(p_question_attributes::jsonb, '[]'::jsonb);

                                    -- Insertar atributos que no existen
                                    INSERT INTO question_attributes (
                                        question_id,
                                        question_attributes_type_id,
                                        value,
                                        created_by,
                                        created_at
                                    )
                                    SELECT
                                        v_question_id,
                                        (attr->>'question_attribute_type_id')::INT,
                                        attr->>'value',
                                        pf_created_by,
                                        now()
                                    FROM jsonb_array_elements(p_question_attributes) AS attr
                                    WHERE NOT EXISTS (
                                        SELECT 1
                                        FROM question_attributes qa
                                        WHERE qa.question_id = v_question_id
                                        AND qa.question_attributes_type_id =
                                            (attr->>'question_attribute_type_id')::INT
                                        AND qa.deleted_at IS NULL
                                    );

                                    -- Actualizar si cambió el value
                                    UPDATE question_attributes qa
                                    SET
                                        value = attr->>'value',
                                        updated_by = pf_created_by,
                                        updated_at = now()
                                    FROM jsonb_array_elements(p_question_attributes) AS attr
                                    WHERE qa.question_id = v_question_id
                                    AND qa.question_attributes_type_id =
                                        (attr->>'question_attribute_type_id')::INT
                                    AND qa.deleted_at IS NULL
                                    AND qa.value IS DISTINCT FROM attr->>'value';

                                    -- Soft delete de atributos que ya no vienen
                                    UPDATE question_attributes qa
                                    SET
                                        deleted_by = pf_created_by,
                                        deleted_at = now()
                                    WHERE qa.question_id = v_question_id
                                    AND qa.deleted_at IS NULL
                                    AND qa.question_attributes_type_id NOT IN (
                                        SELECT (attr->>'question_attribute_type_id')::INT
                                        FROM jsonb_array_elements(p_question_attributes) AS attr
                                    );

                                END IF;

                                -- Insertar observación si p_observation no es NULL ni vacío
                                IF v_final_status = 'DUPL' THEN
                                    INSERT INTO question_observation
                                    (description, similitaries, question_id, type, fl_status, created_by, created_at)
                                    VALUES
                                    (v_obs_desc, v_similary_text, v_question_id, 'DUPL', true, pf_created_by, now());
                                END IF;
                                --

                                SELECT * INTO result FROM question WHERE id = v_question_id LIMIT 1;

                                IF (
                                    1 = 1
                                    AND result.topic_id IS NOT NULL
                                    AND EXISTS (SELECT 1 FROM jsonb_array_elements(pf_subtopic_ids))
                                    AND result.level_id IS NOT NULL
                                    AND result.answer_id IS NOT NULL
                                    AND result.status = 'PEND'
                                ) THEN
                                    UPDATE question
                                    SET status = CASE 
                                                    WHEN p_is_from_text IS TRUE THEN 'VERI'
                                                    ELSE 'DIGI'
                                                END
                                    WHERE id = v_question_id;
                                END IF;

                                SELECT * INTO result FROM question WHERE id = v_question_id LIMIT 1;

                                RETURN result;
                            END;
                            $$;


ALTER FUNCTION odiseo.fn_insert_verified_question_with_alternatives(pf_course_id integer, p_authorship character varying, p_origin jsonb, p_year integer, pf_parent_id integer, p_question_number character varying, p_diagrammed boolean, pf_topic_id smallint, pf_question_columns smallint, pf_subtopic_ids jsonb, p_type_material_template_id integer, p_week_id integer, pf_level_id integer, p_type_id character varying, p_ter numeric, p_question_text text, p_question_short text, p_question_images jsonb, p_alternatives jsonb, p_alternative_images jsonb, pf_config_alternative_id bigint, pf_created_by bigint, p_teacher_id integer, p_is_from_text boolean, p_question_attributes jsonb, p_priority smallint) OWNER TO postgres;

--
