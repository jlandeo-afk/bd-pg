-- Function: odiseo.fn_question_teacher_ia_by_id(bigint)

--

CREATE FUNCTION odiseo.fn_question_teacher_ia_by_id(p_id bigint) RETURNS TABLE(id bigint, description text, description_short text, course_id smallint, course_code character varying, course character varying, area_id bigint, course_alias_nq character varying, topic_id smallint, topic_code character varying, topic character varying, subtopic_id smallint, subtopic_code character varying, subtopic character varying, microtopic character varying, level_id bigint, level character varying, description_level character varying, answer_id bigint, answer_description text, answer_option character varying, theoretical_basis text, argumentation text, format character varying, type character varying, content character varying, teacher_id bigint, teacher character varying, status_revised boolean, date_revised timestamp without time zone, alternatives json, images json, images_solution json, version smallint, chat_feedback_id bigint, diagram_params json)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        SELECT
            qtia.id,
            qtia.description,
            qtia.description_short,
            qtia.course_id,
            c.code AS course_code,
            c.name AS course,
            c.area_id,
            c.alias_nq AS course_alias_nq,
            qtia.topic_id,
            t.code AS topic_code,
            t.name AS topic,
            qtia.subtopic_id,
            st.code AS subtopic_code,
            st.name AS subtopic,
            qtia.microtopic,
            qtia.level_id,
            l.name AS level,
            l.description AS description_level,
            qtia.answer_id,
            qtia.answer_description,
            answer_aqia.option AS answer_option,
            qtia.theoretical_basis,
            qtia.argumentation,
            qtia.format,
            qtia.type,
            qtia.content,
            qtia.teacher_id,
            CONCAT(e.first_name, ' ', e.first_surname, ' ', e.second_surname)::VARCHAR AS teacher,
            qtia.status_revised,
            oqnq.date_revised,
            (
                SELECT json_agg(row_to_json(a))
                FROM (
                    SELECT aqia.id, aqia.description, aqia.option,
                    (
                        SELECT json_agg(row_to_json(alt_img))
                        FROM (
                            SELECT aimg.code, aimg.extension, aimg.image, aimg.alternative_ia_id
                            FROM alternative_ia_images aimg
                            WHERE aimg.alternative_ia_id = aqia.id
                                AND aimg.fl_status = true
                            ORDER BY aimg.id ASC
                        ) AS alt_img
                    ) AS images
                    FROM alternative_questions_ia aqia
                    WHERE aqia.question_ia_id = qtia.id
                        AND aqia.fl_status = true
                    ORDER BY aqia.option ASC
                ) AS a
            ) AS alternatives,
            (
                SELECT json_agg(row_to_json(img))
                FROM (
                    SELECT qimg.code, qimg.extension, qimg.image, qimg.question_ia_id
                    FROM question_ia_images qimg
                    WHERE qimg.question_ia_id = qtia.id
                        AND qimg.fl_status = true
                    ORDER BY qimg.id ASC
                ) AS img
            ) AS images,
            (
                SELECT json_agg(row_to_json(sol_img))
                FROM (
                    SELECT simg.code, simg.extension, simg.image, simg.solution_ia_id
                    FROM solution_ia_images simg
                    WHERE simg.solution_ia_id = qtia.id
                        AND simg.fl_status = true
                    ORDER BY simg.id ASC
                ) AS sol_img
            ) AS images_solution,
            qtia.version,
            qtia.chat_feedback_id,
            (
                SELECT json_agg(
                    json_build_object(
                        'field',    fd.name_nq,
                        'name',     fd.name,
                        'field_diagrammed_id', fd.id,
                        'value',    qfdn.content
                    ) ORDER BY qfdn.position
                )
                FROM question_field_diagrammed_nq qfdn
                JOIN field_diagrammed fd ON fd.id = qfdn.field_diagrammed_id
                WHERE qfdn.question_teacher_ia_id = qtia.id
            ) AS diagram_params
        FROM question_teacher_ia qtia
        JOIN course c ON c.id = qtia.course_id
        JOIN topic t ON t.id = qtia.topic_id
        JOIN subtopic st ON st.id = qtia.subtopic_id
        JOIN level l ON l.id = qtia.level_id
        LEFT JOIN employees e ON e.id = qtia.teacher_id
        JOIN alternative_questions_ia answer_aqia ON answer_aqia.question_ia_id = qtia.id
            AND answer_aqia.id = qtia.answer_id
        LEFT JOIN origin_question_nq oqnq ON qtia.id = oqnq.question_ia_id
        WHERE qtia.id = p_id
            AND qtia.fl_status = true
            AND qtia.fl_parent = false;
    END;
    $$;


ALTER FUNCTION odiseo.fn_question_teacher_ia_by_id(p_id bigint) OWNER TO postgres;

--
