-- Function: questions.fn_change_status_parent_question(bigint, bigint)

--

CREATE FUNCTION questions.fn_change_status_parent_question(p_parent_question_id bigint, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
            BEGIN
                WITH subquestion_status AS (
                    SELECT
                        q.id,
                        q.parent_id,
                        qs.status,
                        qs.description,
                        qs.process
                    FROM question q
                    JOIN parent_question pq ON q.parent_id = pq.id
                        AND pq.status = 'DUPL'
                    JOIN (
                        SELECT DISTINCT ON (question_id) *
                        FROM question_status
                        WHERE fl_active = false
                            AND status <> 'DUPL'
                        ORDER BY question_id, created_at DESC
                    ) qs ON qs.question_id = q.id
                    WHERE q.parent_id = p_parent_question_id
                    ORDER BY qs.status ASC
                ), get_status_to_change AS (
                    SELECT
                        qs.status,
                        qs.process
                    FROM subquestion_status qs
                    LIMIT 1
                ), change_status_parent_question AS (
                    UPDATE parent_question pq
                    SET status = (select gstc.status from get_status_to_change gstc)
                    WHERE pq.id = p_parent_question_id
                ), delete_observation_parent AS (
                    UPDATE parent_observation po
                    SET fl_status = false,
                        deleted_at = now(),
                        deleted_by = p_updated_by
                    WHERE po.parent_id = p_parent_question_id
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
                            LOWER(gstc.process),
                            ' por el ',
                            uc.rol,
                            ' <span class="text-user">',
                            uc.user_name,
                            '</span>'
                        )::VARCHAR description,
                        gstc.process,
                        gstc.status
                    FROM user_created uc, get_status_to_change gstc
                    LIMIT 1
                ), subquestion AS (
                    SELECT
                        q.id,
                        da.description,
                        da.process,
                        da.status
                    FROM question q, desription_archived da
                    WHERE q.parent_id = p_parent_question_id
                    AND q.fl_status = true
                ), desactive_status AS (
                    UPDATE question_status
                    SET fl_active = false
                    WHERE question_id IN (
                        SELECT id
                        FROM subquestion
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

                RETURN;
            END;
            $$;


ALTER FUNCTION questions.fn_change_status_parent_question(p_parent_question_id bigint, p_updated_by bigint) OWNER TO postgres;

--
