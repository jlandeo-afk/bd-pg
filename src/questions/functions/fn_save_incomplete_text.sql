-- Function: questions.fn_save_incomplete_text(bigint, json, bigint)

--

CREATE FUNCTION questions.fn_save_incomplete_text(p_detail_week_type_mat_id bigint, p_missing_text json, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN
            WITH updated_incomplete_text AS (
            UPDATE
                detail_week_type_mat dwtm
            SET
                data_missing_text = p_missing_text,
                updated_by = p_updated_by,
                updated_at = NOW()
            WHERE 1 = 1
            AND fl_status IS TRUE 
            AND id = p_detail_week_type_mat_id
            RETURNING
                dwtm.id AS detail_week_type_mat_id,
                dwtm.type_material_id,
                dwtm.parent_type_material_id,
                dwtm.material_id,
                dwtm.week
            ), validate_type_material AS (
                SELECT
                    DISTINCT dwtm2.id AS detail_week_type_mat_id
                FROM detail_week_type_mat dwtm2
                WHERE dwtm2.fl_status = TRUE
                    AND dwtm2.material_id IN (SELECT uiq.material_id FROM updated_incomplete_text uiq)
                    AND dwtm2.week = (SELECT uiq.week FROM updated_incomplete_text uiq)
                    AND COALESCE(dwtm2.parent_type_material_id, dwtm2.type_material_id) = COALESCE(
                        (SELECT uiq.parent_type_material_id FROM updated_incomplete_text uiq),
                        (SELECT uiq.type_material_id FROM updated_incomplete_text uiq)
                    )
            )  UPDATE detail_week_type_mat dwtmupd
                SET
                    url_solution = null,
                    fl_process_status = 1,
                    url_without_solution = null,
                    fl_process_status_without = 1,
                    url_zip_class_mat = null,
                    fl_process_class_mat = 1,
                    url_quality = null,
                    fl_process_quality = 1,
                    url_without_quality = null,
                    fl_process_without_quality = 1,
                    updated_by = p_updated_by,
                    updated_at = now()
                WHERE 1 = 1
                AND dwtmupd.fl_status IS TRUE
                AND dwtmupd.id IN (SELECT vtm.detail_week_type_mat_id FROM validate_type_material vtm);
        END;
    $$;


ALTER FUNCTION questions.fn_save_incomplete_text(p_detail_week_type_mat_id bigint, p_missing_text json, p_updated_by bigint) OWNER TO postgres;

--
