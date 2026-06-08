-- Function: odiseo.change_status_verified_question(integer, character varying, character varying, integer)

--

CREATE FUNCTION odiseo.change_status_verified_question(p_question_id integer, p_status character varying, p_observations character varying, p_user_id integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_exit_question BOOLEAN;
            v_message TEXT := '';
            v_user_name VARCHAR;
            v_new_status VARCHAR;
            v_old_status VARCHAR;
        BEGIN

            -- Obtener nombre del usuario
            SELECT CASE
                    WHEN e.id IS NOT NULL
                    THEN CONCAT(e.first_name, ' ', LEFT(e.first_surname, 1), '. ', e.second_surname)
                    ELSE 'Admin'
                END AS user
            INTO v_user_name
            FROM users u
            LEFT JOIN employees e ON u.id = e.user_id
            WHERE u.id = p_user_id;

            -- Validación: Verificar si la pregunta existe y cumple las condiciones
            SELECT COUNT(*) > 0
            INTO v_exit_question
            FROM question
            WHERE status IN ('APRB', 'VERI', 'PEND', 'RESV')
            AND fl_status = TRUE
            AND id = p_question_id;

            IF NOT v_exit_question THEN
                RETURN json_build_object(
                        'status', 409,
                        'message', 'No existe la pregunta o no se encuentra en estado VERIFICADO o STAND BY con el id: ' || p_question_id
                    );
            END IF;

            -- Actualización según el estado deseado
            CASE p_status
                WHEN 'PEND' THEN
                    UPDATE question
                    SET status = p_status
                    WHERE id = p_question_id;

                    UPDATE question_status
                    SET fl_active = false
                    WHERE question_id = p_question_id;

                    INSERT INTO question_status (question_id, status, fl_active, process, description, created_by, created_at)
                            VALUES (p_question_id, 'PEND', true, 'PENDIENTE',
                                'La pregunta fue cambiado al estado stand by por el usuario <span class=''text-user''>' || v_user_name || '</span>',
                                p_user_id, NOW());

                    -- Añadir observaciones en la tabla question_observation
                    IF p_observations IS NOT NULL THEN
                        INSERT INTO question_observation (question_id, description, type, created_by, created_at)
                                VALUES (p_question_id, p_observations, 'PEND', p_user_id, NOW());
                    END IF;
                    v_message := 'Se cambio el estado de la pregunta a Stand By exitosamente';

                WHEN 'RESV' THEN
                    UPDATE question
                    SET status = p_status,
                        resv_to_veri_at = NOW() + INTERVAL '4 weeks'
                    WHERE id = p_question_id;

                    UPDATE question_status
                    SET fl_active = false
                    WHERE question_id = p_question_id;

                    INSERT INTO question_status (question_id, status, fl_active, process, description, created_by, created_at)
                    VALUES (p_question_id, 'RESV', true, 'RESERVA',
                                'La pregunta fue cambiado al estado reserva  por el usuario <span class=''text-user''>' || v_user_name || '</span>', 
                                p_user_id, NOW());

                    -- Añadir observaciones en la tabla question_observation
                    IF p_observations IS NOT NULL THEN
                        INSERT INTO question_observation (question_id, description, type, created_by, created_at)
                                VALUES (p_question_id, p_observations, 'RESV', p_user_id, NOW());
                    END IF;

                    v_message := 'Se cambio el estado de la pregunta a Reserva exitosamente';

                WHEN 'VERI' THEN
                    SELECT status
                    INTO v_old_status
                    FROM question
                    WHERE id = p_question_id;

                    IF v_old_status = 'PEND' OR v_old_status = 'RESV' THEN
                        UPDATE question
                        SET status = p_status
                        WHERE id = p_question_id;

                        UPDATE question_status
                        SET fl_active = false
                        WHERE question_id = p_question_id;

                        INSERT INTO question_status (question_id, status, fl_active, process, description, created_by, created_at)
                        VALUES (p_question_id, 'VERI', true, 'VERIFICADO',
                        'La pregunta fue cambiado al estado verificado por el usuario <span class=''text-user''>' || v_user_name || '</span>',
                        p_user_id, NOW());

                        -- Quitando la observación de la tabla question_observation
                        UPDATE question_observation
                        SET fl_status = false
                        WHERE question_id = p_question_id AND type = v_old_status;

                        v_message := 'Se cambio el estado de la pregunta a Verificado exitosamente';

                    END IF;

                WHEN 'APRB' THEN
                    SELECT status
                    INTO v_old_status
                    FROM question
                    WHERE id = p_question_id;

                    -- Si el estado anterior es VERI continua
                    IF v_old_status = 'VERI' THEN

                        -- Actualiza el estado de la pregunta a APRB
                        UPDATE question
                        SET status = p_status
                        WHERE id = p_question_id;

                        -- Inserta data para que se visualice en el historial
                        INSERT INTO question_status (question_id, status, fl_active, process, description, created_by, created_at)
                        VALUES (p_question_id, 'APRB', true, 'APROBADO',
                        'La pregunta fue cambiado al estado aprobado por el usuario <span class=''text-user''>' || v_user_name || '</span>',
                        p_user_id, NOW());

                        -- Quitando la observación de la tabla question_observation
                        UPDATE question_observation
                        SET fl_status = false
                        WHERE question_id = p_question_id AND type = v_old_status;
                    END IF;

                    v_message := 'Se cambio el estado de la pregunta a Aprobado exitosamente';

                ELSE
                    RETURN json_build_object(
                            'status', 409,
                            'message', 'El parámetro del estado de la pregunta no coincide : ' || p_status
                        );
            END CASE;

            SELECT status
            INTO v_new_status
            FROM question
            WHERE id = p_question_id;

            -- Retorno exitoso
            RETURN json_build_object(
                    'status', 200,
                    'message', v_message,
                    'question_status', v_new_status
                );

        END;
        $$;


ALTER FUNCTION odiseo.change_status_verified_question(p_question_id integer, p_status character varying, p_observations character varying, p_user_id integer) OWNER TO postgres;

--
