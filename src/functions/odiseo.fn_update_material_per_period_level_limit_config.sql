-- Function: odiseo.fn_update_material_per_period_level_limit_config(bigint, smallint, smallint, smallint, smallint, bigint)

--

CREATE FUNCTION odiseo.fn_update_material_per_period_level_limit_config(p_material_per_period_id bigint, p_start_week smallint, p_end_week smallint, p_lower_level_limit smallint DEFAULT 1, p_upper_level_limit smallint DEFAULT 1, p_updated_by bigint DEFAULT NULL::bigint) RETURNS TABLE(id bigint, material_per_period_id bigint, material_id bigint, type_material_id smallint, period_start_week smallint, period_end_week smallint, start_week smallint, end_week smallint, lower_level_limit smallint, upper_level_limit smallint, created_by integer, created_by_name character varying, updated_by integer, updated_by_name character varying, deleted_by integer, deleted_by_name character varying, created_at timestamp without time zone, updated_at timestamp without time zone, deleted_at timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_id BIGINT;
BEGIN
    UPDATE material_per_period_level_limit_config
    SET
        lower_level_limit = COALESCE(p_lower_level_limit, 1),
        upper_level_limit = COALESCE(p_upper_level_limit, 1),
        updated_by = p_updated_by,
        updated_at = NOW()
    WHERE material_per_period_level_limit_config.material_per_period_id = p_material_per_period_id
      AND material_per_period_level_limit_config.start_week = p_start_week
      AND material_per_period_level_limit_config.end_week = p_end_week
      AND material_per_period_level_limit_config.deleted_at IS NULL
    RETURNING material_per_period_level_limit_config.id INTO v_id;

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
    WHERE mpllc.id = v_id;
END;
$$;


ALTER FUNCTION odiseo.fn_update_material_per_period_level_limit_config(p_material_per_period_id bigint, p_start_week smallint, p_end_week smallint, p_lower_level_limit smallint, p_upper_level_limit smallint, p_updated_by bigint) OWNER TO postgres;

--
