-- Function: questions.get_shared_status(bigint, integer)

--

CREATE FUNCTION questions.get_shared_status(p_question_id bigint, p_subtopic_id integer) RETURNS text
    LANGUAGE sql STABLE
    AS $$
    SELECT CASE
        WHEN EXISTS (
            SELECT 1 FROM question_shares qs
            WHERE qs.subtopic_id = p_subtopic_id
              AND qs.deleted_at IS NULL
        ) THEN 'shared'
        WHEN EXISTS (
            SELECT 1 FROM question_shares qs
            WHERE qs.question_id = p_question_id
              AND qs.deleted_at IS NULL
        ) THEN 'main'
        ELSE 'normal'
    END;
$$;


ALTER FUNCTION questions.get_shared_status(p_question_id bigint, p_subtopic_id integer) OWNER TO postgres;

--
