-- Function: odiseo.fn_list_material_per_period_level_limit_config(bigint)

--

CREATE FUNCTION odiseo.fn_list_material_per_period_level_limit_config(p_material_per_period_id bigint DEFAULT NULL::bigint) RETURNS TABLE(id bigint, material_per_period_id bigint, material_id bigint, type_material_id smallint, period_start_week smallint, period_end_week smallint, start_week smallint, end_week smallint, lower_level_limit smallint, upper_level_limit smallint, created_by integer, created_by_name character varying, updated_by integer, updated_by_name character varying, deleted_by integer, deleted_by_name character varying, created_at timestamp without time zone, updated_at timestamp without time zone, deleted_at timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        mpllc.id,
        mpllc.material_per_period_id,
        mpp.material_id,
        mpp.type_material_id,
        mpp.start_week AS period_start_week,
        mpp.end_week AS period_end_week,
        mpllc.start_week,
        mpllc.end_week,
        mpllc.lower_level_limit,
        mpllc.upper_level_limit,
        mpllc.created_by,
        uc."user" AS created_by_name,
        mpllc.updated_by,
        uu."user" AS updated_by_name,
        mpllc.deleted_by,
        ud."user" AS deleted_by_name,
        mpllc.created_at,
        mpllc.updated_at,
        mpllc.deleted_at
    FROM material_per_period_level_limit_config mpllc
    JOIN material_per_period mpp ON mpp.id = mpllc.material_per_period_id
    LEFT JOIN users uc ON uc.id = mpllc.created_by
    LEFT JOIN users uu ON uu.id = mpllc.updated_by
    LEFT JOIN users ud ON ud.id = mpllc.deleted_by
    WHERE mpllc.deleted_at IS NULL
      AND (
          p_material_per_period_id IS NULL
          OR mpllc.material_per_period_id = p_material_per_period_id
      )
    ORDER BY mpllc.start_week ASC, mpllc.end_week ASC, mpllc.id ASC;
END;
$$;


ALTER FUNCTION odiseo.fn_list_material_per_period_level_limit_config(p_material_per_period_id bigint) OWNER TO postgres;

--
