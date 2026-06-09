-- Function: common.fn_update_plan(bigint, character varying, character varying, numeric, character varying, integer, integer, bigint)

--

CREATE FUNCTION common.fn_update_plan(p_id bigint, p_name character varying, p_description character varying, p_cost numeric, p_benefits character varying, p_number_users integer, p_number_questions integer, p_updated_by bigint) RETURNS TABLE(v_validated boolean, v_id bigint)
    LANGUAGE plpgsql
    AS $$
			DECLARE
				v_exits_id BIGINT;
            BEGIN
				SELECT id INTO v_exits_id
				FROM odiseo."plans"
				WHERE LOWER(name) = LOWER(p_name)
                AND id <> p_id
				LIMIT 1;

				IF v_exits_id IS NULL THEN
                    UPDATE odiseo."plans"
                    SET
                        name = COALESCE(p_name, name),
                        description = COALESCE(p_description, description),
                        cost = COALESCE(p_cost, cost),
                        benefits = COALESCE(p_benefits, benefits),
                        number_users = COALESCE(p_number_users, number_users),
                        number_questions = COALESCE(p_number_questions, number_questions),
                        updated_by = p_updated_by, updated_at = now()
                    WHERE id = p_id
					RETURNING id INTO v_id;

					RETURN QUERY SELECT TRUE, v_id;
				ELSE
					RETURN QUERY SELECT FALSE, 0::BIGINT;
				END IF;
            END;
            $$;


ALTER FUNCTION common.fn_update_plan(p_id bigint, p_name character varying, p_description character varying, p_cost numeric, p_benefits character varying, p_number_users integer, p_number_questions integer, p_updated_by bigint) OWNER TO postgres;

--
