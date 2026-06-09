-- Function: questions.fn_insert_or_update_field_digitized_question(bigint, jsonb, jsonb, bigint)

--

CREATE FUNCTION questions.fn_insert_or_update_field_digitized_question(p_question_id bigint, p_field_diagram jsonb, p_image jsonb, p_user bigint) RETURNS TABLE(result_id bigint, result_employee_didi_question_id bigint, result_diagram_id bigint, result_value text, result_created_by bigint, result_updated_at timestamp without time zone, result_type character varying)
    LANGUAGE plpgsql
    AS $$
                DECLARE
                    v_didi_question_id BIGINT;  -- Variable para almacenar el ID de employee_didi_question
                    v_field JSONB;              -- Variable para cada elemento del JSONB array
                    v_element JSONB;            -- Variable para iterar sobre p_image
                BEGIN

                    PERFORM 1 FROM questions.question WHERE id = p_question_id FOR UPDATE;

                    -- Actualizar registro en la tabla employee_didi_question
                    UPDATE employee_didi_question
                    SET updated_by = p_user, updated_at = NOW()
                    WHERE question_id = p_question_id AND fl_status = true;
                
                    -- Obtener el ID de la pregunta actualizada
                    SELECT edq.id
                    INTO v_didi_question_id
                    FROM employee_didi_question edq
                    WHERE edq.question_id = p_question_id AND edq.fl_status = true;

                    -- Eliminar formulas matemáticas de la diagramación
                    WITH updated_rows_didi_maths AS (
                        SELECT dm.id
                        FROM didi_maths dm
                        INNER JOIN employee_didi_question_field edqf ON edqf.id = dm.didi_question_id
                        WHERE 1 = 1 
                        AND edqf.employee_didi_question_id = v_didi_question_id
                        AND dm.fl_status = true
                    )
                    UPDATE didi_maths dm
                    SET fl_status = false, 
                        deleted_by = p_user,
                        deleted_at = now()
                    FROM updated_rows_didi_maths urdm
                    WHERE dm.id = urdm.id;


                    -- Eliminar imágenes de diagramación
                    UPDATE employee_didi_question_field_image edqfi
                    SET fl_status = FALSE, deleted_by = p_user, deleted_at = NOW()
                    WHERE edqfi.employee_didi_question_id = v_didi_question_id;
                
                    -- Iterar sobre el JSONB array p_image
                    FOR v_element IN
                        SELECT jsonb_array_elements(p_image)
                    LOOP
                        INSERT INTO employee_didi_question_field_image (
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
                
                    -- Insertar o actualizar en employee_didi_question_field y retornar filas
                    RETURN QUERY
                    WITH new_diagrammed_didi_fields AS (
                        INSERT INTO employee_didi_question_field (
                            employee_didi_question_id,
                            setting_diagrammed_course_id,
                            value,
                            created_by,
                            created_at,
                            updated_at
                        ) SELECT
                            v_didi_question_id,
                            ( field->>'id' )::bigint,
                            field->>'description',
                            p_user,
                            NOW(),
                            NOW()
                        FROM JSONB_ARRAY_ELEMENTS( p_field_diagram ) AS field
                        WHERE 1 = 1
                        AND NOT EXISTS( -- Solo inserta si no existen aún campos de diagramación con el mismo id de atributo de diagramación
                            SELECT
                                1
                            FROM employee_didi_question_field
                            WHERE 1 = 1
                            AND employee_didi_question_id = v_didi_question_id
                            AND setting_diagrammed_course_id = ( field->>'id' )::BIGINT
                        )
                        RETURNING 
                            id AS result_id,
                            employee_didi_question_id AS result_employee_didi_question_id,
                            setting_diagrammed_course_id AS diagram_id,
                            value AS result_value,
                            created_by AS result_created_by,
                            created_at AS result_created_at,
                            'create'::CHARACTER varying AS result_type
                    ), updated_diagrammed_didi_field AS (
                        UPDATE employee_didi_question_field edqfu
                            SET
                                value = field->>'description',
                                updated_by = p_user,
                                updated_at = NOW()
                            FROM JSONB_ARRAY_ELEMENTS( p_field_diagram ) AS field
                            WHERE 1 = 1
                            AND edqfu.setting_diagrammed_course_id = ( field->>'id' )::BIGINT
                            AND edqfu.employee_didi_question_id = v_didi_question_id
                            RETURNING 
                                edqfu.id AS result_id,
                                edqfu.employee_didi_question_id AS result_employee_didi_question_id,
                                edqfu.setting_diagrammed_course_id AS result_setting_diagrammed_course_id,
                                edqfu.value AS result_value,
                                edqfu.created_by AS result_created_by,
                                edqfu.updated_at AS updated_at,
                                'update'::CHARACTER varying AS result_type
                    )
                    SELECT * FROM updated_diagrammed_didi_field
                    UNION ALL
                    SELECT * FROM new_diagrammed_didi_fields;
                END;
            $$;


ALTER FUNCTION questions.fn_insert_or_update_field_digitized_question(p_question_id bigint, p_field_diagram jsonb, p_image jsonb, p_user bigint) OWNER TO postgres;

--
