-- Function: questions.fn_create_question_refuzed(bigint, smallint, smallint, character varying, text, bigint)

--

CREATE FUNCTION questions.fn_create_question_refuzed(p_question_id bigint, p_category_id smallint, p_importance_id smallint, p_observation character varying, p_images text, p_created_by bigint) RETURNS TABLE(v_id bigint)
    LANGUAGE plpgsql
    AS $$
			DECLARE
				v_new_id BIGINT;
            BEGIN
                INSERT INTO questions.question_refuzed (category_rejected_id, importance_rejected, observation, images, question_id, created_by, created_at)
                VALUES (p_category_id, p_importance_id, p_observation, p_images, p_question_id, p_created_by, now())
                RETURNING id INTO v_new_id;

                UPDATE questions.question SET status = 'RECH', updated_by = p_created_by, updated_at = now() WHERE id = p_question_id;

                RETURN QUERY SELECT v_new_id;
            END;
            $$;


ALTER FUNCTION questions.fn_create_question_refuzed(p_question_id bigint, p_category_id smallint, p_importance_id smallint, p_observation character varying, p_images text, p_created_by bigint) OWNER TO postgres;

--
