-- Function: materials.fn_detail_template_by_material(bigint, bigint, smallint)

--

CREATE FUNCTION materials.fn_detail_template_by_material(p_material_id bigint, p_cycle_id bigint, p_week smallint) RETURNS TABLE(id bigint, uuid uuid, type_material_id smallint, fl_process_status integer, fl_process_without integer, fl_process_quality integer, fl_process_without_quality integer, fl_process_class_mat integer, fl_exam boolean, fl_frequent boolean, fl_complete_questions boolean, data_incomplete_questions character varying, fl_config_level boolean, fl_config_type boolean, limit_lower_question smallint, limit_upper_question smallint, material character varying, fl_class_material boolean, questions_generation_process character varying, type_exam_id bigint)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            SELECT
                dwtm.id,
                dwtm.uuid,
                typematedetatemp.type_material_id,
                COALESCE(dwtm.fl_process_status, 0) as fl_process_status,
                COALESCE(dwtm.fl_process_status_without, 0) as fl_process_status_without,
                COALESCE(dwtm.fl_process_quality, 0) as fl_process_quality,
                COALESCE(dwtm.fl_process_without_quality, 0) as fl_process_without_quality,
                COALESCE(dwtm.fl_process_class_mat, 0) as fl_process_class_mat,
                tm.fl_exam,
                CASE
                    WHEN typematetemp.type_exam_id = '4' THEN TRUE
                    ELSE FALSE
                END AS fl_frequent,
                dwtm.fl_complete_questions,
                dwtm.data_incomplete_questions,
                CASE
                    WHEN dwtm.fl_config_level IS NOT NULL THEN dwtm.fl_config_level -- Si no es NULL, conserva su valor
                    WHEN subquery.array_data IS NULL THEN TRUE -- Si el array está vacío, retorna TRUE
                    WHEN subquery.all_true THEN true -- Si todos son true, retorna true
                    ELSE false -- Si hay al menos un false, retorna false
                END AS fl_config_level,
                dwtm.fl_config_type,
                dwtm.limit_lower_question,
                dwtm.limit_upper_question,
                tm.description as material,
                tm.fl_class_material,
                dwtm.questions_generation_process AS questions_generation_process,
                typematetemp.type_exam_id
            FROM type_material_detail_template typematedetatemp
            LEFT JOIN detail_week_type_mat dwtm ON (
                dwtm.type_material_id = typematedetatemp.type_material_id AND
                dwtm.week = typematedetatemp.week AND
                dwtm.fl_status IS TRUE AND
                dwtm.material_id = p_material_id
            )
            LEFT JOIN type_material tm ON tm.id = typematedetatemp.type_material_id AND tm.fl_status = true
            LEFT JOIN type_material_template typematetemp ON tm.type_material_template_id = typematetemp.id
            LEFT JOIN LATERAL (
                SELECT
                    array_agg(json_build_object(
                        'id', d.id,
                        'type_material_id', d.type_material_id,
                        'fl_config_level', d.fl_config_level
                    )) AS array_data,
                    bool_and(d.fl_config_level) AS all_true
                FROM detail_week_type_mat d 
                WHERE 1 = 1
                    ANd d.parent_type_material_id = typematedetatemp.type_material_id
                    AND d.week = p_week
                    AND d.fl_status IS TRUE
            ) subquery ON true
            WHERE 1 = 1
                AND tm.cycle_id = p_cycle_id
                AND typematedetatemp.week = p_week
                AND NOT EXISTS (
                    SELECT 1
                    FROM type_material_bound tmb
                    WHERE tmb.type_material_template_extra_id = tm.type_material_template_id  AND tmb.fl_status = true
                )
                AND typematedetatemp.fl_status = true;
        END;
        $$;


ALTER FUNCTION materials.fn_detail_template_by_material(p_material_id bigint, p_cycle_id bigint, p_week smallint) OWNER TO postgres;

--
