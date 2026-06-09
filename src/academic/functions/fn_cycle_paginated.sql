-- Function: academic.fn_cycle_paginated(character varying, character varying, character varying, boolean, boolean, integer, integer, integer)

--

CREATE FUNCTION academic.fn_cycle_paginated(p_search character varying, p_code character varying, p_description character varying, f_status boolean, p_active boolean, p_perpage integer, p_npage integer, p_company_id integer) RETURNS TABLE(id bigint, description character varying, cycle_template_id bigint, weeks smallint, created_at timestamp without time zone, total bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    offset_val INT;
BEGIN
    /*
        ------------------------------------------------------------------------------------
        -- HISTORIAL DE CAMBIOS
        ------------------------------------------------------------------------------------

        Versión: 1.2
        Fecha: 2025-11-14
        Autor: Junior Alcarraz
        Descripción:
            Se filtra por el id de la compañia del usuario logueado
    */

    -- Calcular el offset para la paginación
    offset_val := p_perpage * (p_npage - 1);

    RETURN QUERY
    WITH cycles AS (
        SELECT
            c.id,
            c.description,
            c.cycle_template_id,
            c.weeks,
            c.created_at
        FROM cycle c
        WHERE c.fl_status = f_status
            AND (p_active IS NULL OR c.active = p_active)
            AND c.deleted_at IS NULL
            AND (p_code IS NULL OR c.code ILIKE '%' || p_code || '%')
            AND (p_description IS NULL OR c.description ILIKE '%' || p_description || '%')
            AND (p_search IS NULL OR (c.code ILIKE '%' || p_search || '%' OR c.description ILIKE '%' || p_search || '%'))
            AND c.company_id = p_company_id
    ), counted_cycles AS (
        SELECT
            *,
            COUNT(*) OVER () AS total_count
        FROM cycles
    )
    SELECT
        *
    FROM counted_cycles
    ORDER BY created_at DESC
    LIMIT p_perpage
    OFFSET offset_val;
END;
$$;


ALTER FUNCTION academic.fn_cycle_paginated(p_search character varying, p_code character varying, p_description character varying, f_status boolean, p_active boolean, p_perpage integer, p_npage integer, p_company_id integer) OWNER TO postgres;

--
