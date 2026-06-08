-- Function: odiseo.fn_edit_zip_material_class(jsonb, smallint, character varying, bigint)

--

CREATE FUNCTION odiseo.fn_edit_zip_material_class(p_detail_week_type_mat_ids jsonb, p_fl_process_class_mat smallint, p_url_zip_class_mat character varying, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_fl_process_validate SMALLINT;
        BEGIN
            IF p_fl_process_class_mat = 3 THEN
                UPDATE detail_week_type_mat
                SET
                    fl_process_class_mat = p_fl_process_class_mat,
                    url_zip_class_mat = p_url_zip_class_mat,
                    updated_by = p_updated_by,
                    updated_at = NOW()
                WHERE 1 = 1
                  AND fl_status IS TRUE
                  AND id IN ( SELECT value::BIGINT FROM jsonb_array_elements_text(p_detail_week_type_mat_ids));
            ELSE
                SELECT dwtm.fl_process_class_mat
                  INTO v_fl_process_validate
                FROM detail_week_type_mat dwtm
                WHERE 1 = 1
                  AND dwtm.fl_status IS TRUE
                  AND dwtm.id IN ( SELECT value::BIGINT FROM jsonb_array_elements_text(p_detail_week_type_mat_ids) )
                LIMIT 1;

                IF p_fl_process_class_mat = 2 AND v_fl_process_validate <> p_fl_process_class_mat THEN
                    UPDATE detail_week_type_mat
                    SET
                        fl_process_class_mat = p_fl_process_class_mat,
                        updated_by = p_updated_by,
                        updated_at = NOW()
                    WHERE 1 = 1
                      AND fl_status IS TRUE
                      AND id IN ( SELECT value::BIGINT FROM jsonb_array_elements_text(p_detail_week_type_mat_ids) );
                END IF;
            END IF;
        END;
        $$;


ALTER FUNCTION odiseo.fn_edit_zip_material_class(p_detail_week_type_mat_ids jsonb, p_fl_process_class_mat smallint, p_url_zip_class_mat character varying, p_updated_by bigint) OWNER TO postgres;

--
