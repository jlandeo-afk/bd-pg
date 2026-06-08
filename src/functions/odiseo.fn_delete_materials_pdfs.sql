-- Function: odiseo.fn_delete_materials_pdfs(bigint, smallint, jsonb, bigint)

--

CREATE FUNCTION odiseo.fn_delete_materials_pdfs(p_material_id bigint, p_week smallint, p_type_material_ids jsonb, p_deleted_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_fl_exam BOOLEAN;
            v_type_material_id SMALLINT;
            v_week_type_material_id BIGINT;
            v_material_exam_area_week_id BIGINT;
        BEGIN
            -- Estado de examen o balotario
            FOR v_type_material_id IN SELECT jsonb_array_elements(p_type_material_ids) LOOP
                -- Obtener si el tipo de material es balotario o examen
                SELECT tm.fl_exam INTO v_fl_exam FROM odiseo.type_material tm WHERE tm.id = v_type_material_id LIMIT 1;

                -- Obtener el id del material de la semana y tipo material mandado y eliminar las rutas de los materiales
                UPDATE odiseo.detail_week_type_mat detm
                SET url_solution = null, url_without_solution = null, fl_process_status = 1, fl_process_status_without = 1, fl_process_class_mat = 1, url_zip_class_mat = null,
                    url_quality = null, url_without_quality = null, fl_process_quality = 1, fl_process_without_quality = 1,
                    updated_by = p_deleted_by, updated_at = now()
                WHERE detm.material_id = p_material_id
                AND detm.week = p_week
                AND detm.type_material_id = v_type_material_id
                AND detm.fl_status = true
                RETURNING detm.id INTO v_week_type_material_id;

                IF v_week_type_material_id IS NOT NULL THEN
                    IF v_fl_exam IS TRUE THEN
                        FOR v_material_exam_area_week_id IN
                            SELECT meaw.id
                            FROM odiseo.material_exam_area_week meaw
                            WHERE meaw.week_type_material_id = v_week_type_material_id
                            AND meaw.fl_status = true
                        LOOP
                            -- Eliminar las rutas de los materiales por area
                            UPDATE odiseo.material_exam_area_week meaw1
                            SET url_solution = null, url_without_solution = null, fl_process_status = 1, fl_process_status_without = 1,
                                url_quality = null, url_without_quality = null, fl_process_quality = 1, fl_process_without_quality = 1,
                                updated_by = p_deleted_by, updated_at = now()
                            WHERE meaw1.id = v_material_exam_area_week_id;
                        END LOOP;
                    END IF;
                END IF;
            END LOOP;
        END;
        $$;


ALTER FUNCTION odiseo.fn_delete_materials_pdfs(p_material_id bigint, p_week smallint, p_type_material_ids jsonb, p_deleted_by bigint) OWNER TO postgres;

--
