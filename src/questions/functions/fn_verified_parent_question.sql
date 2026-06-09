-- Function: questions.fn_verified_parent_question()

--

CREATE FUNCTION questions.fn_verified_parent_question() RETURNS TABLE(id bigint, code character varying, description text, short_description text, course_id smallint)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    pq.id,
                    pq.code,
                    pq.description,
                    pq.short_description,
                    pq.course_id
                FROM questions.parent_question pq
                WHERE pq.fl_status = true
                AND pq.short_description IS NOT NULL
				ORDER BY pq.id ASC;
            END;
            $$;


ALTER FUNCTION questions.fn_verified_parent_question() OWNER TO postgres;

--
