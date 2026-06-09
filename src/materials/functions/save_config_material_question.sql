-- Function: materials.save_config_material_question(jsonb, integer, bigint)

--

CREATE FUNCTION materials.save_config_material_question(p_topics jsonb, p_column integer, p_user bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
                DECLARE
                    v_topic RECORD;
                    v_material_id INTEGER;
                    v_topic_id INTEGER;
                BEGIN
                    FOR v_topic IN
                        SELECT * FROM jsonb_array_elements(p_topics) AS t(topic)
                    LOOP
                        -- Extraer el ID del material del JSON
                        v_material_id := (v_topic.topic->>'material_id')::INTEGER;
                        v_topic_id := (v_topic.topic->>'topic_id')::INTEGER;

                        -- Comprobar si el ID del material es NULL
                        IF v_material_id IS NULL THEN
                            -- Insertar nuevo registro si material_id es NULL
                            INSERT INTO materials.material_column_configurations (
                                material_configuration_id,
                                topic_id,
                                column_count,
                                layout_format,
                                number_format,
                                created_by,
                                created_at
                            )
                            VALUES (
                                7,
                                (v_topic.topic->>'topic_id')::INTEGER,
                                p_column,
                                'one_column',
                                'sequential',
                                p_user,
                                NOW()
                            );
                        ELSE
                            -- Actualizar registro existente si material_id no es NULL
                            UPDATE materials.material_column_configurations
                            SET column_count = p_column,
                                updated_at = NOW(),
                                updated_by = p_user
                            WHERE id = v_material_id and topic_id = v_topic_id;
                        END IF;
                    END LOOP;
                END;
                $$;


ALTER FUNCTION materials.save_config_material_question(p_topics jsonb, p_column integer, p_user bigint) OWNER TO postgres;

--
