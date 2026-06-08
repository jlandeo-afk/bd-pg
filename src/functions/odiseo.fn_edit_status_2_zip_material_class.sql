-- Function: odiseo.fn_edit_status_2_zip_material_class(bigint[])

--

CREATE FUNCTION odiseo.fn_edit_status_2_zip_material_class(p_type_material_ids bigint[]) RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN
            UPDATE odiseo.detail_week_type_mat
            SET fl_process_class_mat = 2, url_zip_class_mat = null
            WHERE id = ANY(p_type_material_ids);
        END;
        $$;


ALTER FUNCTION odiseo.fn_edit_status_2_zip_material_class(p_type_material_ids bigint[]) OWNER TO postgres;

--
