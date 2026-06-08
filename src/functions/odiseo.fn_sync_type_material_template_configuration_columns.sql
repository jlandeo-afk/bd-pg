-- Function: odiseo.fn_sync_type_material_template_configuration_columns(bigint, bigint, jsonb)

--

CREATE FUNCTION odiseo.fn_sync_type_material_template_configuration_columns(p_type_material_template_id bigint, p_user_id bigint, p_settings jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_now  timestamp := NOW();
    v_role text;
BEGIN

    SELECT CASE
        WHEN EXISTS (SELECT 1 FROM type_material_bound tmb
                     WHERE tmb.type_material_template_id       = p_type_material_template_id AND tmb.fl_status = true) THEN 'PARENT'
        WHEN EXISTS (SELECT 1 FROM type_material_bound tmb
                     WHERE tmb.type_material_template_extra_id = p_type_material_template_id AND tmb.fl_status = true) THEN 'CHILD'
        ELSE 'UNIQUE'
    END INTO v_role;

    IF v_role = 'CHILD' THEN
        UPDATE type_material_template_configuration_columns
           SET deleted_at = v_now, deleted_by = p_user_id
         WHERE type_material_template_id = p_type_material_template_id
           AND deleted_at IS NULL;

        UPDATE type_material_template
           SET has_config_column = false, updated_at = v_now, updated_by = p_user_id
         WHERE id = p_type_material_template_id;
        RETURN;
    END IF;

    IF v_role = 'PARENT' THEN
        UPDATE type_material_template_configuration_columns t
           SET deleted_at = v_now, deleted_by = p_user_id
         WHERE t.deleted_at IS NULL
           AND EXISTS (SELECT 1 FROM type_material_bound b
                       WHERE b.type_material_template_extra_id = t.type_material_template_id
                         AND b.type_material_template_id       = p_type_material_template_id
                         AND b.fl_status = true);

        UPDATE type_material_template t
           SET has_config_column = false, updated_at = v_now, updated_by = p_user_id
         WHERE EXISTS (SELECT 1 FROM type_material_bound b
                       WHERE b.type_material_template_extra_id = t.id
                         AND b.type_material_template_id       = p_type_material_template_id
                         AND b.fl_status = true);
    END IF;

    WITH settings AS (
        SELECT
            NULLIF(col->>'type_solution', '')                    AS type_solution,
            COALESCE(NULLIF(col->>'number_columns', '')::int, 1) AS number_columns
        FROM jsonb_array_elements(
            CASE
                WHEN p_settings IS NULL                      THEN '[]'::jsonb
                WHEN jsonb_typeof(p_settings) = 'array'      THEN p_settings
                ELSE '[]'::jsonb
            END
        ) col
        WHERE COALESCE((col->>'has_config_columns')::boolean, FALSE) = TRUE
    ),

    deleted AS (
        UPDATE type_material_template_configuration_columns t
           SET deleted_at = v_now, deleted_by = p_user_id
         WHERE t.type_material_template_id = p_type_material_template_id
           AND t.deleted_at IS NULL
           AND NOT EXISTS (SELECT 1 FROM settings s
                           WHERE s.type_solution IS NOT DISTINCT FROM t.type_solution
                             AND s.number_columns = t.number_columns)
        RETURNING 1
    ),

    restored AS (
        UPDATE type_material_template_configuration_columns t
           SET deleted_at = NULL,
               deleted_by = NULL,
               updated_at = v_now,
               updated_by = p_user_id
         WHERE t.type_material_template_id = p_type_material_template_id
           AND t.deleted_at IS NOT NULL
           AND EXISTS (SELECT 1 FROM settings s
                       WHERE s.type_solution IS NOT DISTINCT FROM t.type_solution
                         AND s.number_columns = t.number_columns)
        RETURNING 1
    ),

    inserted AS (
        INSERT INTO type_material_template_configuration_columns
            (type_material_template_id, type_solution, number_columns, created_at, created_by)
        SELECT p_type_material_template_id, s.type_solution, s.number_columns, v_now, p_user_id
        FROM settings s
        WHERE NOT EXISTS (
            SELECT 1 FROM type_material_template_configuration_columns t
             WHERE t.type_material_template_id = p_type_material_template_id
               AND t.type_solution IS NOT DISTINCT FROM s.type_solution
               AND t.number_columns = s.number_columns
        )
    )

    UPDATE type_material_template
       SET has_config_column = EXISTS (SELECT 1 FROM settings),
           updated_at = v_now, updated_by = p_user_id
     WHERE id = p_type_material_template_id;

END;
$$;


ALTER FUNCTION odiseo.fn_sync_type_material_template_configuration_columns(p_type_material_template_id bigint, p_user_id bigint, p_settings jsonb) OWNER TO postgres;

--
