-- Function: questions.fn_archived_parent_questions(bigint, bigint)

--

CREATE FUNCTION questions.fn_archived_parent_questions(p_parent_question_id bigint, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
            BEGIN
                WITH archived_parent_question AS (
                    UPDATE parent_question pq
                    SET status = 'ARCH'
                    WHERE pq.id = p_parent_question_id
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
                            'La pregunta ha sido archivada por el ',
                            uc.rol,
                            ' <span class="text-user">',
                            uc.user_name,
                            '</span>'
                        )::VARCHAR description,
                        'ARCHIVADO'::VARCHAR process,
                        'ARCH'::VARCHAR "status"
                    FROM user_created uc
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


ALTER FUNCTION questions.fn_archived_parent_questions(p_parent_question_id bigint, p_updated_by bigint) OWNER TO postgres;

--
