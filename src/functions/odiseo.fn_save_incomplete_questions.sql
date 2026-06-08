-- Function: odiseo.fn_save_incomplete_questions(bigint, character varying, bigint)

--

CREATE FUNCTION odiseo.fn_save_incomplete_questions(p_detail_week_type_mat_id bigint, p_url_json character varying, p_updated_by bigint) RETURNS TABLE(id bigint, material_id bigint, week smallint, type_material_id smallint, parent_type_material_id smallint)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            WITH updated_incomplete_questions AS (
                UPDATE detail_week_type_mat dwtm
                SET
                    fl_complete_questions = CASE
                        WHEN p_url_json IS NULL THEN TRUE
                        ELSE FALSE
                    END,
                    data_incomplete_questions = p_url_json,
                    updated_by = p_updated_by,
                    updated_at = NOW()
                WHERE 1 = 1
                  AND dwtm.id = p_detail_week_type_mat_id
                  AND dwtm.fl_status IS TRUE
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
                    AND dwtm2.material_id IN (SELECT uiq.material_id FROM updated_incomplete_questions uiq)
                    AND dwtm2.week = (SELECT uiq.week FROM updated_incomplete_questions uiq)
                    AND COALESCE(dwtm2.parent_type_material_id, dwtm2.type_material_id) = COALESCE(
                        (SELECT uiq.parent_type_material_id FROM updated_incomplete_questions uiq),
                        (SELECT uiq.type_material_id FROM updated_incomplete_questions uiq)
                    )
            ), updated_clean_pdf_url AS (
                UPDATE detail_week_type_mat dwtmupd
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
                  AND dwtmupd.id IN (SELECT vtm.detail_week_type_mat_id FROM validate_type_material vtm)
                RETURNING
                    dwtmupd.id,
                    dwtmupd.material_id,
                    dwtmupd.week,
                    dwtmupd.type_material_id,
                    dwtmupd.parent_type_material_id
            )
            SELECT * FROM updated_clean_pdf_url;
        END;
        $$;


ALTER FUNCTION odiseo.fn_save_incomplete_questions(p_detail_week_type_mat_id bigint, p_url_json character varying, p_updated_by bigint) OWNER TO postgres;

--
