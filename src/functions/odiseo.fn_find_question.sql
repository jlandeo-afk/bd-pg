-- Function: odiseo.fn_find_question(integer, boolean)

--

CREATE FUNCTION odiseo.fn_find_question(f_question_id integer, f_status boolean) RETURNS TABLE(id bigint, code character varying, description text, short_description text, number_question character varying, number character varying, parent_id bigint, course_id smallint, code_course character varying, course character varying, topic_id smallint, code_topic character varying, topic character varying, subtopic_id smallint, code_subtopic character varying, subtopic character varying, level_id smallint, level character varying, teacher_id bigint, code_teacher character varying, first_name character varying, first_surname character varying, second_surname character varying, answer_id bigint, status character varying, fl_status boolean, observation text, similitaries text, created_by bigint, updated_by bigint, deleted_by bigint, created_at timestamp without time zone, updated_at timestamp without time zone, deleted_at timestamp without time zone, url_pdf character varying, config_alternative_id bigint, columns smallint, question_columns smallint, user_name character varying, user_email odiseo.email_citext, shared_status text)
    LANGUAGE plpgsql
    AS $$
                                    BEGIN
                                        RETURN QUERY
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
                                            s.id as subtopic_id,
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
                                            q.config_alternative_id,
                                            ca.columns,
                                            q.columns AS question_columns,
                                            u.user as user_name,
                                            u.email as user_email,
                                            get_shared_status(q.id, qs.subtopic_id) AS shared_status
                                        FROM question q
                                        LEFT JOIN course c ON q.course_id = c.id
                                        LEFT JOIN question_observation qo ON q.id = qo.question_id AND q.status = qo.type AND qo.fl_status = true
                                        LEFT JOIN topic t ON q.topic_id = t.id
                                        LEFT JOIN question_subtopic qs on qs.question_id = q.id
                                        LEFT JOIN subtopic s ON qs.subtopic_id = s.id
                                        LEFT JOIN level l ON q.level_id = l.id
                                        LEFT JOIN employees e ON q.teacher_id = e.id
                                        LEFT JOIN users u ON q.created_by = u.id
                                        LEFT JOIN configuration_alternative ca ON q.config_alternative_id = ca.id
                                        WHERE q.id = f_question_id
                                        AND q.fl_status = f_status
                                        AND q.deleted_at IS NULL;
                                    END;
                                    $$;


ALTER FUNCTION odiseo.fn_find_question(f_question_id integer, f_status boolean) OWNER TO postgres;

--
