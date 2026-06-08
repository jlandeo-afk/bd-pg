-- Function: odiseo.fn_save_plan(character varying, character varying, numeric, character varying, integer, integer, bigint)

--

CREATE FUNCTION odiseo.fn_save_plan(p_name character varying, p_description character varying, p_cost numeric, p_benefits character varying, p_number_users integer, p_number_questions integer, p_created_by bigint) RETURNS TABLE(v_validated boolean, v_id bigint)
    LANGUAGE plpgsql
    AS $$
			DECLARE
				v_exits_id BIGINT;
            BEGIN
				SELECT id INTO v_exits_id
				FROM odiseo."plans"
				WHERE LOWER(name) = LOWER(p_name)
				LIMIT 1;

				IF v_exits_id IS NULL THEN
					INSERT INTO odiseo."plans" (name, description, cost, benefits, number_users, number_questions, created_by, created_at)
					VALUES(p_name, p_description, p_cost, p_benefits, p_number_users, p_number_questions, p_created_by, now())
					RETURNING id INTO v_id;

					RETURN QUERY SELECT TRUE, v_id;
				ELSE
					RETURN QUERY SELECT FALSE, 0::BIGINT;
				END IF;
            END;
            $$;


ALTER FUNCTION odiseo.fn_save_plan(p_name character varying, p_description character varying, p_cost numeric, p_benefits character varying, p_number_users integer, p_number_questions integer, p_created_by bigint) OWNER TO postgres;

--
