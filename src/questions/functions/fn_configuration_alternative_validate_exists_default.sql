-- Function: questions.fn_configuration_alternative_validate_exists_default(integer, bigint)

--

CREATE FUNCTION questions.fn_configuration_alternative_validate_exists_default(p_id integer, p_company_id bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
                DECLARE
                    v_count integer;
                BEGIN
                    SELECT COUNT(*)
                    INTO v_count
                    FROM questions.configuration_alternative
                    WHERE fl_default = true AND company_id = p_company_id AND id <> p_id AND fl_status = true;

                    RETURN v_count > 0;
                END;
            $$;


ALTER FUNCTION questions.fn_configuration_alternative_validate_exists_default(p_id integer, p_company_id bigint) OWNER TO postgres;

--
