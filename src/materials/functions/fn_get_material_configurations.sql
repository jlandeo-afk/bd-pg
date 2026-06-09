-- Function: materials.fn_get_material_configurations(bigint, bigint, bigint, bigint)

--

CREATE FUNCTION materials.fn_get_material_configurations(p_company_id bigint, p_area_id bigint, p_type_material_id bigint, p_type_template_id bigint) RETURNS TABLE(id bigint, category character varying, element character varying, material_detail jsonb)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_type_material_template_id BIGINT;
        BEGIN
            SELECT
                tm.type_material_template_id
            INTO v_type_material_template_id
            FROM type_material tm
            WHERE tm.id = p_type_material_id;

            RETURN QUERY
            SELECT
                mc.id,
                mc.category,
                mc.element,
                jsonb_agg(
                    json_build_object(
                        'id', mcd.id,
                        'material_configuration_id', mcd.material_configuration_id,
                        'name', mcd.name,
                        'value', (
                            SELECT a.value
                            FROM (
                                SELECT 
                                    a.value,
                                    ROW_NUMBER() OVER (
                                        PARTITION BY a.material_configuration_detail_id 
                                        ORDER BY 
                                            CASE 
                                                WHEN a.template_type_material_configuration_id IS NOT NULL THEN 1 
                                                ELSE 2 
                                            END,
                                            a.updated_at DESC
                                    ) AS rn
                                FROM materials.material_configuration_detail_value a
                                WHERE 
                                    (
                                        -- Registro válido (no nulo)
                                        a.template_type_material_configuration_id IN (
                                            SELECT ttmc1.id
                                            FROM materials.template_type_material_configurations ttmc1
                                            WHERE ttmc1.type_template_id = p_type_template_id
                                            AND ttmc1.type_material_template_id = v_type_material_template_id
                                            AND ttmc1.company_id = p_company_id
                                            AND ttmc1.fl_status = TRUE
                                            AND (p_area_id IS NULL OR ttmc1.exam_area_id = p_area_id)
                                        )
                                        -- Registro nulo, solo si no hay un par válido
                                        OR (
                                            a.template_type_material_configuration_id IS NULL
                                            AND a.material_configuration_detail_id NOT IN (
                                                SELECT material_configuration_detail_id
                                                FROM materials.material_configuration_detail_value mcdv3
                                                where mcdv3.template_type_material_configuration_id IN (
                                                    SELECT ttmc.id
                                                    FROM materials.template_type_material_configurations ttmc
                                                    WHERE ttmc.type_template_id = p_type_template_id
                                                    AND ttmc.type_material_template_id = v_type_material_template_id
                                                    AND ttmc.company_id = p_company_id
                                                    AND ttmc.fl_status = TRUE
                                                    AND (p_area_id IS NULL OR ttmc.exam_area_id = p_area_id)
                                                )
                                                and mcdv3.fl_status IS TRUE
                                            )
                                        )
                                    )
                                    AND a.material_configuration_detail_id = mcd.id
                                    AND a.fl_status = TRUE
                            ) a
                            WHERE a.rn = 1
                        )
                    )
                ) AS material_detail
            FROM
                material_configurations mc
            INNER JOIN
                material_configuration_details mcd
                ON mcd.material_configuration_id = mc.id
            WHERE
                mc.id <> 7
                AND mc.fl_status = TRUE
                AND mcd.fl_status = TRUE
            GROUP BY mc.id, mc.category, mc.element;
        END;
        $$;


ALTER FUNCTION materials.fn_get_material_configurations(p_company_id bigint, p_area_id bigint, p_type_material_id bigint, p_type_template_id bigint) OWNER TO postgres;

--
