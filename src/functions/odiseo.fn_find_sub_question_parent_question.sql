-- Function: odiseo.fn_find_sub_question_parent_question(integer, boolean)

--

CREATE FUNCTION odiseo.fn_find_sub_question_parent_question(p_parent_question_id integer, p_status boolean) RETURNS TABLE(id bigint, code character varying, description text, short_description text, number_question character varying, number character varying, parent_id bigint, course_id smallint, code_course character varying, course character varying, topic_id smallint, code_topic character varying, topic character varying, subtopics jsonb, level_id smallint, level character varying, answer_id bigint, status character varying, fl_status boolean, observation text, similitaries text, created_by bigint, updated_by bigint, deleted_by bigint, created_at timestamp without time zone, updated_at timestamp without time zone, deleted_at timestamp without time zone, url_pdf character varying, user_name character varying, user_email odiseo.email_citext)
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                    RETURN QUERY
                    WITH subtopics_cte AS (
                        SELECT 
                            qs.question_id,
                            jsonb_agg(
                                jsonb_build_object(
                                    'id', s.id,
                                    'code', s.code,
                                    'name', s.name
                                )
                            ) subtopics
                        FROM question_subtopic qs
                        JOIN question q ON q.id = qs.question_id
                        JOIN subtopic s ON s.id = qs.subtopic_id 
                        WHERE q.parent_id = p_parent_question_id AND qs.fl_status = TRUE
                        GROUP BY qs.question_id
                    )
                    SELECT
                        q.id,
                        q.code,
                        q.description,
                        q.short_description,
                        q.number_question,
                        q.number,
                        q.parent_id,
                        q.course_id,
                        c.code AS code_course,
                        c.name AS course,
                        q.topic_id,
                        t.code AS code_topic,
                        t.name AS topic,
                        sc.subtopics,
                        q.level_id,
                        l.description AS level,
                        q.answer_id,
                        q.status,
                        q.fl_status,
                        qo.description as observation,
                        qo.similitaries,
                        q.created_by,
                        q.updated_by,
                        q.deleted_by,
                        q.created_at,
                        q.updated_at,
                        q.deleted_at,
                        q.url_pdf,
                        u.user as user_name,
                        u.email as user_email
                    FROM question q
                    LEFT JOIN course c ON q.course_id = c.id
                    LEFT JOIN question_observation qo ON q.id = qo.question_id AND q.status = qo.type
                    LEFT JOIN topic t ON q.topic_id = t.id
                    LEFT JOIN question_subtopic qs ON q.id = qs.question_id AND qs.fl_status = true
                    LEFT JOIN level l ON q.level_id = l.id
                    LEFT JOIN users u ON q.created_by = u.id
                    LEFT JOIN subtopics_cte sc ON sc.question_id = q.id
                    WHERE q.parent_id = p_parent_question_id
                    AND q.fl_status = p_status
                    AND q.deleted_at IS NULL;
                    END;
                    $$;


ALTER FUNCTION odiseo.fn_find_sub_question_parent_question(p_parent_question_id integer, p_status boolean) OWNER TO postgres;

--
