-- Function: odiseo.fn_cycle_all(character varying, character varying, character varying, boolean, integer)

--

CREATE FUNCTION odiseo.fn_cycle_all(p_search character varying, p_code character varying, p_description character varying, f_status boolean, p_company_id integer) RETURNS TABLE(id bigint, description character varying, cycle_template_id bigint, weeks smallint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    /*
        ------------------------------------------------------------------------------------
        -- HISTORIAL DE CAMBIOS
        ------------------------------------------------------------------------------------

        Versión: 1.1
        Fecha: 2025-11-14
        Autor: Junior Alcarraz
        Descripción:
            Se filtra por el id de la compañia del usuario logueado
    */

    RETURN QUERY
    SELECT
        c.id,
        c.description,
        c.cycle_template_id,
        c.weeks
    FROM cycle c
    WHERE c.fl_status = f_status
        AND (p_code IS NULL OR c.code ILIKE '%' || p_code || '%')
        AND (p_description IS NULL OR c.description ILIKE '%' || p_description || '%')
        AND (p_search IS NULL OR (c.code ILIKE '%' || p_search || '%' OR c.description ILIKE '%' || p_search || '%'))
        AND c.cycle_template_id IS NOT NULL
        AND c.company_id = p_company_id
        ORDER BY c.id ASC;
END;
$$;


ALTER FUNCTION odiseo.fn_cycle_all(p_search character varying, p_code character varying, p_description character varying, f_status boolean, p_company_id integer) OWNER TO postgres;

--
