-- Function: questions.fn_question(integer, integer, character varying, character varying, integer, integer, integer, integer, integer, character varying)

--

CREATE FUNCTION questions.fn_question(p_perpage integer, p_npage integer, f_status character varying, p_name_text character varying, f_course_id integer, f_topic_id integer, f_subtopic_id integer, f_level_id integer, f_teacher_id integer, f_type character varying) RETURNS TABLE(id bigint, code character varying, description text, short_description text, number_question character varying, number character varying, course_id smallint, code_course character varying, course character varying, topic_id smallint, code_topic character varying, topic character varying, subtopic_id smallint, code_subtopic character varying, subtopic character varying, level_id smallint, level character varying, teacher_id bigint, code_teacher character varying, first_name character varying, first_surname character varying, second_surname character varying, answer_id bigint, status character varying, fl_status boolean, observation text, similitaries text, created_by bigint, updated_by bigint, deleted_by bigint, created_at timestamp without time zone, updated_at timestamp without time zone, deleted_at timestamp without time zone, url_pdf character varying, user_name character varying, user_email odiseo.email_citext, total integer)
    LANGUAGE plpgsql
    AS $$
                                DECLARE
                                    total_count INTEGER;
                                    offset_val INTEGER;
                                BEGIN
                                    offset_val := p_perpage * (p_npage - 1);

                                    SELECT COUNT(*)
                                    INTO total_count
                                    FROM question q
                                    LEFT JOIN course c ON q.course_id = c.id
                                    LEFT JOIN topic t ON q.topic_id = t.id
                                    LEFT JOIN subtopic s ON q.subtopic_id = s.id
                                    LEFT JOIN level l ON q.level_id = l.id
                                    LEFT JOIN employees e ON q.teacher_id = e.id
                                    AND q.fl_status = true
                                    AND q.deleted_at IS NULL
                                    AND (f_status IS NULL OR q.status = f_status)
                                    AND (f_course_id IS NULL OR q.course_id = f_course_id)
                                    AND (f_topic_id IS NULL OR q.topic_id = f_topic_id)
                                    AND (f_subtopic_id IS NULL OR q.subtopic_id = f_subtopic_id)
                                    AND (f_level_id IS NULL OR q.level_id = f_level_id)
                                    AND (f_teacher_id IS NULL OR q.teacher_id = f_teacher_id)
                                    AND (f_type IS NULL OR q.type = f_type)
                                    AND (
                                        p_name_text IS NULL
                                        OR LOWER(unaccent(q.short_description)) LIKE '%' || LOWER(unaccent(p_name_text)) || '%'
                                        OR LOWER(q.number_question) LIKE '%' || LOWER(p_name_text) || '%'
                                        OR LOWER(q.number) LIKE '%' || LOWER(p_name_text) || '%'
                                    );

                                    RETURN QUERY
                                    SELECT
                                        q.id,
                                        q.code,
                                        q.description,
                                        q.short_description,
                                        q.number_question,
                                        q.number,
                                        q.course_id,
                                        c.code AS code_course,
                                        c.name AS course,
                                        q.topic_id,
                                        t.code AS code_topic,
                                        t.name AS topic,
                                        q.subtopic_id,
                                        s.code AS code_subtopic,
                                        s.name AS subtopic,
                                        q.level_id,
                                        l.description AS level,
                                        q.teacher_id,
                                        e.code AS code_teacher,
                                        e.first_name,
                                        e.first_surname,
                                        e.second_surname,
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
                                        u.email as user_email,
                                        total_count AS total
                                    FROM question q
                                    LEFT JOIN course c ON q.course_id = c.id
                                    LEFT JOIN question_observation qo ON q.id = qo.question_id AND q.status = qo.type
                                    LEFT JOIN topic t ON q.topic_id = t.id
                                    LEFT JOIN subtopic s ON q.subtopic_id = s.id
                                    LEFT JOIN level l ON q.level_id = l.id
                                    LEFT JOIN employees e ON q.teacher_id = e.id
                                    LEFT JOIN users u ON q.created_by = u.id
                                    AND q.fl_status = true
                                                                        AND q.deleted_at IS NULL
                                                                        AND (f_type IS NULL OR q.type = f_type)
                                                                        AND (
                                                                            p_name_text IS NULL
                                                                            OR LOWER(unaccent(q.short_description)) LIKE '%' || LOWER(unaccent(p_name_text)) || '%'
                                                                                                                OR LOWER(q.number_question) LIKE '%' || LOWER(p_name_text) || '%'
                                                                                                                OR LOWER(q.number) LIKE '%' || LOWER(p_name_text) || '%'
                                                                        )
                                                                        ORDER BY q.id ASC
                                                                        LIMIT p_perpage
                                                                        OFFSET offset_val;

                                END;
                                $$;


ALTER FUNCTION questions.fn_question(p_perpage integer, p_npage integer, f_status character varying, p_name_text character varying, f_course_id integer, f_topic_id integer, f_subtopic_id integer, f_level_id integer, f_teacher_id integer, f_type character varying) OWNER TO postgres;

--
