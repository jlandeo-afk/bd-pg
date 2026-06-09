-- Function: materials.fn_create_material_per_period_level_limit_config(bigint, smallint, smallint, smallint, smallint, smallint, boolean, bigint)

--

CREATE FUNCTION materials.fn_create_material_per_period_level_limit_config(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint, p_lower_level_limit smallint DEFAULT 1, p_upper_level_limit smallint DEFAULT 1, p_fl_use_question_type boolean DEFAULT true, p_created_by bigint DEFAULT NULL::bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_material_per_period_id BIGINT;
    v_material_per_period_level_limit_config_id BIGINT;
BEGIN
    WITH get_material_per_period AS (
        SELECT
            mpp.id
        FROM material_per_period AS mpp
        WHERE mpp.material_id = p_material_id
            AND mpp.type_material_id = p_type_material_id
            AND mpp.deleted_by IS NULL
    ), insert_material_per_period AS (
        INSERT INTO material_per_period AS mpp (
            material_id,
            type_material_id,
            created_by,
            created_at
        )
        SELECT
            p_material_id,
            p_type_material_id,
            p_created_by,
            NOW()
        WHERE NOT EXISTS (
            SELECT 1
            FROM get_material_per_period
        )
        RETURNING mpp.id
    )
    SELECT COALESCE(
        (SELECT id FROM insert_material_per_period),
        (SELECT id FROM get_material_per_period)
    )
    INTO v_material_per_period_id;

    UPDATE material_per_period_level_limit_config AS mppllc
    SET
        lower_level_limit = COALESCE(p_lower_level_limit, 1),
        upper_level_limit = COALESCE(p_upper_level_limit, 1),
        fl_use_question_type = COALESCE(p_fl_use_question_type, TRUE),
        updated_by = p_created_by,
        updated_at = NOW()
    WHERE mppllc.material_per_period_id = v_material_per_period_id
        AND mppllc.start_week = p_start_week
        AND mppllc.end_week = p_end_week
    RETURNING mppllc.id
    INTO v_material_per_period_level_limit_config_id;

    IF v_material_per_period_level_limit_config_id IS NULL THEN
        INSERT INTO material_per_period_level_limit_config (
            material_per_period_id,
            start_week,
            end_week,
            lower_level_limit,
            upper_level_limit,
            fl_use_question_type,
            created_by,
            created_at
        )
        VALUES (
            v_material_per_period_id,
            p_start_week,
            p_end_week,
            COALESCE(p_lower_level_limit, 1),
            COALESCE(p_upper_level_limit, 1),
            COALESCE(p_fl_use_question_type, TRUE),
            p_created_by,
            NOW()
        );
    END IF;
END;
$$;


ALTER FUNCTION materials.fn_create_material_per_period_level_limit_config(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint, p_lower_level_limit smallint, p_upper_level_limit smallint, p_fl_use_question_type boolean, p_created_by bigint) OWNER TO postgres;

--
