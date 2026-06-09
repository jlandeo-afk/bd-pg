-- Function: questions.fn_generate_code_parent_question(bigint)

--

CREATE FUNCTION questions.fn_generate_code_parent_question(p_course_id bigint) RETURNS TABLE(number_question character varying, code_course character varying)
    LANGUAGE plpgsql
    AS $$
			DECLARE
				v_number VARCHAR;
				v_code VARCHAR;
            BEGIN
				SELECT code INTO v_code
				FROM academic.course
				WHERE id = p_course_id
				AND fl_status = true
				LIMIT 1;

				SELECT number INTO v_number
				FROM questions.parent_question
				WHERE course_id = p_course_id
				AND fl_status = true
				ORDER BY number DESC
				LIMIT 1;

				IF v_number IS NOT NULL THEN
					RETURN QUERY SELECT v_number, v_code;
				ELSE
					RETURN QUERY SELECT 0::VARCHAR, v_code;
				END IF;
            END;
            $$;


ALTER FUNCTION questions.fn_generate_code_parent_question(p_course_id bigint) OWNER TO postgres;

--
