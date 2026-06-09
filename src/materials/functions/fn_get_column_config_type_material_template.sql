-- Function: materials.fn_get_column_config_type_material_template(bigint)

--

CREATE FUNCTION materials.fn_get_column_config_type_material_template(p_type_material_id bigint) RETURNS TABLE(number_columns integer, type_solution character varying, has_config_column boolean)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_role TEXT;
    v_target_id BIGINT;
BEGIN

    -- Determinar rol
    SELECT 
        CASE
            WHEN EXISTS (
                select 1 from type_material tm
                where tm.id = p_type_material_id
                  and tm.parent_id IS NULL
                  and tm.fl_status = TRUE
            ) THEN 'PARENT'

            WHEN EXISTS (
                select 1 from type_material tm
                where tm.id = p_type_material_id
                  and tm.parent_id IS NOT NULL
                  and tm.fl_status = TRUE
            ) THEN 'CHILD'

            ELSE 'UNIQUE'
        END
    INTO v_role;

    -- Si es CHILD obtener el padre
    IF v_role = 'CHILD' THEN
        select tm_parent.type_material_template_id
        into v_target_id
        from type_material tm
        join type_material tm_parent on tm_parent.id = tm.parent_id and tm_parent.fl_status = TRUE
        where tm.id = p_type_material_id
        and tm.fl_status = TRUE;

    ELSE
        select tm.type_material_template_id
        into v_target_id
        from type_material tm
        where tm.id = p_type_material_id
        and tm.fl_status = TRUE;
    END IF;

    -- Retornar configuración
    RETURN QUERY
    SELECT
        tmc.number_columns,
        tmc.type_solution,
        tmt.has_config_column
    FROM type_material_template_configuration_columns tmc
    JOIN type_material_template tmt ON tmt.id = tmc.type_material_template_id AND tmt.fl_status IS TRUE
    WHERE tmc.type_material_template_id = v_target_id
      AND tmc.deleted_at IS NULL;

END;
$$;


ALTER FUNCTION materials.fn_get_column_config_type_material_template(p_type_material_id bigint) OWNER TO postgres;

--
