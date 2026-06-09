-- Function: materials.fn_save_type_material_template(bigint, character varying, jsonb, boolean, bigint, bigint, jsonb)

--

CREATE FUNCTION materials.fn_save_type_material_template(p_id bigint, p_name character varying, p_children_template_ids jsonb, p_fl_exam boolean, p_user_id bigint, p_type_exam_id bigint, p_settings jsonb) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_new_type_material_template_id bigint;
    v_type_material_template_child_id bigint;
BEGIN
    IF p_id IS NOT NULL THEN
        RETURN json_build_object('status', 409, 'message', 'No se puede actualizar una plantilla con la función de registro');
    END IF;

    p_settings := NULLIF(p_settings, '{}'::jsonb);

    IF TRIM(UPPER(p_name)) IN (
        SELECT
            TRIM(UPPER(name))
        FROM
            type_material_template
        WHERE
            fl_status = TRUE) THEN
        RETURN json_build_object('status', 409, 'message', 'No se puede crear esta plantilla porque ya existe una plantilla con el mismo nombre');
    END IF;
    -- Insertar nueva plantilla
    INSERT INTO type_material_template(name, fl_exam, created_at, created_by, type_exam_id)
        VALUES (p_name, p_fl_exam, NOW(), p_user_id, p_type_exam_id)
    RETURNING
        id INTO v_new_type_material_template_id;

    -- Si hay hijos, insertarlos
    IF p_children_template_ids IS NOT NULL THEN
        FOR v_type_material_template_child_id IN
        SELECT
            value::bigint
        FROM
            jsonb_array_elements_text(p_children_template_ids)
            LOOP
                -- Validar que los hijos de template no tengan sus propios hijos
                IF EXISTS (
                    SELECT
                        1
                    FROM
                        type_material_bound tmb
                    WHERE
                        tmb.type_material_template_id = v_type_material_template_child_id
                        AND tmb.fl_status = TRUE) THEN
                RETURN json_build_object('status', 409, 'message', 'No se puede asociar hijos que ya tienen sus propios hijos');
            END IF;
        -- Insertar relación
        INSERT INTO type_material_bound(type_material_template_id, type_material_template_extra_id, fl_status, created_by, created_at)
            VALUES (v_new_type_material_template_id, v_type_material_template_child_id, TRUE, p_user_id, NOW());
    END LOOP;
END IF;

    PERFORM fn_sync_type_material_template_configuration_columns(
        v_new_type_material_template_id,
        p_user_id,
        p_settings
    );

    RETURN json_build_object('status', 200, 'message', 'Se creó la plantilla exitosamente');
END;
$$;


ALTER FUNCTION materials.fn_save_type_material_template(p_id bigint, p_name character varying, p_children_template_ids jsonb, p_fl_exam boolean, p_user_id bigint, p_type_exam_id bigint, p_settings jsonb) OWNER TO postgres;

--
