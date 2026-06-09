-- Function: common.fn_save_prospect(character varying, character varying, character varying, character varying, character varying, character varying, bigint)

--

CREATE FUNCTION common.fn_save_prospect(p_code character varying, p_name character varying, p_charge character varying, p_type_company character varying, p_name_institute character varying, p_document_number character varying, p_created_by bigint) RETURNS TABLE(v_validated boolean, v_new_prospect_id bigint)
    LANGUAGE plpgsql
    AS $$
			DECLARE
				v_code_id BIGINT;
				v_new_id BIGINT;
            BEGIN
                SELECT cp.id INTO v_code_id
                FROM common.code_prospect cp
				WHERE code = p_code
				AND fl_status = true
				LIMIT 1;

				IF v_code_id IS NOT NULL THEN
					INSERT INTO common.prospect (name, charge, type_company, name_institute, document_number, code_id, created_by, created_at)
					VALUES(p_name, p_charge, p_type_company, p_name_institute, p_document_number, v_code_id, p_created_by, now())
					RETURNING id INTO v_new_id;

					UPDATE common.code_prospect
					SET fl_status = false, deleted_by = created_by, deleted_at = now()
					WHERE code = p_code AND fl_status = true;

					RETURN QUERY SELECT TRUE, v_new_id;
				ELSE
					RETURN QUERY SELECT FALSE, 0::BIGINT;
				END IF;
            END;
            $$;


ALTER FUNCTION common.fn_save_prospect(p_code character varying, p_name character varying, p_charge character varying, p_type_company character varying, p_name_institute character varying, p_document_number character varying, p_created_by bigint) OWNER TO postgres;

--
