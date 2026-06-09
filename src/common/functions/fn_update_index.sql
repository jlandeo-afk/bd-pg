-- Function: common.fn_update_index(integer, integer, integer, integer, character varying, numeric, integer, integer, jsonb)

--

CREATE FUNCTION common.fn_update_index(p_id integer, p_topic_id integer, p_subtopic_id integer, p_level_id integer, p_type character varying, p_ter numeric, p_updated_by integer, p_course_id integer, p_question_attributes jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        v_row_question question%ROWTYPE;
        v_history_description TEXT;
        v_course_id integer;
        v_type_text_template_id integer;

        v_current_type character varying;
        v_new_code character varying;
        v_new_number character varying;
        v_category character varying;
    BEGIN

        -- Busco el curso 

         WITH course_data AS (
            SELECT c.id,c.type_text_template_id
            FROM question q
            INNER JOIN course c 
                ON c.id = q.course_id
                AND c.fl_status = true
                AND c.deleted_at IS NULL
            WHERE q.id = p_id
        )

        SELECT id, type_text_template_id INTO v_course_id, v_type_text_template_id FROM course_data;

        IF p_course_id IS NOT NULL AND p_course_id <> v_course_id THEN
            IF v_current_type = 'TEXTO' THEN 
                v_category := 'T';
            ELSE
                v_category := 'P';
            END IF;
            
            SELECT full_code, number_str 
            INTO v_new_code, v_new_number
            FROM fn_generate_question_code(p_course_id, v_category);
        END IF;

        
        IF p_question_attributes IS NOT NULL THEN

            -- 1. INSERT: Agregar los que no existen
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
                (attr->>'value')::VARCHAR,
                p_updated_by,
                NOW()
            FROM jsonb_array_elements(p_question_attributes) AS attr
            WHERE attr->>'question_attribute_type_id' IS NOT NULL
            AND NOT EXISTS (
                SELECT 1
                FROM question_attributes qa
                WHERE qa.question_id = p_id
                AND qa.question_attributes_type_id = (attr->>'question_attribute_type_id')::INT
                AND qa.deleted_at IS NULL
            );

            -- 2. UPDATE: Actualizar si el valor cambió
            UPDATE question_attributes qa
            SET
                value = (attr->>'value')::VARCHAR,
                updated_by = p_updated_by,
                updated_at = NOW()
            FROM jsonb_array_elements(p_question_attributes) AS attr
            WHERE qa.question_id = p_id
            AND qa.question_attributes_type_id = (attr->>'question_attribute_type_id')::INT
            AND qa.deleted_at IS NULL
            AND qa.value IS DISTINCT FROM (attr->>'value')::VARCHAR;

            -- 3. SOFT DELETE: Eliminar los que ya no vienen en el JSON
            UPDATE question_attributes qa
            SET
                deleted_by = p_updated_by,
                deleted_at = NOW()
            WHERE qa.question_id = p_id
            AND qa.deleted_at IS NULL
            AND qa.question_attributes_type_id NOT IN (
                SELECT (attr->>'question_attribute_type_id')::INT
                FROM jsonb_array_elements(p_question_attributes) AS attr
                WHERE attr->>'question_attribute_type_id' IS NOT NULL
            );

        END IF;

        -- Vlaido si es tipo 2 que permita nulos si es tipo 3 que actualice     
        IF v_type_text_template_id = 2 THEN
            RETURN;
        END IF;
           
        -- Actualizar los datos indexados
        UPDATE question
        SET topic_id = COALESCE(p_topic_id, topic_id),
            subtopic_id = null,
            level_id = COALESCE(p_level_id, level_id),
            type = COALESCE(p_type, type),
            ter = COALESCE(p_ter, ter),
            updated_by = p_updated_by,
            updated_at = now(),
            course_id = p_course_id,
            code = COALESCE(v_new_code, code),
            number = COALESCE(v_new_number, number)
        WHERE id = p_id;

        -- Actualiza question_subtopic
        UPDATE question_subtopic
        SET subtopic_id = p_subtopic_id,
            updated_by = p_updated_by,
            updated_at = now()
        WHERE question_id = p_id;

        -- Si no encuentra la relación, la inserta
        IF NOT FOUND THEN
            INSERT INTO question_subtopic (question_id, subtopic_id, created_by, created_at, updated_by, updated_at)
            VALUES (p_id, p_subtopic_id, p_updated_by, now(), p_updated_by, now());
        END IF;

        SELECT * INTO v_row_question FROM question WHERE id = p_id;

        IF (
            1 = 1
            AND v_row_question.topic_id IS NOT NULL
            AND EXISTS (
                SELECT 1 FROM question_subtopic qs1
                WHERE qs1.question_id = v_row_question.id AND qs1.fl_status AND qs1.deleted_at IS NULL
            )
            AND v_row_question.level_id IS NOT NULL
            AND v_row_question.answer_id IS NOT NULL
            AND v_row_question.type IS NOT NULL
            AND v_row_question.ter IS NOT NULL
            AND v_row_question.status = 'PEND'
        ) THEN
            UPDATE question
            SET status = 'VERI'
            WHERE id = v_row_question.id;

            UPDATE question_status
            SET fl_active = false
            WHERE question_id = v_row_question.id;

            v_history_description := CONCAT(
                'Atributos de indexación completos, la pregunta se cambió a verificado por el usuario <span class=\"text-teacher\">',
                (SELECT u.user FROM users u WHERE u.id = p_updated_by LIMIT 1),
                '</span>'
            );

            INSERT INTO question_status (question_id, status, process, description, created_by, created_at)
            VALUES (v_row_question.id, 'VERI',
                    'VERIFICADO', v_history_description, p_updated_by, NOW());
        END IF;
    END;
    $$;


ALTER FUNCTION common.fn_update_index(p_id integer, p_topic_id integer, p_subtopic_id integer, p_level_id integer, p_type character varying, p_ter numeric, p_updated_by integer, p_course_id integer, p_question_attributes jsonb) OWNER TO postgres;

--
