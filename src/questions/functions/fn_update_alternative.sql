-- Function: questions.fn_update_alternative(bigint, bigint, character varying, bigint)

--

CREATE FUNCTION questions.fn_update_alternative(p_id bigint, p_question bigint, p_alternative character varying, p_updated_by bigint) RETURNS TABLE(v_id bigint, v_description character varying, v_question_id bigint)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                UPDATE questions.alternative
                SET description = p_alternative, updated_at = now(), updated_by = p_updated_by
                WHERE id = p_id AND question_id = p_question
                RETURNING id, description::character varying, question_id;
            END;
            $$;


ALTER FUNCTION questions.fn_update_alternative(p_id bigint, p_question bigint, p_alternative character varying, p_updated_by bigint) OWNER TO postgres;

--
