-- Function: materials.fn_get_material_per_period_exam(bigint, smallint, smallint, smallint)

--

CREATE FUNCTION materials.fn_get_material_per_period_exam(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint) RETURNS TABLE(id bigint, material_id bigint, type_material_id smallint, exam_area_id bigint, fl_created boolean, start_week smallint, end_week smallint, questions_missing_url character varying, courses_missing_url character varying, text_missing_url character varying, url jsonb)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            WITH tbl_type_url (id, name) AS (
                VALUES
                    (1, 'solution'::VARCHAR),
                    (2, 'without_solution'::VARCHAR)
            ), tbl_type_material AS (
                SELECT
                    tm.id,
                    tm.fl_class_material,
                    tma.area_id AS exam_area_id,
                    ea.description
                FROM type_material tm
                LEFT JOIN type_material_area tma ON tm.id = tma.type_material_id
                LEFT JOIN exam_area ea ON tma.area_id = ea.id
                WHERE tm.id = p_type_material_id
            ), tbl_material_per_period AS (
                SELECT DISTINCT
                    mpp.id,
                    m.id,
                    COALESCE(mpp.type_material_id, ttm.id) AS type_material_id,
					COALESCE(mppe.exam_area_id, ttm.exam_area_id) AS exam_area_id,
                    CASE
                        WHEN mppe.start_week IS NOT NULL THEN TRUE
                        ELSE FALSE
                    END AS fl_created,
                    COALESCE(mppe.start_week, p_start_week) AS start_week,
                    COALESCE(mppe.end_week, p_end_week) AS end_week,
                    mppe.questions_missing_url,
                    mppe.courses_missing_url,
                    mppe.text_missing_url,
                    COALESCE((
                        SELECT jsonb_agg(jsonb_build_object(
                            'id', mppeu.id,
                            'material_per_period_exam_id', COALESCE(mppeu.material_per_period_exam_id, mppe.id),
                            'type_url', COALESCE(mppeu.type_url, ttu.name),
                            'fl_job_process',COALESCE(mppeu.fl_job_process, 'unprocessed'::VARCHAR),
                            'job_url', mppeu.job_url,
                            'job_id', mppeu.job_id
                        ) ORDER BY ttu.id ASC) AS urls
                        FROM tbl_type_url ttu
                        LEFT JOIN material_per_period_exam_url mppeu ON ttu.name = mppeu.type_url
                            AND mppeu.deleted_by IS NULL
                            AND mppeu.material_per_period_exam_id = mppe.id
                    ), '[]'::JSONB) AS url
                FROM material m
				LEFT JOIN tbl_type_material ttm ON 1 = 1
                LEFT JOIN material_per_period mpp ON m.id = mpp.material_id
                    AND mpp.deleted_by IS NULL
                    AND mpp.type_material_id = p_type_material_id
                LEFT JOIN material_per_period_exam mppe ON mpp.id = mppe.material_per_period_id
                    AND mppe.deleted_by IS NULL
                    AND mppe.start_week = p_start_week
                    AND mppe.end_week = p_end_week
                WHERE m.id = p_material_id
            )
            SELECT * FROM tbl_material_per_period tmpp;
        END;
        $$;


ALTER FUNCTION materials.fn_get_material_per_period_exam(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint) OWNER TO postgres;

--
