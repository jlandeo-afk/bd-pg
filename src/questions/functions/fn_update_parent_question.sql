-- Function: questions.fn_update_parent_question(bigint, text, text, text, text, integer, integer, integer, text, text, bigint, integer, integer)

--

CREATE FUNCTION questions.fn_update_parent_question(p_id bigint, p_description text, p_short_description text, p_text_traduction text, p_short_text_traduction text, p_type_text_id integer, p_level_id integer, p_type_text_subcategory_id integer, p_description_b text, p_short_description_b text, p_updated_by bigint, p_question_columns integer, p_priority integer) RETURNS TABLE(id bigint, message boolean, status character, process character varying)
    LANGUAGE plpgsql
    AS $$
    DECLARE
        v_similary_text TEXT;
        v_final_status CHAR(4);
        v_codes_list TEXT;
        v_obs_desc TEXT;
        v_process VARCHAR;
        v_type_text_id INTEGER;
    BEGIN
            --	Verificar si la pregunta tiene duplicados
            WITH subquestion_status AS (
                SELECT
                    q.id,
                    q.parent_id,
                    qs.status,
                    qs.description,
                    qs.process
                FROM question q
                JOIN parent_question pq ON q.parent_id = pq.id
                JOIN (
                    SELECT DISTINCT ON (qs.question_id) *
                    FROM question_status qs
                    WHERE qs.status <> 'DUPL'
                    ORDER BY qs.question_id, qs.created_at DESC
                ) qs ON qs.question_id = q.id
                WHERE q.parent_id = p_id
                ORDER BY qs.status ASC
            )
            SELECT
                qs.status, qs.process
                INTO
                v_final_status, v_process
            FROM subquestion_status qs
            LIMIT 1;

            WITH data_parent_question AS (
                SELECT
                    pq.course_id
                FROM parent_question pq
                WHERE pq.id = p_id
            ), similarity_question AS (
                SELECT fsp.id, (fsp.score * 100)::NUMERIC(10,2) as percentage, fsp.code
                FROM fn_search_similar_parent_questions(
                    p_short_description,
                    (SELECT dpq.course_id FROM data_parent_question dpq)
                ) fsp
                WHERE fsp.id != p_id
            )
            SELECT
                COALESCE(
                    jsonb_agg(jsonb_build_object('id', sq.id, 'percentage', sq.percentage))::TEXT,
                    '[]'
                ),
                CASE
                    WHEN EXISTS (SELECT 1 FROM similarity_question)
                        THEN 'DUPL'
                    ELSE v_final_status
                END,
                string_agg(sq.code, ', ' ORDER BY sq.code ASC),
                CASE
                    WHEN EXISTS (SELECT 1 FROM similarity_question)
                        THEN 'DUPLICADO'
                    ELSE v_process
                END
            INTO v_similary_text, v_final_status, v_codes_list, v_process
            FROM similarity_question sq;

            IF v_final_status = 'DUPL' AND v_codes_list IS NOT NULL THEN
                v_obs_desc := 'Tiene similitud con una o varias preguntas: ' || v_codes_list;
            END IF;

            -- obtener la categoria que tenia la pregunta T antes de cambiarlo.
            SELECT pq.type_text_id INTO v_type_text_id FROM parent_question pq WHERE pq.id = p_id;

            UPDATE parent_question as pq
            SET
                description = p_description,
                short_description = p_short_description,
                text_traduction = p_text_traduction,
                short_text_traduction = p_short_text_traduction,
                type_text_id = COALESCE(p_type_text_id, pq.type_text_id),
                level_id = COALESCE(p_level_id, pq.level_id),
                type_text_subcategory_id = COALESCE( p_type_text_subcategory_id, pq.type_text_subcategory_id),
                description_b = p_description_b,
                short_description_b = p_short_description_b,
                updated_by = p_updated_by,
                updated_at = now(),
                columns = p_question_columns,
                status = v_final_status,
                priority = COALESCE(p_priority, pq.priority)
            WHERE pq.id = p_id;

            -- Deshabilita los parametros de diagramación de las preguntas S si la pregunta T cambió de categoría
            IF v_type_text_id <> p_type_text_id THEN
                WITH subquestions_diagrams AS (SELECT edqf.id FROM parent_question pq  
                JOIN question q
                    ON q.parent_id  = pq.id
                JOIN employee_didi_question edq 
                    ON edq.question_id  = q.id 
                JOIN employee_didi_question_field edqf 
                    ON edqf.employee_didi_question_id = edq.id
                WHERE pq.id = p_id
                )
                UPDATE
                employee_didi_question_field AS edqf
                SET fl_status = false,
                    deleted_at = NOW(),
                    deleted_by = p_updated_by
                WHERE edqf.id IN (SELECT sd.id FROM subquestions_diagrams sd);
            END IF;

            -- Insertar observación si p_observation no es NULL ni vacío
            IF v_final_status = 'DUPL' AND v_codes_list IS NOT NULL THEN
                -- Se elimina las observaciones anteriores
                UPDATE parent_observation as po
                SET fl_status = false,
                    deleted_at = now(),
                    deleted_by = p_updated_by
                WHERE po.parent_id = p_id
                    AND po.fl_status = true
                    AND po.type = 'DUPL';

                INSERT INTO parent_observation (
                    description,
                    similitaries,
                    parent_id,
                    type,
                    fl_status,
                    created_by,
                    created_at
                )
                VALUES (
                    v_obs_desc,
                    v_similary_text,
                    p_id,
                    'DUPL',
                    true,
                    p_updated_by, now()
                );
                --	Si es que el padre esta duplicado en este caso los hijos tambien
                UPDATE question set status = v_final_status WHERE question.parent_id = p_id;

                WITH user_created AS (
                    SELECT
                        CASE WHEN e.id IS NULL
                            THEN 'Administrador'
                            ELSE concat(
                                split_part(e.first_name, ' ', 1),
                                ' ',
                                upper(left(e.first_surname, 1)),
                                '. ',
                                e.second_surname
                            )
                            END user_name,
                            COALESCE(r.name, 'usuario') rol
                    FROM users u
                    JOIN users_roles ur ON u.id = ur.user_id
                        AND ur.fl_status = true
                    JOIN roles r ON ur.rol_id = r.id
                    LEFT JOIN employees e ON u.id = e.user_id
                    WHERE u.id = p_updated_by
                ), desription_archived AS (
                    SELECT
                        CONCAT(
                            'La pregunta se cambió a duplicado por el ',
                            uc.rol,
                            ' <span class="text-user">',
                            uc.user_name,
                            '</span>'
                        )::VARCHAR description,
                        'DUPLICADO' process,
                        'DUPL' status
                    FROM user_created uc
                    LIMIT 1
                ), subquestion AS (
                    SELECT
                        q.id,
                        da.description,
                        da.process,
                        da.status
                    FROM question q, desription_archived da
                    WHERE q.parent_id = p_id
                    AND q.fl_status = true
                ), desactive_status AS (
                    UPDATE question_status
                    SET fl_active = false
                    WHERE question_id IN (
                        SELECT sq.id
                        FROM subquestion sq
                    )
                ), delete_observations_subquestion AS (
                    UPDATE question_observation
                    SET fl_status = false,
                        deleted_at = now(),
                        deleted_by = p_updated_by
                    WHERE question_id IN (
                        SELECT sq.id
                        FROM subquestion sq
                    )
                        AND type = 'DUPL'
                        AND fl_status = true
                )
                INSERT INTO question_status (
                    question_id,
                    status,
                    process,
                    description,
                    created_by,
                    created_at
                )
                SELECT
                    q.id,
                    q.status,
                    q.process,
                    q.description,
                    p_updated_by,
                    NOW()
                FROM subquestion q;
            ELSE
                WITH delete_observation_parent AS (
                    UPDATE parent_observation po
                    SET fl_status = false,
                        deleted_at = now(),
                        deleted_by = p_updated_by
                    WHERE po.parent_id = p_id
                        AND po.type = 'DUPL'
                        AND po.fl_status = true
                ), user_created AS (
                    SELECT
                        CASE WHEN e.id IS NULL
                            THEN 'Administrador'
                            ELSE concat(
                                split_part(e.first_name, ' ', 1),
                                ' ',
                                upper(left(e.first_surname, 1)),
                                '. ',
                                e.second_surname
                            )
                            END user_name,
                            COALESCE(r.name, 'usuario') rol
                    FROM users u
                    JOIN users_roles ur ON u.id = ur.user_id
                        AND ur.fl_status = true
                    JOIN roles r ON ur.rol_id = r.id
                    LEFT JOIN employees e ON u.id = e.user_id
                    WHERE u.id = p_updated_by
                ), desription_archived AS (
                    SELECT
                        CONCAT(
                            'La pregunta se cambió a',
                            LOWER(v_process),
                            ' por el ',
                            uc.rol,
                            ' <span class="text-user">',
                            uc.user_name,
                            '</span>'
                        )::VARCHAR description,
                        v_process AS process,
                        v_final_status AS status
                    FROM user_created uc
                    LIMIT 1
                ), subquestion AS (
                    SELECT
                        q.id,
                        da.description,
                        da.process,
                        da.status
                    FROM question q, desription_archived da
                    WHERE q.parent_id = p_id
                    AND q.fl_status = true
                ), desactive_status AS (
                    UPDATE question_status
                    SET fl_active = false
                    WHERE question_id IN (
                        SELECT s.id
                        FROM subquestion s
                    )
                ), delete_observations_subquestion AS (
                    UPDATE question_observation qo
                    SET fl_status = false,
                        deleted_at = now(),
                        deleted_by = p_updated_by
                    WHERE qo.question_id IN (
                        SELECT sq.id
                        FROM subquestion sq
                    )
                        AND qo.type = 'DUPL'
                        AND qo.fl_status = true
                )
                INSERT INTO question_status (
                    question_id,
                    status,
                    process,
                    description,
                    created_by,
                    created_at
                )
                SELECT
                    q.id,
                    q.status,
                    q.process,
                    q.description,
                    p_updated_by,
                    NOW()
                FROM subquestion q;
            END IF;

            RETURN QUERY
            SELECT
                p_id,
                CASE WHEN v_final_status = 'DUPL' THEN FALSE ELSE TRUE END,
                v_final_status,
                LOWER(v_process)::VARCHAR;
        END;
    $$;


ALTER FUNCTION questions.fn_update_parent_question(p_id bigint, p_description text, p_short_description text, p_text_traduction text, p_short_text_traduction text, p_type_text_id integer, p_level_id integer, p_type_text_subcategory_id integer, p_description_b text, p_short_description_b text, p_updated_by bigint, p_question_columns integer, p_priority integer) OWNER TO postgres;

--
