-- Function: organization.fn_update_company(bigint, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, bigint)

--

CREATE FUNCTION organization.fn_update_company(p_id bigint, p_social_reason character varying, p_commercial_name character varying, p_type_company character varying, p_document_number character varying, p_domain_email character varying, p_address character varying, p_city character varying, p_state character varying, p_main_number character varying, p_other_number character varying, p_updated_by bigint) RETURNS TABLE(v_validated boolean, v_type integer, v_id bigint)
    LANGUAGE plpgsql
    AS $$
			DECLARE
				v_exists_social_reason BIGINT;
				v_exists_document_number BIGINT;
				v_new_id BIGINT;
            BEGIN
                -- Validar si existe la misma razon social
                SELECT id INTO v_exists_social_reason
                FROM organization.companies
                WHERE social_reason = p_social_reason
                AND id <> p_id
                AND fl_status = true
                LIMIT 1;

                IF v_exists_social_reason IS NULL THEN
                    -- Validar si existe el mismo nro de documento
                    SELECT id INTO v_exists_document_number
                    FROM organization.companies
                    WHERE document_number = p_document_number
                    AND id <> p_id
                    AND fl_status = true
                    LIMIT 1;

                    IF v_exists_document_number IS NULL THEN
                        UPDATE organization.companies
                        SET
                            social_reason = COALESCE(p_social_reason, social_reason),
                            commercial_name = COALESCE(p_commercial_name, commercial_name),
                            type_company = COALESCE(p_type_company, type_company),
                            document_number = COALESCE(p_document_number, document_number),
                            domain_email = COALESCE(p_domain_email, domain_email),
                            address = COALESCE(p_address, address),
                            city = COALESCE(p_city, city),
                            state = COALESCE(p_state, state),
                            main_number = COALESCE(p_main_number, main_number),
                            other_number = COALESCE(p_other_number, other_number),
                            updated_by = p_updated_by, updated_at = now()
                        WHERE id = p_id
                        RETURNING id INTO v_new_id;

                        RETURN QUERY SELECT TRUE, 0, v_new_id;
                        RETURN;
                    ELSE
                        RETURN QUERY SELECT FALSE, 2, 0::BIGINT;
                        RETURN;
                    END IF;
                ELSE
					RETURN QUERY SELECT FALSE, 1, 0::BIGINT;
                    RETURN;
                END IF;
            END;
            $$;


ALTER FUNCTION organization.fn_update_company(p_id bigint, p_social_reason character varying, p_commercial_name character varying, p_type_company character varying, p_document_number character varying, p_domain_email character varying, p_address character varying, p_city character varying, p_state character varying, p_main_number character varying, p_other_number character varying, p_updated_by bigint) OWNER TO postgres;

--
