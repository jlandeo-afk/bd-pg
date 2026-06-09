-- Function: materials.fn_material_class_week(bigint, bigint, jsonb, smallint)

--

CREATE FUNCTION materials.fn_material_class_week(p_material_id bigint, p_type_material_id bigint, p_detail_week_type_mat jsonb, p_week smallint) RETURNS TABLE(id bigint, material_id bigint, type_material_id smallint, type_material character varying, week_type_material_ids character varying, week smallint, course_id smallint, code_course character varying, name_course character varying, fl_process_status smallint, url_material_class character varying, job_id character varying)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_detail_week_type_mat_id BIGINT[];
        BEGIN
            -- v_detail_week_type_mat_id := ARRAY(SELECT jsonb_array_elements_text(p_detail_week_type_mat)::BIGINT);

            SELECT ARRAY(
                SELECT jsonb_array_elements_text(p_detail_week_type_mat)::BIGINT
            ) INTO v_detail_week_type_mat_id;

            RETURN QUERY
            SELECT
                mcw.id,
                mcw.material_id,
                mcw.type_material_id,
                tm.description as type_material,
                mcw.week_type_material_ids,
                mcw.week,
                mcw.course_id,
                c.code AS code_course,
                c.name AS name_course,
                mcw.fl_process_status,
                mcw.url_material_class,
                mcw.job_id
            FROM materials.material_class_week mcw
            INNER JOIN academic.course c ON mcw.course_id = c.id
            INNER JOIN materials.type_material tm ON mcw.type_material_id = tm.id
            WHERE mcw.material_id = p_material_id
            AND mcw.type_material_id = p_type_material_id
            AND mcw.week = p_week
            -- AND mcw.week_type_material_ids = v_detail_week_type_mat_id::VARCHAR
            AND mcw.fl_status = true;
        END;
        $$;


ALTER FUNCTION materials.fn_material_class_week(p_material_id bigint, p_type_material_id bigint, p_detail_week_type_mat jsonb, p_week smallint) OWNER TO postgres;

--
