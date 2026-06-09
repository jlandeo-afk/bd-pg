-- Function: questions.fn_report_verified_questions_total(integer, integer, integer, integer[])

--

CREATE FUNCTION questions.fn_report_verified_questions_total(p_course_id integer, p_topic_id integer, p_subtopic_id integer, p_level_id integer[]) RETURNS TABLE(records_verified_questions_total bigint)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            SELECT COUNT(*) AS records_verified_questions_total 
            FROM questions.question q 
            LEFT JOIN academic.course c ON q.course_id = c.id 
            LEFT JOIN academic.topic t ON q.topic_id = t.id 
            LEFT JOIN questions.question_subtopic qs ON qs.question_id = q.id 
            LEFT JOIN academic.subtopic s ON s.id = qs.subtopic_id 
            LEFT JOIN academic.level l ON q.level_id = l.id 
            WHERE q.status = 'VERI' 
            AND (p_course_id IS NULL OR c.id = p_course_id) 
            AND (p_topic_id IS NULL OR t.id = p_topic_id) 
            AND (p_subtopic_id IS NULL OR s.id = p_subtopic_id) 
            AND (p_level_id IS NULL OR l.id = ANY (p_level_id));
        END;
        $$;


ALTER FUNCTION questions.fn_report_verified_questions_total(p_course_id integer, p_topic_id integer, p_subtopic_id integer, p_level_id integer[]) OWNER TO postgres;

--
