-- Function: questions.fn_indexar_question_teacher(integer, integer, json, integer, integer, character varying, numeric, character varying, jsonb, integer, character varying, integer, jsonb, jsonb)

--

CREATE FUNCTION questions.fn_indexar_question_teacher(p_id integer, p_topic_id integer, p_subtopics json, p_level_id integer, p_alternative_id integer, p_type character varying, p_ter numeric, p_editor_content character varying, p_editor_images jsonb, p_updated_by integer, p_status character varying, p_course_id integer, p_question_attributes jsonb, p_essential_knowledges jsonb) RETURNS TABLE(new_question_id integer, new_status character varying, v_url_pdf character varying)
    LANGUAGE plpgsql
    AS $$
                    DECLARE
                        v_subtopic_id INT;
                        v_new_subtopics_ids INT[];
                        v_existing_subtopic_ids INT[];
                        v_subtopics_delete INT[];
                        v_employee_question_id INT;
                        v_editor_image JSONB;
                        v_parent_id INT;
                        v_type_text_template_id INT;
                        v_question_attributes jsonb;

                        v_current_course_id INT;
                        v_current_type character varying;
                        v_new_code character varying;
                        v_new_number character varying;
                        v_category character varying;
                        BEGIN
                            new_status := (SELECT status FROM question WHERE id = p_id);

                            SELECT c.type_text_template_id, q.parent_id INTO v_type_text_template_id, v_parent_id FROM question q
                            JOIN course c ON c.id = q.course_id
                            WHERE q.id = p_id;

                            SELECT course_id, type INTO v_current_course_id, v_current_type FROM question WHERE id = p_id;
                            
                            IF p_course_id IS NOT NULL AND p_course_id <> v_current_course_id THEN
                                IF v_current_type = 'TEXTO' THEN 
                                    v_category := 'T';
                                ELSE
                                    v_category := 'P';
                                END IF;
                                
                                SELECT full_code, number_str 
                                INTO v_new_code, v_new_number
                                FROM questions.fn_generate_question_code(p_course_id, v_category);
                            END IF;

                            v_new_subtopics_ids := ARRAY(SELECT json_array_elements_text(p_subtopics)::INT);


                            -- Eliminar los subtemas que no encuentra
                            UPDATE question_subtopic
                            SET fl_status = false, deleted_by = p_updated_by, deleted_at = now()
                            WHERE question_id = p_id
                            AND subtopic_id NOT IN (SELECT unnest(v_new_subtopics_ids));

                            SELECT eq.id
                            INTO v_employee_question_id
                            FROM employee_question eq
                            WHERE eq.fl_status = TRUE  AND eq.deleted_at  IS NULL AND eq.question_id = p_id;

                            -- Consultar los IDs existentes en question_subtopic
                            v_existing_subtopic_ids := ARRAY(
                                SELECT subtopic_id
                                FROM question_subtopic
                                WHERE subtopic_id = ANY(v_new_subtopics_ids)
                                AND question_id = p_id
                                AND fl_status = true
                            );

                            -- Eliminar los IDs existentes de la lista de nuevos IDs
                            v_new_subtopics_ids := ARRAY(
                                SELECT unnest(v_new_subtopics_ids)
                                EXCEPT
                                SELECT unnest(v_existing_subtopic_ids)
                            );

                            -- Insertar los nuevos IDs que no están en la tabla
                            FOREACH v_subtopic_id IN ARRAY v_new_subtopics_ids
                            LOOP
                                INSERT INTO question_subtopic (question_id, subtopic_id, created_by, created_at)
                                VALUES (p_id, v_subtopic_id, p_updated_by, now());
                            END LOOP;

                            IF v_parent_id IS NOT NULL THEN
                                IF v_type_text_template_id = 2 THEN
                                    new_status := 'INDE';
                                END IF;
                                IF v_type_text_template_id = 3 THEN
                                    IF p_topic_id IS NOT NULL AND
                                        p_alternative_id IS NOT NULL AND
                                        p_status = 'INDE' THEN
                                            new_status  := 'INDE';
                                    END IF;
                                END IF;
                            ELSE
                                IF p_topic_id IS NOT NULL AND
                                    p_alternative_id IS NOT NULL AND
                                    p_status = 'INDE' THEN
                                        new_status  := 'INDE';
                                END IF;
                            END IF;

                            UPDATE question
                            SET
                                topic_id = COALESCE(p_topic_id, topic_id),
                                subtopic_id = null,
                                level_id = COALESCE(p_level_id, level_id),
                                answer_id = COALESCE(p_alternative_id, answer_id),
                                type = COALESCE(p_type, type),
                                ter = COALESCE(p_ter, ter),
                                status = new_status,
                                updated_by = p_updated_by,
                                updated_at = now(),
                                course_id = p_course_id,
                                code = COALESCE(v_new_code, code),  
                                number = COALESCE(v_new_number, number)
                            WHERE
                                id = p_id
                                RETURNING id, status, url_pdf INTO new_question_id, new_status, v_url_pdf;

                            IF p_editor_content IS NOT NULL AND v_employee_question_id IS NOT NULL THEN
                                UPDATE employee_question e_q
                                SET editor_content = p_editor_content
                                WHERE e_q.id = v_employee_question_id AND e_q.fl_status = true;
                                IF p_editor_images IS NOT NULL THEN
                                    FOR v_editor_image IN SELECT * FROM jsonb_array_elements(p_editor_images) LOOP
                                        INSERT INTO employee_question_image (code, extension, image, employee_question_id, created_by, created_at)
                                        VALUES (v_editor_image->>'code', v_editor_image->>'extension', v_editor_image->>'image',v_employee_question_id, p_updated_by, now());
                                    END LOOP;
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
                                    p_id,
                                    (attr->>'question_attribute_type_id')::INT,
                                    attr->>'value',
                                    p_updated_by,
                                    now()
                                FROM jsonb_array_elements(p_question_attributes) AS attr
                                WHERE NOT EXISTS (
                                    SELECT 1
                                    FROM question_attributes qa
                                    WHERE qa.question_id = p_id
                                    AND qa.question_attributes_type_id =
                                        (attr->>'question_attribute_type_id')::INT
                                    AND qa.deleted_at IS NULL
                                );

                                -- Actualizar si cambió el value
                                UPDATE question_attributes qa
                                SET
                                    value = attr->>'value',
                                    updated_by = p_updated_by,
                                    updated_at = now()
                                FROM jsonb_array_elements(p_question_attributes) AS attr
                                WHERE qa.question_id = p_id
                                AND qa.question_attributes_type_id =
                                    (attr->>'question_attributes_type_id')::INT
                                AND qa.deleted_at IS NULL
                                AND qa.value IS DISTINCT FROM attr->>'value';

                                -- Soft delete de atributos que ya no vienen
                                UPDATE question_attributes qa
                                SET
                                    deleted_by = p_updated_by,
                                    deleted_at = now()
                                WHERE qa.question_id = p_id
                                AND qa.deleted_at IS NULL
                                AND qa.question_attributes_type_id NOT IN (
                                    SELECT (attr->>'question_attributes_type_id')::INT
                                    FROM jsonb_array_elements(p_question_attributes) AS attr
                                );

                            END IF;

                            IF p_essential_knowledges IS NOT NULL THEN

                                WITH incoming_essential_knowledges AS (
                                    SELECT DISTINCT value::bigint AS id
                                    FROM jsonb_array_elements_text(
                                        COALESCE(p_essential_knowledges, '[]'::jsonb)
                                    ) AS items(value)
                                ),

                                restored_essential_knowledges AS (
                                    UPDATE essential_knowledge_questions ekq
                                    SET
                                        deleted_at = NULL,
                                        deleted_by = NULL,
                                        updated_at = now(),
                                        updated_by = p_updated_by
                                    FROM incoming_essential_knowledges incoming
                                    WHERE ekq.question_id = p_id
                                    AND ekq.essential_knowledge_id = incoming.id
                                    AND ekq.deleted_at IS NOT NULL
                                    RETURNING ekq.id
                                ),

                                new_essential_knowledges AS (
                                    INSERT INTO essential_knowledge_questions (
                                        question_id,
                                        essential_knowledge_id,
                                        created_by,
                                        created_at
                                    )
                                    SELECT
                                        p_id,
                                        incoming.id,
                                        p_updated_by,
                                        now()
                                    FROM incoming_essential_knowledges incoming
                                    WHERE NOT EXISTS (
                                        SELECT 1
                                        FROM essential_knowledge_questions ekq
                                        WHERE ekq.question_id = p_id
                                        AND ekq.essential_knowledge_id = incoming.id
                                    )
                                    RETURNING id
                                )

                                UPDATE essential_knowledge_questions ekq
                                SET
                                    deleted_at = now(),
                                    deleted_by = p_updated_by
                                WHERE ekq.question_id = p_id
                                AND ekq.deleted_at IS NULL
                                AND NOT EXISTS (
                                    SELECT 1
                                    FROM incoming_essential_knowledges incoming
                                    WHERE incoming.id = ekq.essential_knowledge_id
                                );

                            END IF;

                            RETURN NEXT;
                        END;
            $$;


ALTER FUNCTION questions.fn_indexar_question_teacher(p_id integer, p_topic_id integer, p_subtopics json, p_level_id integer, p_alternative_id integer, p_type character varying, p_ter numeric, p_editor_content character varying, p_editor_images jsonb, p_updated_by integer, p_status character varying, p_course_id integer, p_question_attributes jsonb, p_essential_knowledges jsonb) OWNER TO postgres;

--
