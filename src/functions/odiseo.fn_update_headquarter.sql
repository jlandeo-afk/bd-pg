-- Function: odiseo.fn_update_headquarter(smallint, character varying, character varying, character varying, bigint)

--

CREATE FUNCTION odiseo.fn_update_headquarter(p_id smallint, p_name character varying, p_slug character varying, p_address character varying, p_updated_by bigint) RETURNS TABLE(id smallint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE headquarters h
    SET name = p_name,
        slug = p_slug,
        address = p_address,
        updated_by = p_updated_by,
        updated_at = NOW()
    WHERE h.id = p_id;

    RETURN QUERY
    SELECT p_id;
END;
$$;


ALTER FUNCTION odiseo.fn_update_headquarter(p_id smallint, p_name character varying, p_slug character varying, p_address character varying, p_updated_by bigint) OWNER TO postgres;

--
