-- Function: common.fn_validate_save_code_prospect(character varying)

--

CREATE FUNCTION common.fn_validate_save_code_prospect(p_code character varying) RETURNS TABLE(v_validated boolean)
    LANGUAGE plpgsql
    AS $$
			DECLARE
				v_code_id BIGINT;
				v_new_id BIGINT;
            BEGIN
                SELECT cp.id INTO v_code_id
                FROM common.code_prospect cp
				WHERE code = p_code
				LIMIT 1;

				IF v_code_id IS NULL THEN
					INSERT INTO common.code_prospect (code, created_by, created_at)
					VALUES(p_code, 1, now())
					RETURNING id INTO v_new_id;

					RETURN QUERY SELECT TRUE;
				ELSE
					RETURN QUERY SELECT FALSE;
				END IF;
            END;
            $$;


ALTER FUNCTION common.fn_validate_save_code_prospect(p_code character varying) OWNER TO postgres;

--
