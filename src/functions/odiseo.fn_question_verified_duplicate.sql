-- Function: odiseo.fn_question_verified_duplicate(smallint, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_question_verified_duplicate(p_course_id smallint, p_parent_id bigint, p_question_id bigint) RETURNS TABLE(id bigint, code character varying, description text, short_description text, course_id smallint, parent_id bigint)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        SELECT
            q.id,
            q.code,
            q.description,
            q.short_description,
            q.course_id,
            q.parent_id
        FROM question q
        WHERE q.fl_status = true
        AND q.course_id = p_course_id
        AND q.short_description IS NOT NULL
        AND q.status NOT IN ('DUPL', 'ARCH')
        AND (
            (p_parent_id IS NULL AND q.parent_id IS NULL)
            OR (p_parent_id IS NOT NULL AND q.parent_id = p_parent_id)
        )
        AND q.id <> p_question_id
        ORDER BY q.id ASC;
    END;
    $$;


ALTER FUNCTION odiseo.fn_question_verified_duplicate(p_course_id smallint, p_parent_id bigint, p_question_id bigint) OWNER TO postgres;

--
