-- Function: materials.fn_get_detail_week_type_material(bigint, smallint, smallint)

--

CREATE FUNCTION materials.fn_get_detail_week_type_material(p_material_id bigint, p_week smallint, p_type_material_id smallint) RETURNS TABLE(detail_id bigint, cycle_id bigint, fl_examen boolean, name_type_material character varying, name_type_material_template character varying, process_status smallint, process_status_without smallint, fl_complete_questions boolean, data_incomplete_questions character varying, missing_config_message character varying, data_missing_course_config character varying, data_missing_text json, university_id smallint)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        WITH tbl_type_material AS (
            SELECT
                tm.fl_exam,
                tm.description,
                tmt.name
            FROM type_material tm
            LEFT JOIN type_material_template tmt ON tmt.id = tm.type_material_template_id
            WHERE tm.id = p_type_material_id
        )
        SELECT
            dwtm.id AS detail_id,
            m.cycle_id,
            ttm.fl_exam,
            ttm.description AS name_type_material,
            ttm.name AS name_type_material_template,
            dwtm.fl_process_status,
            dwtm.fl_process_status_without,
            dwtm.fl_complete_questions,
            dwtm.data_incomplete_questions,
            dwtm.missing_config_message,
            dwtm.data_missing_course_config,
            dwtm.data_missing_text,
            m.university_id
        FROM detail_week_type_mat dwtm
        INNER JOIN material m ON dwtm.material_id = m.id
        JOIN tbl_type_material ttm ON 1 = 1
        WHERE dwtm.material_id = p_material_id
            AND dwtm.week = p_week
            AND dwtm.type_material_id = p_type_material_id
            AND dwtm.fl_status = true;
    END;
    $$;


ALTER FUNCTION materials.fn_get_detail_week_type_material(p_material_id bigint, p_week smallint, p_type_material_id smallint) OWNER TO postgres;

--
