-- Function: questions.sp_insert_didi_ghost_or_teacher_ghost()

--

CREATE PROCEDURE questions.sp_insert_didi_ghost_or_teacher_ghost()
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_question_ids INTEGER[];
                v_question_id INTEGER;
                v_is_question_assigned_to_teacher BOOLEAN;
                v_is_question_assigned_to_didi BOOLEAN;
                v_ghost_teacher_id INTEGER;
                v_ghost_didi_id INTEGER;
                v_user INTEGER;
                v_employee_didi_question_id INTEGER;
                v_last_id_question_status INTEGER;
                v_exist_field_diagrammed BOOLEAN;
                v_user_name TEXT;
            BEGIN
                -- Obtener IDs de Ghost Teacher y DIDI
                SELECT e.id
                INTO v_ghost_teacher_id
                FROM odiseo.employees e
                WHERE e."document" = '33333333' AND e.charge_id = 2;

                SELECT e.id
                INTO v_ghost_didi_id
                FROM odiseo.employees e
                WHERE e."document" = '44444444' AND e.charge_id = 3;

                -- Obtener preguntas no asignadas
                SELECT ARRAY(
                    SELECT q.id
                    FROM questions.question q
                    WHERE q.status = 'VERI'
                    AND NOT EXISTS (
                        SELECT 1
                        FROM (
                            SELECT question_id FROM questions.employee_question WHERE fl_status = TRUE
                            UNION
                            SELECT question_id FROM questions.employee_didi_question WHERE fl_status = TRUE
                        ) sub
                        WHERE sub.question_id = q.id
                    )
                ) INTO v_question_ids;

                -- Iterar sobre las preguntas
                FOREACH v_question_id IN ARRAY v_question_ids
                LOOP
                    -- Obtener último registro de question_status
                    SELECT qs.created_by, qs.id
                    INTO v_user, v_last_id_question_status
                    FROM questions.question_status qs
                    WHERE qs.question_id = v_question_id
                    ORDER BY qs.created_at DESC, qs.id DESC
                    LIMIT 1;

                    -- Obtener nombre del usuario
                    SELECT CASE
                            WHEN e.id IS NOT NULL
                            THEN CONCAT(e.first_name, ' ', LEFT(e.first_surname, 1), '. ', e.second_surname)
                            ELSE 'Administrador'
                        END AS user
                    INTO v_user_name
                    FROM auth.users u
                    LEFT JOIN odiseo.employees e ON u.id = e.user_id
                    WHERE u.id = v_user;

                -- Eliminar el ultimo registro de ese historial
                    DELETE FROM questions.question_status WHERE id = v_last_id_question_status ;

                    -- Verificar asignación a un docente
                    SELECT CASE WHEN COUNT(*) > 0 THEN true ELSE false END
                    INTO v_is_question_assigned_to_teacher
                    FROM questions.employee_question eq
                    WHERE eq.question_id = v_question_id AND eq.fl_status = TRUE;

                    IF NOT v_is_question_assigned_to_teacher THEN
                        INSERT INTO questions.employee_question (teacher_id, question_id, created_by, created_at)
                        VALUES (v_ghost_teacher_id, v_question_id, v_user, NOW());

                        INSERT INTO questions.question_status (question_id, status, fl_active, process, description, created_by, created_at)
                        VALUES (v_question_id, 'ASIG', false, 'ASIGNACIÓN',
                            'La pregunta fue asignada al docente <span class=''text-teacher''>Docente Ghost</span> por el usuario <span class=''text-user''>' || v_user_name || '</span>', 
                            v_user, NOW());
                    END IF;

                    -- Verificar asignación a un DIDI
                    SELECT CASE WHEN COUNT(*) > 0 THEN true ELSE false END
                    INTO v_is_question_assigned_to_didi
                    FROM questions.employee_didi_question edq
                    WHERE edq.question_id = v_question_id AND edq.fl_status = TRUE;

                    IF NOT v_is_question_assigned_to_didi THEN
                        INSERT INTO questions.employee_didi_question (employee_id, question_id, created_by, created_at)
                        VALUES (v_ghost_didi_id, v_question_id, v_user, NOW())
                        RETURNING id INTO v_employee_didi_question_id;

                        INSERT INTO questions.question_status (question_id, status, fl_active, process, description, created_by, created_at)
                        VALUES (v_question_id, 'DASI', false, 'ASIGNADO',
                            'La pregunta fue asignada al DiDi <span class=''text-teacher''>DIDI GHOST</span> por el usuario <span class=''text-user''>' || v_user_name || '</span>', 
                            v_user, NOW());

                        -- Diagramar la pregunta con campos en proceso
                        INSERT INTO questions.employee_didi_question_field (
                            employee_didi_question_id, setting_diagrammed_course_id, value, created_by, created_at
                        )
                        SELECT v_employee_didi_question_id, sdc.id, 'En proceso', v_user , NOW()
                        FROM academic.setting_diagrammed_courses sdc
                        WHERE sdc.course_id = (
                            SELECT oq.course_id
                            FROM questions.question oq
                            WHERE oq.id = v_question_id
                            LIMIT 1
                        )  AND sdc.fl_status = TRUE
                        ORDER BY sdc.position ASC;

                    ELSE
                        SELECT edq.id
                        INTO v_employee_didi_question_id
                        FROM questions.employee_didi_question edq
                        WHERE edq.question_id = v_question_id AND edq.fl_status = TRUE;

                        -- Verificar si tiene campos diagramados
                        SELECT CASE WHEN COUNT(*) > 0 THEN  TRUE ELSE FALSE END AS exist_field_diagrammed
                        INTO v_exist_field_diagrammed
                        FROM questions.employee_didi_question_field edqf
                        WHERE edqf.employee_didi_question_id = v_employee_didi_question_id;

                        IF NOT v_exist_field_diagrammed THEN
                            -- Diagramar la pregunta con campos en proceso
                            INSERT INTO questions.employee_didi_question_field (
                                employee_didi_question_id, setting_diagrammed_course_id, value, created_by, created_at
                            )
                            SELECT v_employee_didi_question_id, sdc.id, 'En proceso', v_user , NOW()
                            FROM academic.setting_diagrammed_courses sdc
                            WHERE sdc.course_id = (
                                SELECT oq.course_id
                                FROM questions.question oq
                                WHERE oq.id = v_question_id
                                LIMIT 1
                            )  AND sdc.fl_status = TRUE
                            ORDER BY sdc.position ASC;
                        END IF;
                    END IF;

                    -- Registrar estado VERIFICADO
                    INSERT INTO questions.question_status (question_id, status, process, description, created_by, created_at)
                    VALUES (v_question_id, 'VERI', 'VERIFICADO',
                        'La pregunta se cambió al estado verificado por el usuario <span class=''text-user''>' || v_user_name || '</span>', 
                        v_user, NOW());
                END LOOP;
            END;
            $$;


ALTER PROCEDURE questions.sp_insert_didi_ghost_or_teacher_ghost() OWNER TO postgres;

--
