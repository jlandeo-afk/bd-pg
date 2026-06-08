-- Function: odiseo.fn_list_verified_questions_co(integer, integer, character varying, integer, integer[], jsonb, jsonb, integer, character varying, json)

--

CREATE FUNCTION odiseo.fn_list_verified_questions_co(p_perpage integer, p_npage integer, p_name_text character varying, f_teacher_id integer, f_course_id integer[], f_topics_id jsonb, f_subtopics_id jsonb, f_didi_id integer, f_type character varying, f_status json) RETURNS TABLE(id bigint, key_question text, type_question text, code character varying, parent_id bigint, short_description text, subquestions jsonb, course_id smallint, course character varying, status character varying, teacher_id bigint, teacher text, didi_id bigint, didi text, date_status timestamp without time zone, level_id bigint, subtopic_id bigint, shared_status text, total_count bigint)
    LANGUAGE plpgsql
    AS $$
            DECLARE
                offset_val INTEGER;
                v_cut_off_date INTEGER;
                status_array varchar[];
            BEGIN
                -- Obtener la fecha de corte
                SELECT ads.cut_off_date INTO v_cut_off_date
                FROM advanced_settings AS ads
                WHERE ads.fl_status = TRUE
                LIMIT 1;

                offset_val := p_perpage * (p_npage - 1);

                IF f_status IS NULL THEN
                    status_array := ARRAY['VERI','PEND','RESV','APRB'];
                ELSIF jsonb_typeof(f_status::jsonb) = 'array' AND jsonb_array_length(f_status::jsonb) = 0 THEN
                    status_array := ARRAY['VERI','PEND','RESV','APRB'];
                ELSIF jsonb_typeof(f_status::jsonb) = 'array' THEN
                    SELECT array_agg(value::text)
                    INTO status_array
                    FROM jsonb_array_elements_text(f_status::jsonb);
                ELSIF jsonb_typeof(f_status::jsonb) = 'string' THEN
                    status_array := ARRAY[f_status::text];
                ELSE
                    status_array := ARRAY['VERI','PEND','RESV','APRB'];
                END IF;

                RETURN QUERY
                WITH first_verified AS (
                    SELECT qs.question_id, MIN(qs.created_at) as first_verified_at
                    FROM question_status qs
                    WHERE qs.status = 'VERI'
                    GROUP BY qs.question_id
                ),
                all_verified_questions AS (
                    SELECT
                        vq.id,
                        vq.code,
                        vq.status,
                        vq.short_description,
                        vq.parent_id,
                        vq.course_id,
                        c.name as course,
                        fv.first_verified_at as status_date,
                        vq.level_id,
                        vq.topic_id
                    FROM question vq
                    LEFT JOIN course c ON vq.course_id = c.id
                    LEFT JOIN first_verified fv ON fv.question_id = vq.id
                    WHERE vq.fl_status = TRUE
                    AND vq.deleted_at IS NULL
                    AND vq.status = ANY(status_array)
                    AND (
                        f_type IS NULL OR
                        (f_type = 'T' AND vq.parent_id IS NOT NULL) OR
                        (f_type = 'P' AND vq.parent_id IS NULL)
                    )
                ),
                verified_p_questions_expanded AS (
                    SELECT
                        q.id,
                        q.code,
                        q.status,
                        q.short_description,
                        q.parent_id,
                        q.course_id,
                        c.name AS course,
                        q.status_date,
                        q.level_id,
                        q.topic_id,
                        NULL::BIGINT AS share_id,
                        qs.subtopic_id::bigint AS subtopic_id,
                        FALSE AS is_shared,
                        get_shared_status(q.id, qs.subtopic_id) AS shared_status
                    FROM all_verified_questions q
                    INNER JOIN question_subtopic qs ON qs.question_id = q.id AND qs.fl_status = TRUE
                    INNER JOIN course c ON q.course_id = c.id
                    WHERE (f_course_id IS NULL OR q.course_id = ANY(f_course_id))
                    AND (f_topics_id IS NULL OR q.topic_id IN (
                        SELECT jsonb_array_elements_text(f_topics_id)::int
                    ))
                    AND (
                        f_subtopics_id IS NULL
                        OR (
                            qs.subtopic_id IN (
                                SELECT jsonb_array_elements_text(f_subtopics_id)::int
                            )
                            AND qs.deleted_at IS NULL
                        )
                    )

                    UNION ALL

                    SELECT
                        q.id,
                        qs.code,
                        q.status,
                        q.short_description,
                        q.parent_id,
                        t.course_id,
                        c.name AS course,
                        q.status_date,
                        q.level_id,
                        qs.topic_id,
                        qs.id AS share_id,
                        qs.subtopic_id,
                        TRUE AS is_shared,
                        get_shared_status(q.id, qs.subtopic_id) AS shared_status
                    FROM all_verified_questions q
                    INNER JOIN question_shares qs ON qs.question_id = q.id AND qs.deleted_at IS NULL
                    INNER JOIN topic t ON t.id = qs.topic_id
                    INNER JOIN course c ON t.course_id = c.id
                    WHERE (f_course_id IS NULL OR t.course_id = ANY(f_course_id))
                    AND (f_topics_id IS NULL OR qs.topic_id IN (
                        SELECT jsonb_array_elements_text(f_topics_id)::int
                    ))
                    AND (
                        f_subtopics_id IS NULL
                        OR (
                            qs.subtopic_id IN (
                                SELECT jsonb_array_elements_text(f_subtopics_id)::int
                            )
                            AND qs.deleted_at IS NULL
                        )
                    )
                ),
                verified_s_subquestions AS (
                    SELECT
                        oq.parent_id,
                        JSONB_AGG(
                            JSONB_BUILD_OBJECT(
                                'id', oq.id,
                                'key_question', CASE
                                    WHEN oq.is_shared THEN CONCAT('s_', oq.id, '_', oq.share_id)
                                    ELSE CONCAT('s_', oq.id)
                                END,
                                'type_question', 'S',
                                'code', oq.code,
                                'parent_id', oq.parent_id,
                                'short_description', oq.short_description,
                                'course_id', oq.course_id,
                                'course', oq.course,
                                'status', oq.status,
                                'teacher_id', es1.id,
                                'teacher', CONCAT(es1.first_surname, ' ', es1.second_surname, ' ', es1.first_name),
                                'didi_id', es2.id,
                                'didi', CONCAT(es2.first_surname, ' ', es2.second_surname, ' ', es2.first_name),
                                'date_status', oq.status_date
                            )
                        ) AS subquestions
                    FROM verified_p_questions_expanded oq
                    LEFT JOIN employee_question eoq ON eoq.question_id = oq.id AND eoq.fl_status = TRUE
                    LEFT JOIN employees es1 ON eoq.teacher_id = es1.id
                    LEFT JOIN employee_didi_question edq ON edq.question_id = oq.id AND edq.fl_status = TRUE
                    LEFT JOIN employees es2 ON edq.employee_id = es2.id
                    WHERE oq.parent_id IS NOT NULL
                    AND (f_type IS NULL OR f_type = 'T')
                    AND (f_teacher_id IS NULL OR es1.id = f_teacher_id)
                    AND (f_didi_id IS NULL OR es2.id = f_didi_id)
                    AND (
                        p_name_text IS NULL
                        OR LOWER(oq.code) LIKE '%' || LOWER(p_name_text) || '%'
                        OR unaccent(LOWER(oq.short_description)) LIKE '%' || LOWER(p_name_text) || '%'
                    )
                    GROUP BY oq.parent_id
                ),
                tbl_questions AS (
                    SELECT
                        q.id,
                        CASE
                            WHEN q.is_shared THEN 'p_' || q.id || '_s_' || q.share_id
                            ELSE 'p_' || q.id
                        END AS key_question,
                        'P' AS type_question,
                        q.code,
                        q.parent_id,
                        q.short_description,
                        NULL AS subquestions,
                        q.course_id,
                        q.course,
                        q.status,
                        e1.id AS teacher_id,
                        CONCAT(e1.first_surname, ' ', e1.second_surname, ' ', e1.first_name) AS teacher,
                        e2.id AS didi_id,
                        CONCAT(e2.first_surname, ' ', e2.second_surname, ' ', e2.first_name) AS didi,
                        q.status_date AS date_status,
                        q.level_id,
                        q.subtopic_id,
                        q.shared_status
                    FROM verified_p_questions_expanded q
                    LEFT JOIN employee_question eq ON eq.question_id = q.id AND eq.fl_status = TRUE
                    LEFT JOIN employees e1 ON eq.teacher_id = e1.id
                    LEFT JOIN employee_didi_question edq ON edq.question_id = q.id AND edq.fl_status = TRUE
                    LEFT JOIN employees e2 ON edq.employee_id = e2.id
                    WHERE (f_type IS NULL OR f_type = 'P')
                    AND q.parent_id IS NULL
                    AND (f_teacher_id IS NULL OR e1.id = f_teacher_id)
                    AND (f_didi_id IS NULL OR e2.id = f_didi_id)
                    AND (
                        p_name_text IS NULL
                        OR LOWER(q.code) LIKE '%' || LOWER(p_name_text) || '%'
                        OR unaccent(LOWER(q.short_description)) LIKE '%' || LOWER(p_name_text) || '%'
                    )
                    UNION ALL
                    SELECT
                        pq.id,
                        't_' || pq.id AS key_question,
                        'T' AS type_question,
                        pq.code,
                        pq.id AS parent_id,
                        pq.short_description,
                        COALESCE(vq.subquestions, '[]'::jsonb),
                        pq.course_id,
                        c.name,
                        pq.status,
                        0::BIGINT,
                        '',
                        0::BIGINT,
                        '',
                        pq.created_at,
                        pq.level_id,
                        NULL::BIGINT AS subtopic_id,
                        NULL::TEXT AS shared_status
                    FROM parent_question pq
                    INNER JOIN verified_s_subquestions vq ON vq.parent_id = pq.id
                    INNER JOIN course c ON pq.course_id = c.id
                    WHERE 1 = 1
                    AND EXISTS (
                        SELECT 1 FROM verified_p_questions_expanded avq
                        WHERE avq.parent_id = pq.id
                    )
                ),
                counted_questions AS (
                    SELECT *, count(*) OVER () AS total_count
                    FROM tbl_questions
                )
                SELECT *
                FROM counted_questions
                ORDER BY date_status DESC NULLS LAST
                LIMIT p_perpage
                OFFSET offset_val;
            END;
            $$;


ALTER FUNCTION odiseo.fn_list_verified_questions_co(p_perpage integer, p_npage integer, p_name_text character varying, f_teacher_id integer, f_course_id integer[], f_topics_id jsonb, f_subtopics_id jsonb, f_didi_id integer, f_type character varying, f_status json) OWNER TO postgres;

--
