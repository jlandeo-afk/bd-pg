-- Function: odiseo.fn_report_verified_questions(integer, integer, integer, integer[])

--

CREATE FUNCTION odiseo.fn_report_verified_questions(p_course_id integer, p_topic_id integer, p_subtopic_id integer, p_level_id integer[]) RETURNS TABLE(correlativo bigint, course_name character varying, topic_name character varying, subtopic_name character varying, level character varying, total_question bigint)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY 
            SELECT 
                ROW_NUMBER() OVER (ORDER BY c.name ASC, t.name ASC, s.name ASC, l.name ASC)::bigint AS correlativo, 
                c.name AS course_name, 
                t.name AS topic_name, 
                s.name AS subtopic_name, 
                l.description AS level, 
                COUNT(q.id) AS total_question 
            FROM odiseo.question q 
            LEFT JOIN odiseo.course c ON q.course_id = c.id 
            LEFT JOIN odiseo.topic t ON q.topic_id = t.id 
            LEFT JOIN odiseo.question_subtopic qs ON qs.question_id = q.id 
            LEFT JOIN odiseo.subtopic s ON s.id = qs.subtopic_id 
            LEFT JOIN odiseo.level l ON q.level_id = l.id 
            WHERE q.status = 'VERI' 
            AND (p_course_id IS NULL OR c.id = p_course_id) 
            AND (p_topic_id IS NULL OR t.id = p_topic_id) 
            AND (p_subtopic_id IS NULL OR s.id = p_subtopic_id) 
            AND (p_level_id IS NULL OR l.id = ANY (p_level_id)) 
            GROUP BY c.name, t.name, s.name, l.name, l.description 
            ORDER BY c.name ASC, t.name ASC, s.name ASC, l.name ASC;
        END;
        $$;


ALTER FUNCTION odiseo.fn_report_verified_questions(p_course_id integer, p_topic_id integer, p_subtopic_id integer, p_level_id integer[]) OWNER TO postgres;

--
