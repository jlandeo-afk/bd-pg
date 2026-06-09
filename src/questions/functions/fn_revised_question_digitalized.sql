-- Function: questions.fn_revised_question_digitalized(bigint, jsonb, jsonb, bigint)

--

CREATE FUNCTION questions.fn_revised_question_digitalized(p_question_id bigint, p_data_diagram jsonb, p_images jsonb, p_user bigint) RETURNS TABLE(result_id bigint, result_value text, result_updated_by bigint, result_updated_at timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
                                        DECLARE
                                            v_employee_didi_question_id bigint;
                                            v_diagram jsonb;
                                            v_image jsonb;
                                        BEGIN
                                            -- Obtener el ID del employee_didi_question correspondiente a la pregunta
                                            SELECT edq.id
                                            INTO v_employee_didi_question_id
                                            FROM employee_didi_question edq
                                            WHERE edq.question_id = p_question_id AND edq.fl_status = true;

                                            -- Eliminar las imágenes antiguas
                                            UPDATE employee_didi_question_field_image
                                            SET fl_status = false,
                                                deleted_by = p_user,
                                                deleted_at = now()
                                            WHERE employee_didi_question_id = v_employee_didi_question_id;

                                            -- Insertar las nuevas imágenes
                                            FOR v_image IN
                                                SELECT * FROM jsonb_array_elements(p_images)
                                            LOOP
                                                INSERT INTO employee_didi_question_field_image(
                                                    employee_didi_question_id,
                                                    code,
                                                    image,
                                                    extension,
                                                    created_by,
                                                    created_at
                                                )
                                                VALUES (
                                                    v_employee_didi_question_id,
                                                    v_image->>'code',
                                                    v_image->>'image',
                                                    v_image->>'extension',
                                                    p_user,
                                                    now()
                                                );
                                            END LOOP;

                                            -- Se inserta los diagramas que no tengan id, ya que son nuevos
                                            WITH diagrams_to_insert AS (
                                                SELECT
                                                    diagram_element->>'value' AS value,
                                                    (diagram_element->>'setting_diagrammed_course_id')::BIGINT AS setting_diagrammed_course_id
                                                FROM jsonb_array_elements(p_data_diagram) AS diagram_element
                                                WHERE diagram_element->>'id' IS NULL
                                            )
                                            INSERT INTO employee_didi_question_field(
                                                employee_didi_question_id, 
                                                setting_diagrammed_course_id, 
                                                value, 
                                                created_by, 
                                                created_at
                                            )
                                            SELECT
                                                v_employee_didi_question_id,
                                                dti.setting_diagrammed_course_id,
                                                dti.value,
                                                p_user,
                                                now()
                                            FROM diagrams_to_insert dti;

                                            -- Eliminar el employee_didi_question que no se enviaron en el array de diagramas
                                            WITH diagrams_to_update AS (
                                                SELECT
                                                    (diagram_element->>'id')::bigint AS id
                                                FROM jsonb_array_elements(p_data_diagram) AS diagram_element
                                            ), existing_diagrams AS (
                                                SELECT edqf.id  
                                                FROM employee_didi_question_field edqf 
                                                WHERE edqf.employee_didi_question_id = v_employee_didi_question_id
                                                AND edqf.fl_status = true
                                            ) UPDATE employee_didi_question_field AS edqf
                                            SET fl_status = false,
                                                deleted_at = now(),
                                                deleted_by = p_user
                                            FROM existing_diagrams ed
                                            WHERE ed.id = edqf.id AND ed.id NOT IN (SELECT id FROM diagrams_to_update);

                                            -- Se actualiza los que tengan id
                                            RETURN QUERY
                                            WITH updated AS (
                                                UPDATE employee_didi_question_field AS edqf
                                                SET value = diagram_element->>'value',
                                                    updated_by = p_user,
                                                    updated_at = now()
                                                FROM jsonb_array_elements(p_data_diagram) AS diagram_element
                                                WHERE edqf.id = (diagram_element->>'id')::bigint
                                                RETURNING edqf.id, edqf.value, edqf.updated_by, edqf.updated_at
                                            )
                                            SELECT * FROM updated;
                                        END;
                                    $$;


ALTER FUNCTION questions.fn_revised_question_digitalized(p_question_id bigint, p_data_diagram jsonb, p_images jsonb, p_user bigint) OWNER TO postgres;

--
