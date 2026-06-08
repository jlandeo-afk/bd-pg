-- Function: odiseo.fn_update_type_material_template(bigint, character varying, jsonb, boolean, bigint, bigint, jsonb)

--

CREATE FUNCTION odiseo.fn_update_type_material_template(p_id bigint, p_name character varying, p_children_template_ids jsonb, p_fl_exam boolean, p_user_id bigint, p_type_exam_id bigint, p_settings jsonb) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_old_is_exam bool;
    v_type_material_template_child_id bigint;
BEGIN
    p_settings := NULLIF(p_settings, '{}'::jsonb);
    
    SELECT
        tmt.fl_exam,
        tmt.name INTO v_old_is_exam
    FROM
        type_material_template tmt
    WHERE
        tmt.id = p_id
        AND tmt.fl_status = TRUE
    LIMIT 1;

    IF TRIM(UPPER(p_name)) IN (
        SELECT
            TRIM(UPPER(name))
        FROM
            type_material_template
        WHERE
            fl_status = TRUE AND id <> p_id) THEN
        RETURN json_build_object('status', 409, 'message', 'No se puede modificar esta plantilla porque ya existe una plantilla con el mismo nombre');
    END IF;

    IF v_old_is_exam <> p_fl_exam AND EXISTS (
        SELECT
            1
        FROM
            type_material tm
        WHERE
            tm.type_material_template_id = p_id AND tm.fl_status = TRUE) THEN
        RETURN json_build_object('status', 409, 'message', 'No se puede modificar esta plantilla porque ya tiene materiales asignados');
    END IF;

    UPDATE
        type_material_template
    SET
        name = COALESCE(p_name, name),
        fl_exam = COALESCE(p_fl_exam, fl_exam),
        updated_at = NOW(),
        updated_by = p_user_id,
        type_exam_id = p_type_exam_id,
        deleted_at = NULL,
        deleted_by = NULL,
        fl_status = TRUE
    WHERE
        id = p_id;
    WITH deleted_bounds AS (
        UPDATE
            type_material_bound tmb
        SET
            fl_status = FALSE,
            deleted_by = p_user_id,
            deleted_at = NOW()
        WHERE
            tmb.type_material_template_id = p_id
            AND tmb.type_material_template_extra_id NOT IN (
                SELECT
                    value::bigint
                FROM
                    jsonb_array_elements_text(p_children_template_ids))
                AND tmb.fl_status = TRUE
            RETURNING
                tmb.type_material_template_extra_id)
        UPDATE
            type_material tm
        SET
            fl_status = FALSE,
            updated_by = p_user_id,
            updated_at = NOW(),
            deleted_by = p_user_id,
            deleted_at = NOW()
        WHERE
            tm.parent_id IN (
                SELECT
                    id
                FROM
                    type_material
                WHERE
                    type_material_template_id = p_id)
            AND tm.type_material_template_id IN (
                SELECT
                    type_material_template_extra_id
                FROM
                    deleted_bounds);
    FOR v_type_material_template_child_id IN
    SELECT
        value::bigint
    FROM
        jsonb_array_elements_text(p_children_template_ids)
        LOOP
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
    INSERT INTO type_material_bound(type_material_template_id, type_material_template_extra_id, fl_status, created_by, created_at)
        VALUES (p_id, v_type_material_template_child_id, TRUE, p_user_id, NOW())
    ON CONFLICT (type_material_template_id, type_material_template_extra_id)
        DO UPDATE SET
            fl_status = TRUE,
            updated_by = p_user_id,
            updated_at = NOW(),
            deleted_by = NULL,
            deleted_at = NULL;
    UPDATE
        type_material tm_hijo
    SET
        fl_status = TRUE,
        updated_by = p_user_id,
        updated_at = NOW(),
        deleted_by = NULL,
        deleted_at = NULL
    FROM
        type_material tm_padre
    WHERE
        tm_padre.type_material_template_id = p_id
        AND tm_hijo.parent_id = tm_padre.id
        AND tm_hijo.type_material_template_id = v_type_material_template_child_id;
END LOOP;

    UPDATE
        type_material tm_padre
    SET
        amount_question = COALESCE((
            SELECT
                SUM(hijo.amount_question)
            FROM type_material hijo
            WHERE
                hijo.parent_id = tm_padre.id
                AND hijo.fl_status = TRUE), 0)
    WHERE
        tm_padre.type_material_template_id = p_id;

    PERFORM fn_sync_type_material_template_configuration_columns(
        p_id,
        p_user_id,
        p_settings
    );

    RETURN json_build_object('status', 200, 'message', 'Se actualizó la plantilla exitosamente');
END;
$$;


ALTER FUNCTION odiseo.fn_update_type_material_template(p_id bigint, p_name character varying, p_children_template_ids jsonb, p_fl_exam boolean, p_user_id bigint, p_type_exam_id bigint, p_settings jsonb) OWNER TO postgres;

--
