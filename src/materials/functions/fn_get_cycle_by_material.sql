-- Function: materials.fn_get_cycle_by_material(bigint, bigint)

--

CREATE FUNCTION materials.fn_get_cycle_by_material(p_material_id bigint, p_company_id bigint) RETURNS TABLE(id bigint, start_date date)
    LANGUAGE plpgsql STABLE
    AS $$
                BEGIN
                    RETURN QUERY
                    SELECT
                        c.id,
                        c.start_date
                    FROM material m
                    INNER JOIN cycle c ON c.id = m.cycle_id
                        AND c.company_id = p_company_id
                        AND c.fl_status = true
                    WHERE m.id = p_material_id
                        AND m.company_id = p_company_id
                    LIMIT 1;
                END;
                $$;


ALTER FUNCTION materials.fn_get_cycle_by_material(p_material_id bigint, p_company_id bigint) OWNER TO postgres;

--
