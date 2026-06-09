-- Function: questions.fn_subtopics_count_questions(smallint)

--

CREATE FUNCTION questions.fn_subtopics_count_questions(f_topic_id smallint) RETURNS TABLE(id smallint, code character varying, name character varying, topic_id smallint, count_questions bigint)
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                        RETURN QUERY
                        WITH tbl_question_veri AS (
                            SELECT
                                qs.subtopic_id,
                                count(q.id) AS count_questions
                            FROM question q
                            INNER JOIN question_subtopic qs ON q.id = qs.question_id AND qs.fl_status = true
                            WHERE q.status IN ('VERI', 'APRB')
                            GROUP BY qs.subtopic_id
                        ), tbl_subtopic AS (
                            SELECT
                                s.id, s.code, s.name, s.topic_id, COALESCE(qs.count_questions, 0) AS count_questions
                            FROM subtopic s
                            LEFT JOIN tbl_question_veri qs ON s.id = qs.subtopic_id
                            WHERE s.fl_status = true
                        )
                        SELECT ts.* FROM tbl_subtopic ts
                        WHERE (f_topic_id IS NULL OR ts.topic_id = f_topic_id)
                        ORDER BY ts.code ASC;
                    END;
                    $$;


ALTER FUNCTION questions.fn_subtopics_count_questions(f_topic_id smallint) OWNER TO postgres;

--
