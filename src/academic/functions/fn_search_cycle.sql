-- Function: academic.fn_search_cycle(integer, integer, character varying, boolean, integer)

--

CREATE FUNCTION academic.fn_search_cycle(p_perpage integer, p_npage integer, p_name_text character varying, p_active boolean, p_company_id integer) RETURNS TABLE(id bigint, code character varying, description character varying, month smallint, year smallint, weeks smallint, start_date date, end_date date, active boolean, cycle_template_id bigint, cycle_type_id bigint, cycle_type character varying, created_by text, created_at timestamp without time zone, total_count bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    offset_val INTEGER;
BEGIN
    /*
        ------------------------------------------------------------------------------------
        -- HISTORIAL DE CAMBIOS
        ------------------------------------------------------------------------------------

        Versión: 1.0
        Fecha: 2025-11-14
        Autor: Junior Alcarraz
        Descripción:
            Se filtra por el id de la compañia del usuario logueado
    */

    -- Calcular el offset para la paginación
    offset_val := p_perpage * (p_npage - 1);

    RETURN QUERY
    WITH tbl_cycle as (
        SELECT
            c.id,
            c.code,
            c.description,
            c.month,
            c.year,
            c.weeks,
            c.start_date,
            c.end_date,
            c.active,
            c.cycle_template_id,
            c.cycle_type_id,
            ct.name AS cycle_type,
            CASE
                WHEN e.first_name IS NOT NULL AND e.first_surname IS NOT NULL THEN
                    CONCAT(initcap(split_part(e.first_name, ' ', 1)), ' ',
                        upper(left(e.first_surname, 1)), '. ',
                        initcap(e.second_surname))
                ELSE
                    NULL
            END AS created_by,
            c.created_at
        FROM "cycle" c
        LEFT JOIN cycle_types ct ON c.cycle_type_id = ct.id
        LEFT JOIN users u ON c.created_by = u.id
        LEFT JOIN employees e ON u.id = e.user_id
        WHERE c.fl_status = true and c.deleted_at is null
            AND (
                p_name_text IS NULL
                OR c.description ILIKE '%' || p_name_text || '%'
                OR c.code ILIKE '%' || p_name_text || '%'
            )
            AND (p_active IS NULL OR c.active = p_active)
            AND c.company_id = p_company_id
    ), counted_cycles AS (
        SELECT *, COUNT(*) OVER () AS total_count
        FROM tbl_cycle
    )
    SELECT *
    FROM counted_cycles
    ORDER BY created_at DESC
    LIMIT p_perpage
    OFFSET offset_val;
END;
$$;


ALTER FUNCTION academic.fn_search_cycle(p_perpage integer, p_npage integer, p_name_text character varying, p_active boolean, p_company_id integer) OWNER TO postgres;

--
