-- Function: questions.fn_get_essential_knowledge_by_question_id(bigint)

--

CREATE FUNCTION questions.fn_get_essential_knowledge_by_question_id(p_question_id bigint) RETURNS TABLE(course_id smallint, topic_id smallint, essential_knowledge jsonb)
    LANGUAGE plpgsql
    AS $$
BEGIN

    RETURN QUERY
    SELECT
        q.course_id,
        q.topic_id,

        COALESCE(
            jsonb_agg(
                DISTINCT jsonb_build_object(
                    'id', ek.id,
                    'code', ek.code,
                    'name', ek.name,
                    'course_id', ek.course_id,
                    'topic_id', ek.topic_id,
                    'image', eki.image
                )
            ) FILTER (WHERE ek.id IS NOT NULL),
            '[]'::jsonb
        ) AS essential_knowledge

    FROM question q

    LEFT JOIN essential_knowledge_questions ekq
        ON q.id = ekq.question_id
        AND ekq.deleted_at IS NULL

    LEFT JOIN essential_knowledges ek
        ON ek.id = ekq.essential_knowledge_id
        AND ek.is_active IS TRUE
        AND ek.deleted_at IS NULL

    LEFT JOIN essential_knowledge_image eki
        ON ek.id = eki.essential_knowledge_id
        AND eki.deleted_at IS NULL

    WHERE q.id = p_question_id

    GROUP BY q.course_id, q.topic_id;

END;
$$;


ALTER FUNCTION questions.fn_get_essential_knowledge_by_question_id(p_question_id bigint) OWNER TO postgres;

--
