-- Function: odiseo.fn_update_configuration_diagrammed_course(bigint, jsonb, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_update_configuration_diagrammed_course(p_course_id bigint, p_setting_diagram_course jsonb, p_category_text_id bigint, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                        IF EXISTS (
                            SELECT 1
                            FROM setting_diagrammed_courses sdc
                            WHERE sdc.course_id = p_course_id
                                AND (
                                    (p_category_text_id IS NULL AND sdc.category_text_id IS NULL) OR
                                    (p_category_text_id IS NOT NULL AND sdc.category_text_id = p_category_text_id)
                                )
                                AND sdc.fl_status = true
                        ) THEN
                            -- Se elimina loss diagramas de cursos que no se mandaron
                            UPDATE setting_diagrammed_courses
                            SET fl_status = false,
                                fl_optional = true,
                                updated_by = p_updated_by,
                                updated_at = NOW()
                            WHERE course_id = p_course_id
                                AND (
                                    (p_category_text_id IS NULL AND setting_diagrammed_courses.category_text_id IS NULL) OR
                                    (p_category_text_id IS NOT NULL AND setting_diagrammed_courses.category_text_id = p_category_text_id)
                                )
                                AND fl_status = true
                                AND field_diagram_id NOT IN (
                                    SELECT
                                        (sdc->>'field_diagram_id')::BIGINT
                                    FROM jsonb_array_elements(p_setting_diagram_course) AS sdc
                                    WHERE (sdc->>'field_diagram_id') IS NOT NULL
                                );

                            -- Se actualiza la posicion de los diagramas de cursos mandados y existentes
                            UPDATE setting_diagrammed_courses
                            SET position = (sdc->>'position')::INT,
                                fl_active = (sdc->>'fl_active')::BOOL,
                                fl_optional = (sdc->>'fl_optional')::BOOL,
                                fl_status = true,
                                updated_by = p_updated_by,
                                updated_at = now()
                            FROM jsonb_array_elements(p_setting_diagram_course) AS sdc
                            WHERE course_id = p_course_id
                                AND fl_status = true
                                AND (sdc->>'field_diagram_id')::BIGINT = setting_diagrammed_courses.field_diagram_id
                                AND (
                                    (p_category_text_id IS NULL AND setting_diagrammed_courses.category_text_id IS NULL) OR
                                    (p_category_text_id IS NOT NULL AND p_category_text_id = setting_diagrammed_courses.category_text_id)
                                );

                            -- Insertamos los nuevos registros que no están en la base de datos
                            INSERT INTO setting_diagrammed_courses (
                                course_id,
                                field_diagram_id,
                                "position",
                                category_text_id,
                                fl_active,
                                fl_optional,
                                created_by,
                                created_at
                            )
                            SELECT
                                p_course_id,
                                (sdc->>'field_diagram_id')::BIGINT AS field_diagram_id,
                                (sdc->>'position')::INT AS position,
                                p_category_text_id AS category_text_id,
                                (sdc->>'fl_active')::BOOL AS fl_active,
                                (sdc->>'fl_optional')::BOOL AS fl_optional,
                                p_updated_by AS created_by,
                                NOW() AS created_at
                            FROM jsonb_array_elements(p_setting_diagram_course) AS sdc
                            WHERE (sdc->>'field_diagram_id')::BIGINT NOT IN (
                                SELECT field_diagram_id
                                FROM setting_diagrammed_courses
                                WHERE course_id = p_course_id
                                    AND fl_status = true
                                    AND (
                                    (p_category_text_id IS NULL AND setting_diagrammed_courses.category_text_id IS NULL) OR
                                    (p_category_text_id IS NOT NULL AND setting_diagrammed_courses.category_text_id = p_category_text_id)
                                )
                            );
                        END IF;
                    END;
                    $$;


ALTER FUNCTION odiseo.fn_update_configuration_diagrammed_course(p_course_id bigint, p_setting_diagram_course jsonb, p_category_text_id bigint, p_updated_by bigint) OWNER TO postgres;

--
