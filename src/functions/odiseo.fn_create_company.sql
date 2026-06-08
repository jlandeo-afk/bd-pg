-- Function: odiseo.fn_create_company(uuid, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, bigint, bigint, bigint, uuid, character varying, character varying)

--

CREATE FUNCTION odiseo.fn_create_company(p_uuid uuid, p_social_reason character varying, p_commercial_name character varying, p_type_company character varying, p_document_number character varying, p_domain_email character varying, p_schema character varying, p_address character varying, p_city character varying, p_state character varying, p_main_number character varying, p_other_number character varying, p_prospect_id bigint, p_plan_id bigint, p_created_by bigint, p_uuid_user uuid, p_user character varying, p_password character varying) RETURNS TABLE(v_validated boolean, v_type integer, v_id bigint)
    LANGUAGE plpgsql
    AS $$
			DECLARE
				v_exists_social_reason BIGINT;
				v_exists_document_number BIGINT;
				v_exists_prospect BIGINT;
				v_exists_plan BIGINT;
				v_prospect_id BIGINT;
				v_schema BIGINT;
				v_exists_user BIGINT;
				v_new_id BIGINT;
            BEGIN
                -- Validar si existe la misma razon social
                SELECT id INTO v_exists_social_reason
                FROM odiseo.companies
                WHERE social_reason = p_social_reason
                AND fl_status = true
                LIMIT 1;

                IF v_exists_social_reason IS NULL THEN
                    -- Validar si existe el mismo nro de documento
                    SELECT id INTO v_exists_document_number
                    FROM odiseo.companies
                    WHERE document_number = p_document_number
                    AND fl_status = true
                    LIMIT 1;

                    IF v_exists_document_number IS NULL THEN
                        -- Validar si existe el prospecto
                        IF p_prospect_id IS NOT NULL THEN
                            SELECT id INTO v_exists_prospect
                            FROM odiseo.prospect
                            WHERE id = p_prospect_id
                            AND fl_status = true
                            AND fl_validate = false
                            LIMIT 1;

                            IF v_exists_prospect IS NULL THEN
                                RETURN QUERY SELECT FALSE, 3, 0::BIGINT;
                                RETURN;
                            END IF;
                        END IF;

                        -- Validar schema
                        SELECT COUNT(*) INTO v_schema
                        FROM pg_namespace
                        WHERE nspname = p_schema;

                        IF v_schema > 0 THEN
                            RETURN QUERY SELECT FALSE, 4, 0::BIGINT;
                            RETURN;
                        END IF;

                        -- Validar si existe el usuario
                        SELECT u.id INTO v_exists_user
                        FROM odiseo.users u
                        WHERE LOWER(u.user) = LOWER(p_user)
                        AND u.fl_status = true
                        LIMIT 1;

                        IF v_exists_user IS NOT NULL THEN
                            RETURN QUERY SELECT FALSE, 5, 0::BIGINT;
                            RETURN;
                        END IF;

                        INSERT INTO odiseo.companies
                        (uuid, social_reason, commercial_name, type_company, document_number, domain_email, "schema", address, city, state, main_number, other_number, prospect_id, plan_id , created_by, created_at)
                        VALUES (p_uuid, p_social_reason, p_commercial_name, p_type_company, p_document_number, p_domain_email, p_schema, p_address, p_city, p_state, p_main_number, p_other_number, p_prospect_id, p_plan_id, p_created_by, now())
                        RETURNING id INTO v_new_id;

                        -- Cambiar estado de prospecto
                        UPDATE odiseo.prospect
                        SET fl_validate = true
                        WHERE id = p_prospect_id
                        AND fl_status = true;

                        -- Crear usuario admin
                        INSERT INTO odiseo.users (uuid, "user", password, status_session, company_id, created_by, created_at)
                        VALUES (p_uuid_user, p_user, p_password, 1001, v_new_id, p_created_by, now());

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


ALTER FUNCTION odiseo.fn_create_company(p_uuid uuid, p_social_reason character varying, p_commercial_name character varying, p_type_company character varying, p_document_number character varying, p_domain_email character varying, p_schema character varying, p_address character varying, p_city character varying, p_state character varying, p_main_number character varying, p_other_number character varying, p_prospect_id bigint, p_plan_id bigint, p_created_by bigint, p_uuid_user uuid, p_user character varying, p_password character varying) OWNER TO postgres;

--
