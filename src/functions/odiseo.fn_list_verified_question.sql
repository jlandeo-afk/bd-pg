-- Function: odiseo.fn_list_verified_question(character varying, integer, integer, integer, character varying, json, json, json, integer, integer, integer, integer, character varying, integer[], smallint, smallint, smallint, smallint, character varying)

--

CREATE FUNCTION odiseo.fn_list_verified_question(f_name_text character varying, f_employee_id integer, f_course_id integer, f_teacher_id integer, f_type character varying, f_topics_id json, f_subtopics_id json, f_status json, f_cycle_id integer, f_week_id integer, f_type_material_id integer, f_level_id integer, f_number_question character varying, f_array_courses integer[], f_university_id smallint, f_option_id smallint, f_modality_id smallint, f_version smallint, f_year character varying) RETURNS TABLE(id bigint, key_question text, parent_id bigint, subquestions jsonb, type_question text, code character varying, number_question character varying, short_description text, course_id smallint, course character varying, teacher_id bigint, subtopic_id bigint, teacher text, status character varying, date_status timestamp without time zone, observation text, level_id smallint, level_question character varying, origin_question jsonb, shared_status text, total_count bigint)
    LANGUAGE plpgsql
    AS $$
                DECLARE status_array VARCHAR[];
                BEGIN
                    IF f_status IS NULL THEN
                        status_array := ARRAY['DIGI', 'VERI', 'PEND', 'RESV','APRB'];
                    ELSIF jsonb_typeof(f_status::jsonb) = 'array' AND jsonb_array_length(f_status::jsonb) = 0 THEN
                        status_array := ARRAY['DIGI', 'VERI', 'PEND', 'RESV','APRB'];
                    ELSIF jsonb_typeof(f_status::jsonb) = 'array' THEN
                        SELECT array_agg(value::text)
                        INTO status_array
                        FROM jsonb_array_elements_text(f_status::jsonb);
                    ELSIF jsonb_typeof(f_status::jsonb) = 'string' THEN
                        status_array := ARRAY[f_status::text];
                    ELSE
                        status_array := ARRAY['DIGI', 'VERI', 'PEND', 'RESV','APRB'];
                    END IF;

                    RETURN QUERY
                    WITH first_verified_date AS (
                        SELECT
                            qss.question_id,
                            MIN(qss.created_at) date_status
                        FROM question_status qss
                        WHERE qss.status = 'VERI'
                        GROUP BY qss.question_id
                    ), verified_p_questions AS (
                        SELECT
                            vf.id,
                            vf.code,
                            vf.status,
                            vf.short_description,
                            vf.parent_id,
                            vf.course_id,
                            vf.fl_status,
                            vf.topic_id,
                            vf.number_question,
                            fvd.date_status,
                            vf.level_id,
                            CASE
                                WHEN l.name IS NOT NULL THEN l.name
                                ELSE l.description
                            END AS level_question,
                            qn.question_origin,
                            qn.university_id,
                            qn.option_id,
                            qn.modality_id,
                            qn."version",
                            qn."year"
                        FROM question vf
                        LEFT JOIN v_all_question_origins qn ON qn.question_id = vf.id
                        LEFT JOIN first_verified_date fvd ON fvd.question_id = vf.id
                        LEFT JOIN level l ON l.id = vf.level_id
                        WHERE 1 = 1
                        AND vf.fl_status = TRUE
                        AND vf.deleted_at IS NULL
                        AND vf.status = ANY(status_array)
                        AND (f_number_question IS NULL OR vf.number_question ILIKE CONCAT('%', f_number_question, '%'))
                        AND ( f_university_id IS NULL OR qn.university_id = f_university_id )
                        AND ( f_option_id IS NULL OR qn.option_id = f_option_id )
                        AND ( f_modality_id IS NULL OR qn.modality_id = f_modality_id )
                        AND ( f_version IS NULL OR qn."version" = f_version )
                        AND ( f_year IS NULL OR qn."year" = f_year )
                    ),
                    shared_status_cte AS (
                        SELECT DISTINCT
                            qsh.question_id,
                            qsh.subtopic_id,
                            'shared'::TEXT AS shared_status
                        FROM question_shares qsh
                        WHERE qsh.deleted_at IS NULL
                    ),
                    verified_p_questions_expanded AS (

                    /* Preguntas normales */
                    SELECT
                        q.id,
                        q.code,
                        q.status,
                        q.short_description,
                        q.parent_id,
                        q.course_id,
                        q.fl_status,
                        q.topic_id,
                        NULL::BIGINT AS share_id,
                        qs.subtopic_id::BIGINT AS subtopic_id,
                        FALSE AS is_shared,
                        q.number_question,
                        q.date_status,
                        q.level_id,
                        q.level_question,
                        q.question_origin,
                        q.university_id,
                        q.option_id,
                        q.modality_id,
                        q."version",
                        q."year",

                        COALESCE(
                            ss.shared_status,
                            'not_shared'
                        ) AS shared_status

                    FROM verified_p_questions q

                    INNER JOIN question_subtopic qs
                        ON qs.question_id = q.id
                        AND qs.fl_status = TRUE

                    LEFT JOIN shared_status_cte ss
                        ON ss.question_id = q.id
                        AND ss.subtopic_id = qs.subtopic_id


                    UNION ALL


                    /* Preguntas compartidas */
                    SELECT
                        q.id,
                        qs.code,
                        q.status,
                        q.short_description,
                        q.parent_id,
                        t.course_id,
                        q.fl_status,
                        qs.topic_id,
                        qs.id AS share_id,
                        qs.subtopic_id,
                        TRUE AS is_shared,
                        q.number_question,
                        q.date_status,
                        q.level_id,
                        q.level_question,
                        q.question_origin,
                        q.university_id,
                        q.option_id,
                        q.modality_id,
                        q."version",
                        q."year",

                        COALESCE(
                            ss.shared_status,
                            'not_shared'
                        ) AS shared_status

                    FROM verified_p_questions q

                    INNER JOIN question_shares qs
                        ON qs.question_id = q.id
                        AND qs.deleted_at IS NULL

                    INNER JOIN topic t
                        ON t.id = qs.topic_id

                    LEFT JOIN shared_status_cte ss
                        ON ss.question_id = q.id
                        AND ss.subtopic_id = qs.subtopic_id
                ),filtered_questions AS (
                        /* P questions */
                        SELECT
                            DISTINCT q.id AS id,
                            CASE
                                WHEN q.is_shared THEN 'f_' || q.id || '_s_' || q.share_id
                                ELSE 'f_' || q.id
                            END AS key_question,
                            pq.id AS parent_id,
                            NULL::JSONB AS subquestions,
                            'P' AS type_question,
                            q.code AS code,
                            q.number_question AS number_question,
                            q.short_description AS short_description,
                            q.course_id,
                            c.name AS course,
                            eq.teacher_id,
                            q.subtopic_id,
                            CONCAT(e.first_surname,' ', e.second_surname,' ', e.first_name) AS teacher,
                            q.status status,
                            q.date_status AS date_status,
                            '' AS observation,
                            q.level_id::SMALLINT AS level_id,
                            q.level_question AS level_question,
                            q.question_origin,
                            q.shared_status
                        FROM employee_didi_question edq
                        INNER JOIN verified_p_questions_expanded q ON edq.question_id = q.id
                        LEFT JOIN parent_question pq ON q.parent_id = pq.id
                        LEFT JOIN course c ON q.course_id = c.id
                        LEFT JOIN employee_question eq ON eq.question_id = q.id AND eq.fl_status = true
                        LEFT JOIN employees e ON eq.teacher_id = e.id
                        LEFT JOIN question_subtopic qsub ON edq.question_id = qsub.question_id AND qsub.fl_status = TRUE AND q.is_shared = FALSE
                        WHERE 1 = 1
                        AND ( ( f_type IS NULL OR f_type = 'P' ) AND q.parent_id IS NULL )
                        AND (f_employee_id IS NULL OR q.course_id = ANY(f_array_courses))
                        AND (f_teacher_id IS NULL OR e.id = f_teacher_id)
                        AND q.status = ANY(status_array)
                        AND (f_level_id IS NULL OR q.level_id = f_level_id)
                        AND (f_topics_id IS NULL OR q.topic_id = ANY (SELECT jsonb_array_elements_text(f_topics_id::jsonb)::int))
                        AND (f_course_id IS NULL OR q.course_id = f_course_id)
                        AND (f_number_question IS NULL OR q.number_question ILIKE CONCAT('%', f_number_question, '%'))
                        AND (
                            f_subtopics_id IS NULL
                            OR (
                                COALESCE(q.subtopic_id, qsub.subtopic_id) IS NOT NULL
                                AND COALESCE(q.subtopic_id, qsub.subtopic_id) = ANY (SELECT jsonb_array_elements_text(f_subtopics_id::jsonb)::int)
                            )
                        )
                        AND (
                            f_name_text IS NULL
                            OR LOWER(translate(q.code, E'\u00A0', ' ')) ILIKE '%' || LOWER(f_name_text) || '%'
                            OR LOWER(translate(q.number_question, E'\u00A0', ' ')) ILIKE '%' || LOWER(f_name_text) || '%'
                            OR unaccent(LOWER(translate(q.short_description, E'\u00A0', ' '))) ILIKE '%' || LOWER(f_name_text) || '%'
                        )

                        UNION ALL

                        /* T questions */
                        SELECT
                            pq.id AS id,
                            't_' || pq.id AS key_question,
                            pq.id AS parent_id,
                            JSONB_AGG(
                                JSONB_BUILD_OBJECT(
                                    'key_question', CASE
                                        WHEN q.is_shared THEN CONCAT('s_', q.id, '_', q.share_id)
                                        ELSE CONCAT('s_', q.id)
                                    END,
                                    'id', q.id,
                                    'code', q.code,
                                    'course_id', q.course_id,
                                    'course', cq.name,
                                    'status', q.status,
                                    'teacher', CONCAT(e.first_surname,' ', e.second_surname,' ', e.first_name),
                                    'subtopic_id', q.subtopic_id,
                                    'date_status', q.date_status,
                                    'short_description', q.short_description,
                                    'type_question', 'S',
                                    'parent_id', q.parent_id,
                                    'number_question', q.number_question,
                                    'level_id', q.level_id,
                                    'level_question', q.level_question,
                                    'origin_question', q.question_origin
                                )
                            ) AS subquestions,
                            'T' AS type_question,
                            pq.code AS code,
                            pq.number_question AS number_question,
                            pq.short_description AS short_description,
                            pq.course_id,
                            c.name AS course,
                            NULL::BIGINT AS teacher_id,
                            NULL::INTEGER AS subtopic_id,
                            NULL::TEXT AS teacher,
                            pq.status status,
                            MIN(q.date_status) AS date_status,
                            '' AS observation,
                            pq.level_id::SMALLINT AS level_id,
                            CASE
                                WHEN l.name IS NOT NULL THEN l.name
                                ELSE l.description
                            END AS level_question,
                            opq.question_origin,
                            NULL::TEXT AS shared_status
                        FROM parent_question pq
                                                JOIN verified_p_questions_expanded q ON pq.status = ANY(status_array) AND pq.id = q.parent_id AND q.fl_status IS TRUE
                        LEFT JOIN course c ON pq.course_id = c.id
                                                LEFT JOIN course cq ON q.course_id = cq.id
                        LEFT JOIN level l ON l.id = pq.level_id
                        LEFT JOIN odiseo.v_all_parent_origins opq ON opq.parent_id = pq.id
                        LEFT JOIN employee_question eq ON eq.question_id = q.id AND eq.fl_status = true
                        LEFT JOIN employees e ON eq.teacher_id = e.id
                        WHERE 1 = 1
                                                    AND ( f_type IS NULL OR f_type = 'T' )
                          AND ( f_teacher_id IS NULL OR e.id = f_teacher_id )
                          AND ( f_level_id IS NULL OR q.level_id = f_level_id )
                          AND ( f_topics_id IS NULL OR q.topic_id = ANY(SELECT jsonb_array_elements_text(f_topics_id::jsonb)::int) )
                                                    AND ( f_course_id IS NULL OR q.course_id = f_course_id )
                          AND ( f_employee_id IS NULL OR q.course_id = ANY(f_array_courses) )
                          AND ( f_number_question IS NULL OR q.number_question ILIKE CONCAT('%', f_number_question, '%') )
                                                    AND ( f_university_id IS NULL OR opq.university_id = f_university_id OR q.university_id = f_university_id )
                                                    AND ( f_option_id IS NULL OR opq.option_id = f_option_id OR q.option_id = f_option_id )
                                                    AND ( f_modality_id IS NULL OR opq.modality_id = f_modality_id OR q.modality_id = f_modality_id )
                                                    AND ( f_version IS NULL OR opq."version" = f_version OR q."version" = f_version )
                                                    AND ( f_year IS NULL OR opq."year" = f_year OR q."year" = f_year )
                          AND ( f_number_question IS NULL OR (f_number_question IS NOT NULL AND (q.number_question ILIKE CONCAT('%', f_number_question,'%' ))) )
                        GROUP BY
                            pq.id,
                            c.id,
                            l.id,
                            opq.question_origin
                        HAVING 1 = 1
                           AND (
                                f_name_text IS NULL
                                OR f_name_text = ''
                                OR LOWER(pq.number_question) ILIKE '%' || LOWER(f_name_text) || '%'
                                OR LOWER(pq.code) ILIKE '%' || LOWER(f_name_text) || '%'
                                OR BOOL_OR(LOWER(q.number_question) ILIKE '%' || LOWER(f_name_text) || '%')
                                OR BOOL_OR(LOWER(q.code) ILIKE '%' || LOWER(f_name_text) || '%')
                           )
                    ),
                   counted_questions AS (
                        SELECT COUNT(*) AS total_count
                        FROM filtered_questions
                    )

                    SELECT
                        fq.id,
                        fq.key_question,
                        fq.parent_id,
                        fq.subquestions,
                        fq.type_question,
                        fq.code,
                        fq.number_question,
                        fq.short_description,
                        fq.course_id,
                        fq.course,
                        fq.teacher_id,
                        fq.subtopic_id,
                        fq.teacher,
                        fq.status,
                        fq.date_status,
                        fq.observation,
                        fq.level_id,
                        fq.level_question,
                        fq.question_origin AS origin_question,
                        fq.shared_status,
                        cq.total_count
                    FROM filtered_questions fq
                    CROSS JOIN counted_questions cq
                    ORDER BY
                        CASE
                            WHEN fq.status = 'VERI' THEN 1
                            WHEN fq.status = 'DIGI' THEN 2
                            ELSE 3
                        END,
                        CASE
                            WHEN fq.status = 'VERI' THEN fq.date_status
                        END,
                        CASE
                            WHEN fq.status = 'DIGI' THEN fq.date_status
                        END,
                        fq.id ASC;
                END;
                $$;


ALTER FUNCTION odiseo.fn_list_verified_question(f_name_text character varying, f_employee_id integer, f_course_id integer, f_teacher_id integer, f_type character varying, f_topics_id json, f_subtopics_id json, f_status json, f_cycle_id integer, f_week_id integer, f_type_material_id integer, f_level_id integer, f_number_question character varying, f_array_courses integer[], f_university_id smallint, f_option_id smallint, f_modality_id smallint, f_version smallint, f_year character varying) OWNER TO postgres;

--
