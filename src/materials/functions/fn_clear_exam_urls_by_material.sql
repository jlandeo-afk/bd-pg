-- Function: materials.fn_clear_exam_urls_by_material(bigint, bigint, integer, jsonb, bigint)

--

CREATE FUNCTION materials.fn_clear_exam_urls_by_material(p_material_id bigint, p_type_material_id bigint, p_week integer, p_areas jsonb, p_deleted_by bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_week_type_material_id bigint;
BEGIN
    -- Limpia URLs y estados del detalle semana - tipo material
    UPDATE detail_week_type_mat detm
    SET url_solution               = NULL,
        url_without_solution       = NULL,
        fl_process_status          = 1,
        fl_process_status_without  = 1,
        fl_process_class_mat       = 1,
        url_zip_class_mat           = NULL,
        url_quality                = NULL,
        url_without_quality        = NULL,
        fl_process_quality         = 1,
        fl_process_without_quality = 1,
        updated_by                 = p_deleted_by,
        updated_at                 = now()
    WHERE detm.material_id = p_material_id
    AND detm.week = p_week
    AND detm.type_material_id = p_type_material_id
    AND detm.fl_status = true
    RETURNING detm.id
    INTO v_week_type_material_id;

    -- Si existe el registro, limpia URLs de los exámenes por área
    IF v_week_type_material_id IS NOT NULL THEN
        UPDATE material_exam_area_week meaw
        SET url_solution               = NULL,
            url_without_solution       = NULL,
            fl_process_status          = 1,
            fl_process_status_without  = 1,
            url_quality                = NULL,
            url_without_quality        = NULL,
            fl_process_quality         = 1,
            fl_process_without_quality = 1,
            data_missing_course_config = NULL,
            missing_config_message     = NULL,
            updated_by                 = p_deleted_by,
            updated_at                 = now()
        WHERE meaw.week_type_material_id = v_week_type_material_id
        AND meaw.area_id = ANY (
            SELECT jsonb_array_elements_text(p_areas)::bigint
        )
        AND meaw.fl_status = true;
    END IF;

    RETURN v_week_type_material_id;
END;
$$;


ALTER FUNCTION materials.fn_clear_exam_urls_by_material(p_material_id bigint, p_type_material_id bigint, p_week integer, p_areas jsonb, p_deleted_by bigint) OWNER TO postgres;

--
