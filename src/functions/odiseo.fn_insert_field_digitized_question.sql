-- Function: odiseo.fn_insert_field_digitized_question(bigint, jsonb, jsonb, bigint)

--

CREATE FUNCTION odiseo.fn_insert_field_digitized_question(p_question_id bigint, p_field_diagram jsonb, p_image jsonb, p_user bigint) RETURNS TABLE(result_id bigint, result_employee_didi_question_id bigint, result_setting_diagrammed_course_id bigint, result_value text, result_created_by bigint, result_created_at timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_didi_question_id BIGINT;  -- Variable para almacenar el ID de employee_didi_question
            v_field JSONB;              -- Variable para cada elemento del JSONB array
            v_element JSONB;            -- Variable para iterar sobre p_image
        BEGIN
            -- Actualizar registro en la tabla employee_didi_question
            UPDATE odiseo.employee_didi_question
            SET updated_by = p_user, updated_at = NOW()
            WHERE question_id = p_question_id AND fl_status = true;
        
            -- Obtener el ID de la pregunta actualizada
            SELECT edq.id
            INTO v_didi_question_id
            FROM odiseo.employee_didi_question edq
            WHERE edq.question_id = p_question_id AND edq.fl_status = true;
        
            -- Iterar sobre el JSONB array p_image
            FOR v_element IN
                SELECT jsonb_array_elements(p_image)
            LOOP
                INSERT INTO odiseo.employee_didi_question_field_image (
                    employee_didi_question_id,
                    code,
                    extension,
                    image,
                    created_by,
                    created_at
                )
                VALUES (
                    v_didi_question_id,
                    v_element->>'code',        -- Extraer el valor de 'code'
                    v_element->>'extension',   -- Extraer el valor de 'extension'
                    v_element->>'image',       -- Extraer el valor de 'image'
                    p_user,                    -- Usuario que crea el registro
                    NOW()                      -- Fecha de creación
                );
            END LOOP;
        
            -- Insertar en employee_didi_question_field y retornar filas
            RETURN QUERY
            WITH inserted AS (
                INSERT INTO odiseo.employee_didi_question_field (
                    employee_didi_question_id,
                    setting_diagrammed_course_id,
                    value,
                    created_by,
                    created_at
                )
                SELECT 
                    v_didi_question_id,
                    (field->>'id')::bigint,
                    field->>'description',
                    p_user,
                    NOW()
                FROM jsonb_array_elements(p_field_diagram) AS field
                RETURNING 
                    id AS result_id,
                    employee_didi_question_id AS result_employee_didi_question_id,
                    setting_diagrammed_course_id AS result_setting_diagrammed_course_id,
                    value AS result_value,
                    created_by AS result_created_by,
                    created_at AS result_created_at
            )
            SELECT * FROM inserted;
        
        END;
        $$;


ALTER FUNCTION odiseo.fn_insert_field_digitized_question(p_question_id bigint, p_field_diagram jsonb, p_image jsonb, p_user bigint) OWNER TO postgres;

--
