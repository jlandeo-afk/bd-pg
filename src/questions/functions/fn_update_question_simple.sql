-- Function: questions.fn_update_question_simple(integer, text, text, integer, integer)

--

CREATE FUNCTION questions.fn_update_question_simple(p_id integer, p_description text, p_short_description text, p_updated_by integer, p_course_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
                    DECLARE
                        v_question_id INTEGER;
                        v_count INTEGER;
                    BEGIN
                        UPDATE questions.question
                        SET
                            description = p_description,
                            short_description = p_short_description,
                            updated_by = p_updated_by,
                            updated_at = now(),
                            course_id = CASE
                                WHEN p_course_id IS NOT NULL THEN p_course_id
                                ELSE course_id
                            END
                        WHERE
                            id = p_id
                        RETURNING id INTO v_question_id;

                        RETURN v_question_id;
                    END;
                $$;


ALTER FUNCTION questions.fn_update_question_simple(p_id integer, p_description text, p_short_description text, p_updated_by integer, p_course_id integer) OWNER TO postgres;

--
