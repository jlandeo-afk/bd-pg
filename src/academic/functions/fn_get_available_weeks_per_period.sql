-- Function: academic.fn_get_available_weeks_per_period(bigint)

--

CREATE FUNCTION academic.fn_get_available_weeks_per_period(p_material_per_period_id bigint) RETURNS TABLE(week smallint, detail_ids jsonb)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        dwtm.week,
        JSONB_AGG(DISTINCT dwtm.id) AS detail_ids
    FROM odiseo.material_per_period_ballot mppb
    JOIN odiseo.material_per_period mpp ON mpp.id = mppb.material_per_period_id
    JOIN odiseo.type_material_detail_template tmdt
      ON 1 = 1 
     AND tmdt.type_material_id = mpp.type_material_id
     AND tmdt.fl_status IS TRUE
     AND tmdt.week BETWEEN mppb.start_week AND mppb.end_week
    JOIN academic.detail_week_type_mat dwtm
      ON 1 = 1
     AND (
        ( dwtm.parent_type_material_id IS NOT NULL AND dwtm.parent_type_material_id = mpp.type_material_id ) OR
        ( dwtm.type_material_id = mpp.type_material_id ) )
     AND dwtm.material_id = mpp.material_id
     AND dwtm.fl_status IS TRUE
     AND dwtm.week = tmdt.week
    WHERE mppb.id = p_material_per_period_id
    GROUP BY dwtm.week
    ORDER BY dwtm.week;
END;
$$;


ALTER FUNCTION academic.fn_get_available_weeks_per_period(p_material_per_period_id bigint) OWNER TO postgres;

--
