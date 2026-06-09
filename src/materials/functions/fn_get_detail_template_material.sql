-- Function: materials.fn_get_detail_template_material(bigint)

--

CREATE FUNCTION materials.fn_get_detail_template_material(p_material_id bigint) RETURNS TABLE(id bigint, uuid uuid, week smallint, type_week_id bigint, type_week character varying, cycle_id bigint, type_material_id smallint, fl_process_status integer, fl_process_without integer, fl_process_quality integer, fl_process_without_quality integer, fl_process_class_mat integer, fl_exam boolean, fl_frequent boolean, fl_complete_questions boolean, data_incomplete_questions character varying, fl_config_level boolean, fl_config_type boolean, limit_lower_question smallint, limit_upper_question smallint, material character varying, fl_class_material boolean, questions_generation_process character varying, type_exam_id bigint)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            WITH tbl_material AS (
                SELECT
                    m.id,
                    m.cycle_id
                FROM material m
                WHERE m.id = p_material_id
            ),tbl_cycle_weeks AS (
                SELECT
                    fdtm.id,
                    fdtm.uuid,
                    cw.week,
                    cw.type_week_id,
                    tw.description AS type_week,
                    cw.cycle_id,
                    fdtm.type_material_id,
                    fdtm.fl_process_status,
                    fdtm.fl_process_without,
                    fdtm.fl_process_quality,
                    fdtm.fl_process_without_quality,
                    fdtm.fl_process_class_mat,
                    fdtm.fl_exam,
                    fdtm.fl_frequent,
                    fdtm.fl_complete_questions,
                    fdtm.data_incomplete_questions,
                    fdtm.fl_config_level,
                    fdtm.fl_config_type,
                    fdtm.limit_lower_question,
                    fdtm.limit_upper_question,
                    fdtm.material,
                    fdtm.fl_class_material,
                    fdtm.questions_generation_process,
                    fdtm.type_exam_id
                FROM cycle_weeks cw
                INNER JOIN cycle c ON cw.cycle_id = c.id
                INNER JOIN type_week tw ON cw.type_week_id = tw.id
                LEFT JOIN fn_detail_template_by_material(p_material_id, c.id, cw.week) fdtm ON 1 = 1
                WHERE cw.cycle_id IN (SELECT tm.cycle_id FROM tbl_material tm)
                    AND cw.fl_status = true
            )
            SELECT * FROM tbl_cycle_weeks tcw
            ORDER BY tcw.week ASC, tcw.material ASC;
        END;
        $$;


ALTER FUNCTION materials.fn_get_detail_template_material(p_material_id bigint) OWNER TO postgres;

--
