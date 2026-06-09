-- Function: materials.fn_save_material_exam_quality(bigint, smallint, smallint, boolean, character varying, smallint, smallint, bigint)

--

CREATE FUNCTION materials.fn_save_material_exam_quality(p_material_id bigint, p_week smallint, p_type_material_id smallint, p_solution boolean, p_url_quality character varying, p_exam_area_id smallint, p_fl_process smallint, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_type_material_id SMALLINT;
            v_detail_week_type_mat_id BIGINT;
        BEGIN
            SELECT dwtm.id INTO v_detail_week_type_mat_id FROM academic.detail_week_type_mat dwtm
            WHERE dwtm.material_id = p_material_id AND dwtm.week = p_week AND dwtm.type_material_id = p_type_material_id AND dwtm.fl_status = true;

            IF p_solution IS TRUE THEN
                UPDATE materials.material_exam_area_week
                SET url_quality = p_url_quality, updated_by = p_updated_by, updated_at = now(), fl_process_quality = p_fl_process
                WHERE week_type_material_id = v_detail_week_type_mat_id AND area_id = p_exam_area_id AND fl_status = true;
            ELSE
                UPDATE materials.material_exam_area_week
                SET url_without_quality = p_url_quality, updated_by = p_updated_by, updated_at = now(), fl_process_without_quality = p_fl_process
                WHERE week_type_material_id = v_detail_week_type_mat_id AND area_id = p_exam_area_id AND fl_status = true;
            END IF;
        END;
        $$;


ALTER FUNCTION materials.fn_save_material_exam_quality(p_material_id bigint, p_week smallint, p_type_material_id smallint, p_solution boolean, p_url_quality character varying, p_exam_area_id smallint, p_fl_process smallint, p_updated_by bigint) OWNER TO postgres;

--
