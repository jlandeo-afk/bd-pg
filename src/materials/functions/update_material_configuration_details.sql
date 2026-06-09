-- Function: materials.update_material_configuration_details(integer, integer, integer, text, integer, integer)

--

CREATE FUNCTION materials.update_material_configuration_details(p_type_material_template_id integer, p_material_configuration_detail_id integer, p_company_id integer, p_value text, p_exam_area_id integer, p_user integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_material_configuration_detail_value_id INT;
            v_template_type_material_configuration_id INT;
        BEGIN
            -- Verificar si ya existe un detalle de configuración con los parámetros dados
            SELECT mcdv.id
            INTO v_material_configuration_detail_value_id
            FROM materials.material_configuration_detail_value mcdv
            JOIN materials.template_type_material_configurations ttmc
            ON mcdv.template_type_material_configuration_id = ttmc.id
            WHERE ttmc.type_material_template_id = p_type_material_template_id
            AND ttmc.company_id = p_company_id
            AND (p_exam_area_id IS NULL OR  ttmc.exam_area_id = p_exam_area_id )
            AND mcdv.material_configuration_detail_id = p_material_configuration_detail_id
            AND mcdv.fl_status = TRUE;

            -- Si no existe, insertar
            IF v_material_configuration_detail_value_id IS NULL THEN
                -- Obtener el ID de la configuración de la plantilla de material
                SELECT ttmc.id
                INTO v_template_type_material_configuration_id
                FROM materials.template_type_material_configurations ttmc
                WHERE ttmc.type_material_template_id = p_type_material_template_id
                AND (p_exam_area_id IS NULL OR  ttmc.exam_area_id = p_exam_area_id )
                AND ttmc.company_id = p_company_id
                AND ttmc.fl_status = TRUE;

                -- Si no existe, insertar nueva configuración
                IF v_template_type_material_configuration_id IS NULL THEN
                    INSERT INTO materials.template_type_material_configurations
                        (type_material_template_id, exam_area_id,company_id, created_by, created_at)
                    VALUES
                        (p_type_material_template_id, p_exam_area_id,p_company_id, p_user, now())
                    RETURNING id INTO v_template_type_material_configuration_id;
                END IF;

                -- Insertar un nuevo detalle de configuración
                INSERT INTO materials.material_configuration_detail_value
                    (material_configuration_detail_id, template_type_material_configuration_id, value, created_by, created_at)
                VALUES
                    (p_material_configuration_detail_id, v_template_type_material_configuration_id, p_value, p_user, now());

            ELSE
                -- Si ya existe, actualizar el valor
                UPDATE materials.material_configuration_detail_value
                SET value = p_value, updated_by = p_user, updated_at = now()
                WHERE id = v_material_configuration_detail_value_id;
            END IF;

        END;
        $$;


ALTER FUNCTION materials.update_material_configuration_details(p_type_material_template_id integer, p_material_configuration_detail_id integer, p_company_id integer, p_value text, p_exam_area_id integer, p_user integer) OWNER TO postgres;

--
