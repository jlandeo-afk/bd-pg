-- Function: academic.fn_find_by_subtopic(smallint)

--

CREATE FUNCTION academic.fn_find_by_subtopic(p_subtopic_id smallint) RETURNS TABLE(id smallint, code character varying, name character varying, topic_id smallint, topic character varying, course_id smallint, course character varying)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            SELECT
                s.id,
                s.code,
                s.name,
                s.topic_id,
                t.name AS topic,
                t.course_id,
                c.name AS course
            FROM subtopic s
            INNER JOIN topic t ON s.topic_id = t.id
            INNER JOIN course c ON t.course_id = c.id
            WHERE s.id = p_subtopic_id;
        END;
        $$;


ALTER FUNCTION academic.fn_find_by_subtopic(p_subtopic_id smallint) OWNER TO postgres;

--
