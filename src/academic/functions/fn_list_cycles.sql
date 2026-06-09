-- Function: academic.fn_list_cycles(character varying, character varying, character varying, boolean, integer)

--

CREATE FUNCTION academic.fn_list_cycles(p_search character varying, p_code character varying, p_description character varying, p_status boolean, p_company_id integer) RETURNS TABLE(id bigint, description character varying, weeks smallint)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id,
        c.description,
        c.weeks
    FROM cycle c
    WHERE c.fl_status = p_status
        AND (p_code IS NULL OR c.code ILIKE '%' || p_code || '%')
        AND (p_description IS NULL OR c.description ILIKE '%' || p_description || '%')
        AND (p_search IS NULL OR (c.code ILIKE '%' || p_search || '%' OR c.description ILIKE '%' || p_search || '%'))
        AND c.company_id = p_company_id
    ORDER BY c.id ASC;
END;
$$;


ALTER FUNCTION academic.fn_list_cycles(p_search character varying, p_code character varying, p_description character varying, p_status boolean, p_company_id integer) OWNER TO postgres;

--
