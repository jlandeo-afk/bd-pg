-- Function: odiseo.fn_add_question_bank_ia(bigint, bigint, smallint, bigint, character varying, text, character varying, character varying, integer, text, jsonb)

--

CREATE FUNCTION odiseo.fn_add_question_bank_ia(p_question_ia_id bigint, p_config_alternative_id bigint, p_columns smallint, p_created_by bigint, p_observation character varying, p_similary text, p_status character varying, p_status_text character varying, p_level_id integer, p_description_level text, p_diagram_params jsonb) RETURNS TABLE(question_id bigint, code character varying, status character varying, teacher text, date_revised timestamp without time zone, code_course character varying, course character varying, nq_question_key uuid, level character varying, old_level character varying)
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_question_id       BIGINT;
                v_answer_id         BIGINT;
                v_teacher           TEXT;
                v_employee_neuro_id BIGINT;
                v_course_id         BIGINT;
                v_new_number        TEXT;
                v_new_code          TEXT;
            BEGIN
                SELECT e.id INTO v_employee_neuro_id
                FROM employees e
                WHERE e.first_name = 'NEURO'
                  AND e.first_surname = 'QUEST';

                -- 2.1 GENERACION DE CODIGO
                SELECT qtia.course_id INTO v_course_id
                FROM question_teacher_ia qtia
                WHERE qtia.id = p_question_ia_id;

                SELECT full_code, number_str INTO v_new_code, v_new_number
                FROM fn_generate_question_code(v_course_id::INTEGER,'P'::VARCHAR);

                WITH tbl_question_teacher_ia AS ( -- Se trae la data de pregunta IA
                    SELECT
                        qtia.id,
                        qtia.description,
                        qtia.description_short,
                        qtia.course_id,
                        qtia.topic_id,
                        qtia.subtopic_id,
                        qtia.level_id,
                        qtia.answer_id,
                        qtia.answer_description,
                        qtia.theoretical_basis,
                        qtia.argumentation,
                        CASE
                            WHEN qtia.type = 'DECO' THEN 'D'
                            WHEN qtia.type = 'TRADICIONAL' THEN 'T'
                            ELSE null
                        END AS type,
                        qtia.teacher_id
                    FROM question_teacher_ia qtia
                    INNER JOIN alternative_questions_ia aqia ON qtia.id = aqia.question_ia_id
                        AND qtia.answer_id = aqia.id
                    WHERE qtia.id = p_question_ia_id
                        AND qtia.status_revised = false
                ), get_teacher_exists AS ( -- Si no tiene docente se usa el docente GPT
                    SELECT
                        e.id AS teacher_id,
                        TRIM(CONCAT(e.first_name, ' ', e.first_surname, ' ', e.second_surname)) AS teacher
                    FROM employees e
                    WHERE id = COALESCE(
                        (SELECT tqtia.teacher_id FROM tbl_question_teacher_ia tqtia),
                        136
                    )
                    LIMIT 1
                ), update_question_ia_revised AS ( -- Se actualiza el estado y se asigna el docente GPT si no lo tiene
                    UPDATE question_teacher_ia qtia
                    SET
                        status_revised  = true,
                        teacher_id      = COALESCE(tqti.teacher_id, 136),
                        level_id        = COALESCE(p_level_id, tqti.level_id),
                        level_old_id    = tqti.level_id,
                        level_description = p_description_level,
                        updated_by      = p_created_by,
                        updated_at      = NOW()
                    FROM tbl_question_teacher_ia tqti
                    WHERE qtia.id = p_question_ia_id
                        AND tqti.id = p_question_ia_id
                    RETURNING qtia.level_id
                ), generate_code AS ( -- Genera el código de la pregunta
                    SELECT
                        LPAD((COALESCE(MAX(q.number::INT), 0) + 1)::TEXT, 7, '0') AS number,
                        CONCAT(c.code, '-', LPAD((COALESCE(MAX(q.number::INT), 0) + 1)::TEXT, 7, '0')) AS code_course
                    FROM question q
                    INNER JOIN course c ON q.course_id = c.id
                    WHERE q.course_id = (SELECT tqt.course_id FROM tbl_question_teacher_ia tqt)
                    GROUP BY c.code
                ), insert_question AS ( -- Inserta la pregunta en la base de datos
                    INSERT INTO question (
                        code, description, short_description, number,
                        course_id, topic_id, level_id, type, columns,
                        status, config_alternative_id, fl_diagrammed,
                        ia_generated, created_by, created_at
                    )
                    SELECT
                        v_new_code, tqtia.description, tqtia.description_short, v_new_number,
                        tqtia.course_id, tqtia.topic_id, uqir.level_id, tqtia.type, p_columns,
                        p_status, p_config_alternative_id, true, true, p_created_by, NOW()
                    FROM tbl_question_teacher_ia tqtia,
                        generate_code gc,
                        update_question_ia_revised uqir
                    RETURNING id AS question_id
                ), get_alternatives AS ( -- Se lista las alternativas
                    SELECT aqia.description, aqia.option, qtia.answer_id
                    FROM alternative_questions_ia aqia
                    LEFT JOIN question_teacher_ia qtia ON aqia.id = qtia.answer_id
                    WHERE aqia.question_ia_id = p_question_ia_id
                ), insert_alternatives AS ( -- Se inserta las alternativas
                    INSERT INTO alternative AS a (description, question_id, created_by, created_at)
                    SELECT ga.description, iq.question_id, p_created_by, NOW()
                    FROM get_alternatives ga, insert_question iq
                    ORDER BY ga.option
                    RETURNING a.id, a.description, a.question_id
                ), get_alternative_correct AS ( -- Se lista la alternativa correcta
                    SELECT a.id, a.description, a.question_id, gte.teacher
                    FROM insert_alternatives a, get_teacher_exists gte
                    WHERE TRIM(a.description) = (SELECT TRIM(ga.description) FROM get_alternatives ga WHERE ga.answer_id IS NOT NULL LIMIT 1)
                        AND a.question_id = (SELECT iq.question_id FROM insert_question iq)
                    LIMIT 1
                ), get_images_description AS (
                    SELECT qiai.code, qiai.extension, qiai.image
                    FROM question_ia_images qiai
                    WHERE qiai.question_ia_id = p_question_ia_id AND qiai.fl_status = true
                ), insert_images_description AS (
                    INSERT INTO question_image (code, extension, image, question_id)
                    SELECT gid.code, gid.extension, gid.image, iq.question_id
                    FROM get_images_description gid, insert_question iq
                ), get_images_alternatives AS (
                    SELECT aiai.code, aiai.extension, aiai.image
                    FROM alternative_ia_images aiai
                    INNER JOIN alternative_questions_ia aqia ON aiai.alternative_ia_id = aqia.id
                    WHERE aqia.question_ia_id = p_question_ia_id AND aiai.fl_status = true
                ), insert_images_alternatives AS (
                    INSERT INTO question_image (code, extension, image, question_id)
                    SELECT gia.code, gia.extension, gia.image, iq.question_id
                    FROM get_images_alternatives gia, insert_question iq
                ), insert_teacher_question AS ( -- Se asigna la pregunta al docente
                    INSERT INTO employee_question (teacher_id, question_id, week, year, solved, created_by, created_at)
                    SELECT gte.teacher_id, iq.question_id,
                        EXTRACT(WEEK FROM CURRENT_DATE)::INT,
                        EXTRACT(YEAR FROM CURRENT_DATE)::INT,
                        true, p_created_by, NOW()
                    FROM get_teacher_exists gte, insert_question iq
                ), insert_subtopic_question AS ( -- Se inserta el subtema de la pregunta
                    INSERT INTO question_subtopic (question_id, subtopic_id, created_by, created_at)
                    SELECT iq.question_id, tqtia.subtopic_id, p_created_by, NOW()
                    FROM tbl_question_teacher_ia tqtia, insert_question iq
                ), insert_didi_question AS ( -- Se asigna al didi la pregunta
                    INSERT INTO employee_didi_question AS edq (
                        employee_id, question_id, week, year, diagrammed, created_by, created_at
                    )
                    SELECT v_employee_neuro_id, iq.question_id,
                        EXTRACT(WEEK FROM CURRENT_DATE)::INT,
                        EXTRACT(YEAR FROM CURRENT_DATE)::INT,
                        true, p_created_by, NOW()
                    FROM insert_question iq
                    RETURNING edq.id AS employee_didi_question_id
                ), insert_origin_nq AS ( -- Se inserta la relación de la pregunta ia con la pregunta banco
                    INSERT INTO origin_question_nq (question_ia_id, question_id, date_revised, created_by, created_at)
                    SELECT p_question_ia_id, iq.question_id, NOW(), p_created_by, NOW()
                    FROM insert_question iq
                ), tbl_rol_user AS ( -- Se obtiene el rol del usuario que creó
                    SELECT
                        r.name AS rol,
                        CASE
                            WHEN e.user_id IS NOT NULL THEN
                                CONCAT(split_part(e.first_name, ' ', 1), ' ', upper(left(e.first_surname, 1)), '. ', e.second_surname)
                            ELSE 'admin-odiseo'
                        END AS user_name
                    FROM users_roles ur
                    INNER JOIN roles r ON ur.rol_id = r.id
                    LEFT JOIN users u ON ur.user_id = u.id
                    LEFT JOIN employees e ON u.id = e.user_id
                    WHERE ur.user_id = p_created_by
                ), insert_status_question AS ( -- Se inserta el estado de la pregunta
                    INSERT INTO question_status (question_id, status, process, description, fl_active, created_by, created_at)
                    SELECT
                        ia.question_id, p_status, p_status_text,
                        CONCAT('La pregunta generada de NQ ha sido ', LOWER(p_status_text), ' por el ', tru.rol,
                            ' <span class="text-teacher">', tru.user_name, '</span>'),
                        true, p_created_by, NOW()
                    FROM insert_question ia, tbl_rol_user tru
                ), get_setting_diagrammed AS ( -- Se obtiene los nombres de diagramación del curso
                    SELECT sdc.id, sdc.course_id, sdc.field_diagram_id
                    FROM setting_diagrammed_courses sdc
                    WHERE sdc.fl_status = true
                        AND sdc.course_id = (SELECT tqtia.course_id FROM tbl_question_teacher_ia tqtia)
                ), insert_diagram_params AS ( -- Se inserta los parámetros de diagramación desde p_diagram_params
                    INSERT INTO employee_didi_question_field (
                        employee_didi_question_id,
                        setting_diagrammed_course_id,
                        value,
                        created_by,
                        created_at
                    )
                    SELECT
                        edq.employee_didi_question_id,
                        sdc.id,
                        (param->>'cleanedHtml'),
                        p_created_by,
                        NOW()
                    FROM insert_didi_question edq,
                        get_setting_diagrammed sdc,
                        jsonb_array_elements(p_diagram_params) AS param
                    WHERE sdc.field_diagram_id = (param->>'fieldSolutionId')::BIGINT
                ), get_images_solution AS (
                    SELECT siai.code, siai.extension, siai.image
                    FROM solution_ia_images siai
                    WHERE siai.solution_ia_id = p_question_ia_id AND siai.fl_status = true
                ), insert_images_solution AS (
                    INSERT INTO employee_didi_question_field_image(code, extension, image, employee_didi_question_id)
                    SELECT gis.code, gis.extension, gis.image, edq.employee_didi_question_id
                    FROM get_images_solution gis, insert_didi_question edq
                )
                SELECT gac.question_id, gac.id, gac.teacher
                INTO v_question_id, v_answer_id, v_teacher
                FROM get_alternative_correct gac;

                UPDATE question q
                SET answer_id = v_answer_id
                WHERE q.id = v_question_id;

                -- Registrar preguntas compartidas si el subtema está configurado como compartido
                PERFORM fn_insert_question_shares(
                    v_question_id,
                    (SELECT tqtia.subtopic_id FROM question_teacher_ia tqtia WHERE tqtia.id = p_question_ia_id)::SMALLINT,
                    v_course_id::INTEGER,
                    p_created_by
                );

                IF p_observation IS NOT NULL AND p_observation <> '' THEN
                    INSERT INTO question_observation (
                        description, similitaries, question_id, type, fl_status, created_by, created_at
                    )
                    VALUES (p_observation, p_similary, v_question_id, 'DUPL', true, p_created_by, NOW());
                END IF;

                RETURN QUERY
                SELECT DISTINCT
                    q.id AS question_id,
                    q.code,
                    q.status,
                    v_teacher,
                    oqnq.date_revised,
                    c.code AS code_course,
                    c.name AS course,
                    qti.nq_question_key,
                    l.name level,
                    l2.name old_level
                FROM question q
                INNER JOIN origin_question_nq oqnq ON oqnq.question_id = q.id
                INNER JOIN question_teacher_ia qti ON qti.id = oqnq.question_ia_id
                INNER JOIN course c ON q.course_id = c.id
                INNER JOIN level l ON l.id = qti.level_id
                INNER JOIN level l2 ON l2.id = qti.level_old_id
                WHERE q.id = v_question_id
                    AND oqnq.question_ia_id = p_question_ia_id;
            END;
            $$;


ALTER FUNCTION odiseo.fn_add_question_bank_ia(p_question_ia_id bigint, p_config_alternative_id bigint, p_columns smallint, p_created_by bigint, p_observation character varying, p_similary text, p_status character varying, p_status_text character varying, p_level_id integer, p_description_level text, p_diagram_params jsonb) OWNER TO postgres;

--
