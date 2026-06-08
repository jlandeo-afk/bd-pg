-- Function: odiseo.fn_material_exam_area_week(bigint)

--

CREATE FUNCTION odiseo.fn_material_exam_area_week(p_detail_id bigint) RETURNS TABLE(id bigint, type_material character varying, area_id smallint, exam_area character varying, url_solution character varying, url_without_solution character varying, fl_process_status smallint, fl_process_status_without smallint, url_quality character varying, url_without_quality character varying, fl_process_quality smallint, fl_process_without_quality smallint, fl_complete_questions boolean, data_incomplete_questions character varying, missing_config_message character varying, data_missing_course_config character varying, filename character varying, fl_frequent boolean, type_exam_id bigint)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            SELECT
                meaw.id,
                tm.description AS type_material,
                meaw.area_id,
                ea.description AS exam_area,
                meaw.url_solution,
                meaw.url_without_solution,
                meaw.fl_process_status,
                meaw.fl_process_status_without,
                meaw.url_quality,
                meaw.url_without_quality,
                meaw.fl_process_quality,
                meaw.fl_process_without_quality,
                meaw.fl_complete_questions,
                meaw.data_incomplete_questions,
                meaw.missing_config_message,
                meaw.data_missing_course_config,
                meaw.filename,
                CASE
                    WHEN tmt.type_exam_id = '4' THEN TRUE
                    ELSE FALSE
                END AS fl_frequent,
                tmt.type_exam_id
            FROM material_exam_area_week meaw
            INNER JOIN exam_area ea ON meaw.area_id = ea.id
            INNER JOIN detail_week_type_mat dwtm ON meaw.week_type_material_id = dwtm.id AND dwtm.fl_status IS TRUE
            INNER JOIN type_material tm ON dwtm.type_material_id = tm.id
            INNER JOIN type_material_template tmt ON tm.type_material_template_id = tmt.id
            WHERE meaw.week_type_material_id = p_detail_id
            AND meaw.fl_status = true
            ORDER BY meaw.area_id ASC;
        END;
        $$;


ALTER FUNCTION odiseo.fn_material_exam_area_week(p_detail_id bigint) OWNER TO postgres;

--
