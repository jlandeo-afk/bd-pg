-- Function: materials.fn_exam_material_list_cycle(character varying, boolean, integer, integer, integer)

--

CREATE FUNCTION materials.fn_exam_material_list_cycle(p_search character varying, p_active boolean, p_perpage integer, p_npage integer, p_company_id integer) RETURNS TABLE(id bigint, cycle_id bigint, description character varying, created_at timestamp without time zone, total bigint)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            offset_val INT;
        BEGIN
            /*
                ------------------------------------------------------------------------------------
                -- HISTORIAL DE CAMBIOS
                ------------------------------------------------------------------------------------

                Versión: 1.3
                Fecha: 2025-11-14
                Autor: Junior Alcarraz
                Descripción:
                    Se filtra por el id de la compañia del usuario logueado
            */

            -- Calcular el offset para la paginación
            offset_val := p_perpage * (p_npage - 1);

            RETURN QUERY
            WITH cycles AS (
                SELECT DISTINCT
                    c.id,
                    c.id AS cycle_id,
                    c.description,
                    c.created_at
                FROM cycle c
                INNER JOIN type_material tm ON c.id = tm.cycle_id
                WHERE (p_active IS NULL OR c.active = p_active)
                AND c.deleted_at IS NULL
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


ALTER FUNCTION materials.fn_exam_material_list_cycle(p_search character varying, p_active boolean, p_perpage integer, p_npage integer, p_company_id integer) OWNER TO postgres;

--
