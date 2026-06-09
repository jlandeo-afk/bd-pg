-- Function: questions.fn_get_questions_ia(boolean, text, integer, character varying, integer, integer, integer)

--

CREATE FUNCTION questions.fn_get_questions_ia(p_status_revised boolean, p_search_term text DEFAULT NULL::text, p_course_id integer DEFAULT NULL::integer, p_status character varying DEFAULT NULL::character varying, p_teacher_id integer DEFAULT NULL::integer, p_page integer DEFAULT 1, p_per_page integer DEFAULT 15) RETURNS TABLE(id bigint, description text, course_id smallint, course character varying, course_code character varying, topic_id smallint, topic_code character varying, topic character varying, subtopic_id smallint, subtopic_code character varying, subtopic character varying, level_id bigint, level character varying, description_level character varying, teacher_id bigint, teacher text, status_revised boolean, created_at timestamp without time zone, date_revised timestamp without time zone, question_id bigint, code character varying, status character varying, verification_time character varying, total_records bigint)
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                        RETURN QUERY
                        SELECT
                            qtia.id,
                            qtia.description_short AS description,
                            qtia.course_id,
                            c.name AS course,
                            c.code AS course_code,
                            qtia.topic_id,
                            t.code AS topic_code,
                            t.name AS topic,
                            qtia.subtopic_id,
                            st.code AS subtopic_code,
                            st.name AS subtopic,
                            qtia.level_id,
                            l.name AS level,
                            l.description AS description_level,
                            qtia.teacher_id,
                            CASE
                                WHEN qtia.teacher_id IS NOT NULL THEN
                                    e.first_name || ' ' || e.first_surname || ' ' || e.second_surname
                                ELSE NULL
                            END AS teacher,
                            qtia.status_revised,
                            qtia.created_at,
                            oqnq.date_revised,
                            q.id AS question_id,
                            q.code,
                            q.status,
                            (LPAD(
                                FLOOR(
                                    EXTRACT(EPOCH FROM (
                                        qtia.verification_finished_at - qtia.verification_started_at
                                    )) / 60
                                )::TEXT,
                                2,
                                '0'
                            ) || ':' ||
                            LPAD(
                                MOD(
                                    FLOOR(EXTRACT(EPOCH FROM (
                                        qtia.verification_finished_at - qtia.verification_started_at
                                    ))),
                                    60
                                )::TEXT,
                                2,
                                '0'
                            ))::VARCHAR AS verification_time,
                            COUNT(*) OVER() AS total_records
                        FROM
                            question_teacher_ia AS qtia
                        JOIN course AS c ON c.id = qtia.course_id
                        JOIN topic AS t ON t.id = qtia.topic_id
                        JOIN subtopic AS st ON st.id = qtia.subtopic_id
                        JOIN level AS l ON l.id = qtia.level_id
                        LEFT JOIN employees AS e ON e.id = qtia.teacher_id
                        LEFT JOIN origin_question_nq AS oqnq ON qtia.id = oqnq.question_ia_id
                        LEFT JOIN question AS q ON oqnq.question_id = q.id
                        WHERE
                            qtia.fl_status = true
                            AND qtia.status_revised = p_status_revised
                            AND (p_search_term IS NULL
                                OR unaccent(qtia.description) ILIKE '%' || unaccent(p_search_term) || '%'
                                OR q.code ILIKE '%' || p_search_term || '%')
                            AND (p_course_id IS NULL OR qtia.course_id = p_course_id)
                            AND (p_teacher_id IS NULL OR qtia.teacher_id = p_teacher_id)
                            AND (p_status IS NULL OR q.status = p_status)
                        ORDER BY
                            qtia.created_at ASC
                        LIMIT
                            p_per_page
                        OFFSET
                            (p_page - 1) * p_per_page;
                    END;
                    $$;


ALTER FUNCTION questions.fn_get_questions_ia(p_status_revised boolean, p_search_term text, p_course_id integer, p_status character varying, p_teacher_id integer, p_page integer, p_per_page integer) OWNER TO postgres;

--
