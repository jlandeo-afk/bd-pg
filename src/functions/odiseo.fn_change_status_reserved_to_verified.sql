-- Function: odiseo.fn_change_status_reserved_to_verified(integer, integer)

--

CREATE FUNCTION odiseo.fn_change_status_reserved_to_verified(p_question_id integer, p_user_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_exist_question BOOL;
            BEGIN
                -- Verificar si la pregunta con estado 'RESV' y fl_status = TRUE existe
                SELECT COUNT(*) > 0
                INTO v_exist_question
                FROM odiseo.question q
                WHERE q.status = 'RESV'
                AND q.fl_status = TRUE
                AND q.id = p_question_id;

                -- Si la pregunta existe, actualizar el estado a 'VERI'
                IF v_exist_question THEN
                    -- Actualizar el estado de la pregunta
                    UPDATE odiseo.question
                    SET status = 'VERI', resv_to_veri_at = NULL
                    WHERE id = p_question_id
                    AND fl_status = TRUE;

                    -- Desactivar estado previo en question_status
                    UPDATE odiseo.question_status
                    SET fl_active = FALSE
                    WHERE question_id = p_question_id;

                    -- Insertar un nuevo registro en question_status
                    INSERT INTO odiseo.question_status (
                        question_id, status, fl_active, process, description, created_by, created_at
                    ) VALUES (
                        p_question_id, 'VERI', TRUE, 'VERIFICADO',
                        'La pregunta fue cambiada al estado verificado por el usuario <span class=''text-user''> Admin </span>',
                        p_user_id, NOW()
                    );

                    -- Quitando la observación de la tabla question_observation
                        UPDATE odiseo.question_observation
                        SET fl_status = false
                        WHERE question_id = p_question_id AND type = 'RESV';

                    -- Retornar TRUE porque se realizó la actualización
                    RETURN TRUE;
                END IF;

                -- Si no se encontró la pregunta, retornar FALSE
                RETURN FALSE;
            END;
            $$;


ALTER FUNCTION odiseo.fn_change_status_reserved_to_verified(p_question_id integer, p_user_id integer) OWNER TO postgres;

--
