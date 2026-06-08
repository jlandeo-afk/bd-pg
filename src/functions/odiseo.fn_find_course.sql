-- Function: odiseo.fn_find_course(bigint)

--

CREATE FUNCTION odiseo.fn_find_course(p_id bigint) RETURNS TABLE(id smallint, code character varying, name character varying, area_code character varying, area character varying, agreement_url character varying, agreement_file_name character varying)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        SELECT
            c.id,
            c.code,
            c.name,
            a.code AS area_code,
            a.description AS area,
            c.agreement_url as agreement_url,
            c.agreement_file_name as agreement_file_name
        FROM course c
        LEFT JOIN area a ON c.area_id = a.id
        WHERE c.id = p_id
        AND c.fl_status = true
        ORDER BY c.id ASC;
    END;
    $$;


ALTER FUNCTION odiseo.fn_find_course(p_id bigint) OWNER TO postgres;

--
