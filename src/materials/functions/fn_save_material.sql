-- Function: materials.fn_save_material(bigint, smallint, jsonb, boolean, character varying, smallint, bigint)

--

CREATE FUNCTION materials.fn_save_material(p_material_id bigint, p_week smallint, p_type_materials jsonb, p_solution boolean, p_url_pdf character varying, p_fl_process_status smallint, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_type_material_id SMALLINT;
        BEGIN
            IF p_solution IS TRUE THEN
                FOR v_type_material_id IN SELECT * FROM jsonb_array_elements(p_type_materials) LOOP
                    UPDATE academic.detail_week_type_mat
                    SET url_solution = p_url_pdf, updated_by = p_updated_by, updated_at = now(), fl_process_status = p_fl_process_status
                    WHERE material_id = p_material_id AND week = p_week AND type_material_id = v_type_material_id AND fl_status = true;
                END LOOP;
            ELSE
                FOR v_type_material_id IN SELECT * FROM jsonb_array_elements(p_type_materials) LOOP
                    UPDATE academic.detail_week_type_mat
                    SET url_without_solution = p_url_pdf, updated_by = p_updated_by, updated_at = now(), fl_process_status_without = p_fl_process_status
                    WHERE material_id = p_material_id AND week = p_week AND type_material_id = v_type_material_id AND fl_status = true;
                END LOOP;
            END IF;
        END;
        $$;


ALTER FUNCTION materials.fn_save_material(p_material_id bigint, p_week smallint, p_type_materials jsonb, p_solution boolean, p_url_pdf character varying, p_fl_process_status smallint, p_updated_by bigint) OWNER TO postgres;

--
