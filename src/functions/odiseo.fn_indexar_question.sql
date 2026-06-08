-- Function: odiseo.fn_indexar_question(integer, integer, json, integer, integer, character varying, numeric, character varying, integer, character varying, integer)

--

CREATE FUNCTION odiseo.fn_indexar_question(p_id integer, p_topic_id integer, p_subtopics json, p_level_id integer, p_alternative_id integer, p_type character varying, p_ter numeric, p_editor_content character varying, p_updated_by integer, p_status character varying, p_employee_question_id integer DEFAULT NULL::integer) RETURNS TABLE(new_question_id integer, new_status character varying, v_url_pdf character varying)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_subtopic_id INT;
            v_new_subtopics_ids INT[];
            v_existing_subtopic_ids INT[];
            v_subtopics_delete INT[];
        BEGIN
            new_status := (SELECT status FROM odiseo.question WHERE id = p_id);

            v_new_subtopics_ids := ARRAY(SELECT json_array_elements_text(p_subtopics)::INT);

            -- Eliminar los subtemas que no encuentra
            UPDATE odiseo.question_subtopic
            SET fl_status = false, deleted_by = p_updated_by, deleted_at = now()
            WHERE question_id = p_id
            AND subtopic_id NOT IN (SELECT unnest(v_new_subtopics_ids));

            -- Consultar los IDs existentes en odiseo.question_subtopic
            v_existing_subtopic_ids := ARRAY(
                SELECT subtopic_id
                FROM odiseo.question_subtopic
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
                INSERT INTO odiseo.question_subtopic (question_id, subtopic_id, created_by, created_at)
                VALUES (p_id, v_subtopic_id, p_updated_by, now());
            END LOOP;

            IF p_topic_id IS NOT NULL AND
                p_level_id IS NOT NULL AND
                p_alternative_id IS NOT NULL AND
                p_type IS NOT NULL AND
                p_ter IS NOT NULL AND
                p_status = 'INDEX' THEN
                    new_status  := 'INDE';
            END IF;

            UPDATE odiseo.question
            SET
                topic_id = COALESCE(p_topic_id, topic_id),
                subtopic_id = null,
                level_id = COALESCE(p_level_id, level_id),
                answer_id = COALESCE(p_alternative_id, answer_id),
                type = COALESCE(p_type, type),
                ter = COALESCE(p_ter, ter),
                status = new_status,
                updated_by = p_updated_by,
                updated_at = now()
            WHERE
                id = p_id
                RETURNING id, status, url_pdf INTO new_question_id, new_status, v_url_pdf;
            
            IF p_editor_content IS NOT NULL AND p_employee_question_id IS NOT NULL THEN
                UPDATE odiseo.employee_question e_q
                SET editor_content = p_editor_content
                WHERE e_q.id = p_employee_question_id AND e_q.fl_status = true;
            END IF;

            RETURN NEXT;
        END;
        $$;


ALTER FUNCTION odiseo.fn_indexar_question(p_id integer, p_topic_id integer, p_subtopics json, p_level_id integer, p_alternative_id integer, p_type character varying, p_ter numeric, p_editor_content character varying, p_updated_by integer, p_status character varying, p_employee_question_id integer) OWNER TO postgres;

--
