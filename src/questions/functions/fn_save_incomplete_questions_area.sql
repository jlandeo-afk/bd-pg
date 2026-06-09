-- Function: questions.fn_save_incomplete_questions_area(bigint, smallint, character varying, bigint)

--

CREATE FUNCTION questions.fn_save_incomplete_questions_area(p_week_type_material_id bigint, p_exam_area_id smallint, p_url_json character varying, p_updated_by bigint) RETURNS TABLE(material_id bigint, week smallint, type_material_id smallint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH update_material_exam_area_week AS (
        UPDATE material_exam_area_week meaw
        SET
            fl_complete_questions = CASE
                WHEN p_url_json IS NULL THEN TRUE
                ELSE FALSE
            END,
            data_incomplete_questions = p_url_json,
            url_solution = null,
            fl_process_status = 1,
            url_without_solution = null,
            fl_process_status_without = 1,
            url_quality = null,
            fl_process_quality = 1,
            url_without_quality = null,
            fl_process_without_quality = 1,
            updated_by = p_updated_by,
            updated_at = NOW()
        WHERE meaw.week_type_material_id = p_week_type_material_id
            AND meaw.area_id = p_exam_area_id
        RETURNING
            meaw.id,
            meaw.area_id,
            meaw.week_type_material_id
    ), clean_url_pdfs AS (
        SELECT
            fsiq.id,
            fsiq.material_id,
            fsiq.week,
            fsiq.type_material_id
        FROM fn_save_incomplete_questions(
            p_week_type_material_id,
            ''::VARCHAR,
            p_updated_by
        ) fsiq
        LIMIT 1
    )
    SELECT
        dwtm.material_id,
        dwtm.week,
        dwtm.type_material_id
    FROM detail_week_type_mat dwtm
    WHERE dwtm.id = p_week_type_material_id
    LIMIT 1;
END;
$$;


ALTER FUNCTION questions.fn_save_incomplete_questions_area(p_week_type_material_id bigint, p_exam_area_id smallint, p_url_json character varying, p_updated_by bigint) OWNER TO postgres;

--
