-- Function: odiseo.subtopic_has_related_questions(smallint)

--

CREATE FUNCTION odiseo.subtopic_has_related_questions(p_subtopic_id smallint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN EXISTS (
                SELECT 1
                FROM odiseo.question q
                INNER JOIN odiseo.question_subtopic qs
                ON q.id = qs.question_id AND qs.fl_status = true
                WHERE
                    qs.subtopic_id = p_subtopic_id
                    AND q.deleted_at IS NULL
                    AND q.fl_status
                    AND qs.deleted_at IS NULL
                    AND qs.fl_status
            );
        END;
        $$;


ALTER FUNCTION odiseo.subtopic_has_related_questions(p_subtopic_id smallint) OWNER TO postgres;

--
