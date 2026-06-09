-- Function: academic.fn_generate_detail_week_type_mat(bigint, smallint, smallint, smallint, boolean, boolean, smallint, smallint, bigint)

--

CREATE FUNCTION academic.fn_generate_detail_week_type_mat(p_material_id bigint, p_week smallint, p_type_material_id smallint, p_parent_type_material smallint, p_fl_config_level boolean, p_fl_config_type boolean, p_limit_lower_question smallint, p_limit_upper_question smallint, p_created_by bigint) RETURNS TABLE(detail_id bigint, cycle_id bigint, fl_examen boolean, name_type_material character varying, name_type_material_template character varying, process_status smallint)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_detail_id BIGINT;
            v_parent_type_material_id SMALLINT;
            v_url_solution VARCHAR;
            v_fl_process_status SMALLINT;
            v_fl_exam BOOLEAN;
            v_name_type_material VARCHAR;
            v_name_type_material_template VARCHAR;
            v_cycle_id BIGINT;
            v_fl_class_material BOOLEAN;
            v_fl_process_class_mat SMALLINT;
        BEGIN
            -- Obtener ciclo del material
            SELECT m.cycle_id INTO v_cycle_id FROM material m WHERE m.id = p_material_id LIMIT 1;

            -- Tipo de material padre
            SELECT tmp.fl_class_material INTO v_fl_class_material FROM type_material tmp WHERE tmp.id = p_parent_type_material;

            IF v_fl_class_material IS TRUE THEN
                v_fl_process_class_mat := 1::SMALLINT;
            ELSE
                v_fl_process_class_mat := 0::SMALLINT;
            END IF;

            -- Estado de examen o balotario
            SELECT tm.fl_exam, tm.description, tmt.name INTO v_fl_exam, v_name_type_material, v_name_type_material_template
            FROM type_material tm
            LEFT JOIN type_material_template tmt ON tm.type_material_template_id = tmt.id
            WHERE tm.id = p_type_material_id LIMIT 1;

            SELECT
                id, url_solution, fl_process_status
                INTO v_detail_id, v_url_solution, v_fl_process_status
            FROM detail_week_type_mat
            WHERE material_id = p_material_id AND week = p_week
            AND type_material_id = p_type_material_id AND fl_status = true LIMIT 1;

            IF v_detail_id IS NULL THEN
                IF p_type_material_id <> p_parent_type_material THEN
                    INSERT INTO detail_week_type_mat (
                        material_id,
                        week,
                        type_material_id,
                        parent_type_material_id,
                        fl_process_class_mat,
                        fl_config_level,
                        fl_config_type,
                        limit_lower_question,
                        limit_upper_question,
                        created_by,
                        created_at
                    )
                    VALUES (
                        p_material_id,
                        p_week,
                        p_type_material_id,
                        p_parent_type_material,
                        v_fl_process_class_mat,
                        p_fl_config_level,
                        p_fl_config_type,
                        p_limit_lower_question,
                        p_limit_upper_question,
                        p_created_by,
                        now()
                    )
                    RETURNING id, fl_process_status INTO v_detail_id, v_fl_process_status;
                ELSE
                    INSERT INTO detail_week_type_mat (
                        material_id,
                        week,
                        type_material_id,
                        fl_process_class_mat,
                        fl_config_level,
                        fl_config_type,
                        limit_lower_question,
                        limit_upper_question,
                        created_by,
                        created_at
                    )
                    VALUES (
                        p_material_id,
                        p_week,
                        p_type_material_id,
                        v_fl_process_class_mat,
                        p_fl_config_level,
                        p_fl_config_type,
                        p_limit_lower_question,
                        p_limit_upper_question,
                        p_created_by,
                        now()
                    )
                    RETURNING id, fl_process_status INTO v_detail_id, v_fl_process_status;
                END IF;

                RETURN QUERY SELECT v_detail_id, v_cycle_id, v_fl_exam, v_name_type_material, v_name_type_material_template, v_fl_process_status;
            ELSE
                RETURN QUERY SELECT null::BIGINT, v_cycle_id, v_fl_exam, v_name_type_material, v_name_type_material_template, v_fl_process_status;
            END IF;
        END;
        $$;


ALTER FUNCTION academic.fn_generate_detail_week_type_mat(p_material_id bigint, p_week smallint, p_type_material_id smallint, p_parent_type_material smallint, p_fl_config_level boolean, p_fl_config_type boolean, p_limit_lower_question smallint, p_limit_upper_question smallint, p_created_by bigint) OWNER TO postgres;

--
