-- Function: odiseo.fn_generate_code_teacher(bigint)

--

CREATE FUNCTION odiseo.fn_generate_code_teacher(p_company_id bigint) RETURNS TABLE(code text)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    COALESCE(
                        LPAD((MAX(NULLIF(e.code, '')::int) + 1)::text, 3, '0'),
                        '001'
                    ) AS code
                FROM employees e
                WHERE e.charge_id = 2
                AND e.company_id = p_company_id;
            END;
            $$;


ALTER FUNCTION odiseo.fn_generate_code_teacher(p_company_id bigint) OWNER TO postgres;

--
