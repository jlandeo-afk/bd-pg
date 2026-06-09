-- Function: questions.fn_find_question_subtopics(integer, integer)

--

CREATE FUNCTION questions.fn_find_question_subtopics(p_question_id integer, p_subtopic_id integer) RETURNS TABLE(id bigint, code character varying, description text, short_description text, number character varying, parent_id bigint, course_id smallint, code_course character varying, course character varying, question_columns smallint, code_topic character varying, topic character varying, level_id smallint, level character varying, teacher_id bigint, code_teacher character varying, answer_id bigint, status character varying, observation text, similitaries text, url_pdf character varying, config_alternative_id bigint, columns smallint, subtopics json, images json, alternatives json, priority integer, topic_code character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH context_data AS (
        SELECT
            q.id AS question_id,
            COALESCE(qsh.course_id, q.course_id) AS course_id,
            COALESCE(qsh.topic_id, q.topic_id) AS topic_id,
            qsh.subtopic_id,
            (qsh.id IS NOT NULL) AS has_share
        FROM question q
        LEFT JOIN question_shares qsh 
            ON qsh.question_id = q.id
            AND qsh.subtopic_id = p_subtopic_id
            AND qsh.deleted_at IS NULL
        WHERE q.id = p_question_id
    )

    SELECT
        q.id,
        q.code,
        q.description,
        q.short_description,
        q.number,
        q.parent_id,

        cd.course_id::SMALLINT,
        c.code AS code_course,
        c.name AS course,

        q.columns AS question_columns,

        t.code AS code_topic,
        t.name AS topic,

        q.level_id::SMALLINT,
        l.description AS level,

        q.teacher_id,
        e.code AS code_teacher,

        q.answer_id,
        q.status,

        qo.description as observation,
        qo.similitaries,

        q.url_pdf,
        q.config_alternative_id,
        ca.columns,

        CASE 
            WHEN cd.has_share THEN
                (
                    SELECT json_agg(
                        json_build_object(
                            'name', s2.name,
                            'code', s2.code
                        )
                    )
                    FROM subtopic s2
                    WHERE s2.id = cd.subtopic_id
                )
            ELSE
                COALESCE((
                    SELECT json_agg(
                        DISTINCT jsonb_build_object(
                            'name', st.name,
                            'code', st.code
                        )
                    )
                    FROM subtopic st
                    JOIN question_subtopic qst 
                        ON qst.subtopic_id = st.id
                    WHERE qst.question_id = q.id
                    AND qst.fl_status = true
                    AND st.fl_status = true
                ), '[]'::json)
        END AS subtopics,

        COALESCE((
            SELECT json_agg(json_build_object(
                'id', qi.id,
                'code', qi.code,
                'extension', qi.extension,
                'image', qi.image,
                'question_id', qi.question_id
            ))
            FROM question_image qi
            WHERE qi.question_id = q.id
            AND qi.fl_status = true
        ), '[]'::json) AS images,

        COALESCE((
            SELECT json_agg(json_build_object(
                'id', alt.id,
                'description', alt.description,
                'question_id', alt.question_id,
                'value', CASE WHEN q.answer_id = alt.id THEN true ELSE false END
            ))
            FROM (
                SELECT 
                    alt.id,
                    alt.description,
                    alt.question_id
                FROM alternative alt
                WHERE alt.question_id = q.id
                AND alt.fl_status = true
                ORDER BY alt.id ASC
            ) AS alt
        ), '[]'::json) AS alternatives,

        q.priority,
        t.code AS topic_code

    FROM context_data cd
    JOIN question q ON q.id = cd.question_id

    LEFT JOIN course c ON c.id = cd.course_id
    LEFT JOIN topic t ON t.id = cd.topic_id
    LEFT JOIN level l ON l.id = q.level_id
    LEFT JOIN employees e ON q.teacher_id = e.id
    LEFT JOIN question_observation qo 
        ON q.id = qo.question_id 
        AND q.status = qo.type 
        AND qo.fl_status = true
    LEFT JOIN configuration_alternative ca 
        ON q.config_alternative_id = ca.id

    WHERE q.fl_status = true
    AND q.deleted_at IS NULL;

END;
$$;


ALTER FUNCTION questions.fn_find_question_subtopics(p_question_id integer, p_subtopic_id integer) OWNER TO postgres;

--
