-- Function: odiseo.fn_get_material_week_type_mat(bigint, smallint, smallint)

--

CREATE FUNCTION odiseo.fn_get_material_week_type_mat(p_material_id bigint, p_week smallint, p_type_material smallint) RETURNS TABLE(id bigint, material_id bigint, week smallint, type_material_id smallint, area_id smallint, url_solution character varying, url_without_solution character varying, url_quality character varying, url_without_quality character varying, parent_type_material_id smallint, fl_process_status smallint, fl_process_status_without smallint, fl_process_quality smallint, fl_process_without_quality smallint, job_solution_id character varying, job_without_solution_id character varying, job_quality_id character varying, job_without_quality_id character varying, fl_process_class_mat smallint, url_zip_class_mat character varying)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_type_materials SMALLINT[] := ARRAY[]::SMALLINT[];
            v_p_type_material_template_id SMALLINT;
            v_type_material_id SMALLINT;
            v_cycle_id BIGINT;
            v_fl_exam BOOLEAN;
        BEGIN
            -- Obtener plantilla de ciclo por medio del material
            SELECT m.cycle_id INTO v_cycle_id
            FROM material m
            WHERE m.id = p_material_id LIMIT 1;

            -- Obtener el estado de examen
            SELECT tym.fl_exam INTO v_fl_exam FROM type_material tym WHERE tym.id = p_type_material LIMIT 1;

            SELECT tmp.type_material_template_id INTO v_p_type_material_template_id
            FROM type_material tmp
            WHERE tmp.id = p_type_material LIMIT 1;

            FOR v_type_material_id IN
                SELECT tm.id
                FROM type_material_bound tmbo
                INNER JOIN type_material_template tmt ON tmbo.type_material_template_extra_id = tmt.id
                INNER JOIN type_material tm ON tmt.id = tm.type_material_template_id
                WHERE tmbo.type_material_template_id = v_p_type_material_template_id
                AND tm.cycle_id = v_cycle_id
                AND tmbo.fl_status = true
            LOOP
                v_type_materials := array_append(v_type_materials, v_type_material_id);
            END LOOP;

            IF v_type_materials = '{}' THEN
                v_type_materials := array_append(v_type_materials, p_type_material);
            END IF;

            IF v_fl_exam IS TRUE THEN
                RETURN QUERY
                SELECT
                    meaw.id,
                    dwt.material_id,
                    dwt.week,
                    dwt.type_material_id,
                    meaw.area_id,
                    meaw.url_solution,
                    meaw.url_without_solution,
                    meaw.url_quality,
                    meaw.url_without_quality,
                    dwt.parent_type_material_id,
                    meaw.fl_process_status,
                    meaw.fl_process_status_without,
                    meaw.fl_process_quality,
                    meaw.fl_process_without_quality,
                    meaw.job_solution_id,
                    meaw.job_without_solution_id,
                    meaw.job_quality_id,
                    meaw.job_without_quality_id,
                    0::SMALLINT AS fl_process_class_mat,
                    NULL::VARCHAR AS url_zip_class_mat
                FROM material_exam_area_week meaw
                INNER JOIN detail_week_type_mat dwt ON meaw.week_type_material_id = dwt.id AND meaw.fl_status = true AND dwt.fl_status IS TRUE
                WHERE dwt.material_id = p_material_id
                AND dwt.week = p_week
                AND dwt.type_material_id = ANY(v_type_materials)
                AND dwt.fl_status = true
                AND meaw.fl_status = true;
            ELSE
                RETURN QUERY
                SELECT
                    dwt.id,
                    dwt.material_id,
                    dwt.week,
                    dwt.type_material_id,
                    NULL::SMALLINT,
                    dwt.url_solution,
                    dwt.url_without_solution,
                    dwt.url_quality,
                    dwt.url_without_quality,
                    dwt.parent_type_material_id,
                    dwt.fl_process_status,
                    dwt.fl_process_status_without,
                    dwt.fl_process_quality,
                    dwt.fl_process_without_quality,
                    dwt.job_solution_id,
                    dwt.job_without_solution_id,
                    dwt.job_quality_id,
                    dwt.job_without_quality_id,
                    dwt.fl_process_class_mat,
                    dwt.url_zip_class_mat
                FROM detail_week_type_mat dwt
                WHERE dwt.material_id = p_material_id
                AND dwt.week = p_week
                AND dwt.type_material_id = ANY(v_type_materials)
                AND dwt.fl_status = true;
            END IF;
        END;
        $$;


ALTER FUNCTION odiseo.fn_get_material_week_type_mat(p_material_id bigint, p_week smallint, p_type_material smallint) OWNER TO postgres;

--
