-- Function: odiseo.fn_report_missing_questions(integer, integer, integer, integer[])

--

CREATE FUNCTION odiseo.fn_report_missing_questions(p_course_id integer, p_topic_id integer, p_subtopic_id integer, p_level_id integer[]) RETURNS TABLE(correlativo bigint, course_name character varying, topic_name character varying, subtopic_name character varying, level character varying)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY 
            SELECT 
			    ROW_NUMBER() OVER (ORDER BY c.name ASC, t.name ASC, s.name ASC, l.name ASC)::bigint AS correlativo, 
			    c.name AS course_name, 
			    t.name AS topic_name, 
			    s.name AS subtopic_name, 
			    l.description AS level
			FROM odiseo.course c
			JOIN odiseo.topic t ON t.course_id = c.id
			JOIN odiseo.subtopic s ON s.topic_id = t.id
			JOIN odiseo.level l ON 1 = 1  AND l.deleted_at IS NULL
			WHERE NOT EXISTS (
			    SELECT 1
			    FROM odiseo.question q
			    JOIN odiseo.question_subtopic qs ON qs.question_id = q.id
			    WHERE q.course_id = c.id
			      AND q.topic_id = t.id
			      AND qs.subtopic_id = s.id
			      AND q.level_id = l.id
			)
            AND (p_course_id IS NULL OR c.id = p_course_id) 
            AND (p_topic_id IS NULL OR t.id = p_topic_id) 
            AND (p_subtopic_id IS NULL OR s.id = p_subtopic_id) 
            AND (p_level_id IS NULL OR l.id = ANY (p_level_id)) 
			ORDER BY c.name ASC, t.name ASC, s.name ASC, l.name ASC;
        END;
        $$;


ALTER FUNCTION odiseo.fn_report_missing_questions(p_course_id integer, p_topic_id integer, p_subtopic_id integer, p_level_id integer[]) OWNER TO postgres;

--
