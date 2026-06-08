-- Function: odiseo.fn_configuration_alternative_validate_name(character varying, integer, bigint)

--

CREATE FUNCTION odiseo.fn_configuration_alternative_validate_name(p_name character varying, p_id integer, p_company_id bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
                DECLARE
                    v_count integer;
                BEGIN
                    SELECT COUNT(*)
                    INTO v_count
                    FROM odiseo.configuration_alternative
                    WHERE LOWER(name) = LOWER(p_name) AND company_id = p_company_id AND id <> p_id AND fl_status = true;

                    RETURN v_count = 0;
                END;
            $$;


ALTER FUNCTION odiseo.fn_configuration_alternative_validate_name(p_name character varying, p_id integer, p_company_id bigint) OWNER TO postgres;

--
