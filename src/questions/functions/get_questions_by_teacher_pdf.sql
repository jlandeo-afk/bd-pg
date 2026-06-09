-- Function: questions.get_questions_by_teacher_pdf(integer[])

--

CREATE FUNCTION questions.get_questions_by_teacher_pdf(question_ids integer[]) RETURNS TABLE(question_id bigint, course_id smallint, curso character varying, topic_id smallint, tema character varying, answer_id bigint, question_description text, alternatives jsonb)
    LANGUAGE plpgsql
    AS $$
        BEGIN
        RETURN QUERY
        SELECT
            q.id AS question_id,
            q.course_id,
            c."name" AS curso,
            q.topic_id,
            t."name" AS tema,
            q.answer_id,
            q.description AS question_description,
            jsonb_agg(jsonb_build_object('id', a.id, 'description', a.description)) AS alternatives
        FROM
            questions.question q
        LEFT JOIN
            questions.alternative a ON a.question_id = q.id
        LEFT JOIN
            academic.topic t ON q.topic_id = t.id
        LEFT JOIN
            academic.course c ON q.course_id = c.id
        WHERE
            q.id = ANY(question_ids)
        GROUP BY
            q.id,
            q.course_id,
            q.answer_id,
            t.name,
            c.name,
            q.topic_id,
            q.description
        ORDER BY
            t."name" ASC, 
            c."name" ASC;
        END;
        $$;


ALTER FUNCTION questions.get_questions_by_teacher_pdf(question_ids integer[]) OWNER TO postgres;

--
