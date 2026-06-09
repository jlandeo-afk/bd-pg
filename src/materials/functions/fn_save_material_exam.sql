-- Function: materials.fn_save_material_exam(bigint, smallint, smallint, boolean, character varying, character varying, smallint, smallint, smallint, bigint)

--

CREATE FUNCTION materials.fn_save_material_exam(p_material_id bigint, p_week smallint, p_type_material_id smallint, p_solution boolean, p_filename character varying, p_url_pdf character varying, p_exam_area_id smallint, p_fl_process_status smallint, p_number_pages smallint, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_type_material_id SMALLINT;
    v_detail_week_type_mat_id BIGINT;
BEGIN
    SELECT dwtm.id INTO v_detail_week_type_mat_id FROM detail_week_type_mat dwtm
    WHERE dwtm.material_id = p_material_id AND dwtm.week = p_week AND dwtm.type_material_id = p_type_material_id AND dwtm.fl_status = true;

    IF p_solution IS TRUE THEN
        UPDATE material_exam_area_week
        SET url_solution = p_url_pdf,
            filename = p_filename,
            updated_by = p_updated_by,
            updated_at = now(),
            fl_process_status = p_fl_process_status
        WHERE week_type_material_id = v_detail_week_type_mat_id AND area_id = p_exam_area_id AND fl_status = true;
    ELSE
        UPDATE material_exam_area_week
        SET url_without_solution = p_url_pdf,
            filename = p_filename,
            updated_by = p_updated_by,
            updated_at = now(),
            fl_process_status_without = p_fl_process_status,
            number_pages = p_number_pages
        WHERE week_type_material_id = v_detail_week_type_mat_id AND area_id = p_exam_area_id AND fl_status = true;
    END IF;
END;
$$;


ALTER FUNCTION materials.fn_save_material_exam(p_material_id bigint, p_week smallint, p_type_material_id smallint, p_solution boolean, p_filename character varying, p_url_pdf character varying, p_exam_area_id smallint, p_fl_process_status smallint, p_number_pages smallint, p_updated_by bigint) OWNER TO postgres;

--
