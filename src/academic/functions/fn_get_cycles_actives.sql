-- Function: academic.fn_get_cycles_actives(bigint)

--

CREATE FUNCTION academic.fn_get_cycles_actives(p_company_id bigint) RETURNS TABLE(id bigint, description character varying, weeks integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id, 
        c.description, 
        COUNT(cw.id) FILTER (WHERE tw.description != 'Inactiva' AND cw.id IS NOT NULL)::int as weeks
    FROM cycle c
    LEFT JOIN cycle_weeks cw ON cw.cycle_id = c.id AND cw.fl_status = true AND cw.deleted_at IS NULL
    LEFT JOIN type_week tw ON tw.id = cw.type_week_id
    WHERE c.company_id = p_company_id
      AND c.fl_status = true
      AND c.active = true
    GROUP BY c.id, c.description, c.created_at
    ORDER BY c.created_at DESC;
END;
$$;


ALTER FUNCTION academic.fn_get_cycles_actives(p_company_id bigint) OWNER TO postgres;

--
