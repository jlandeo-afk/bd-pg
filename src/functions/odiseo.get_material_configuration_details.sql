-- Function: odiseo.get_material_configuration_details(integer, integer, integer, integer, integer)

--

CREATE FUNCTION odiseo.get_material_configuration_details(p_id integer, p_company_id integer, p_type_material_template_id integer, p_type_template_id integer, p_area_id integer) RETURNS TABLE(id bigint, name character varying, value text)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            SELECT
                mcd.id,
                mcd.name,
                COALESCE(
                    -- Verificar si p_type_material_template_id no es NULL
                    CASE
                        WHEN p_type_material_template_id IS NOT NULL THEN
                            (
                                SELECT mcdv1.value
                                FROM material_configuration_detail_value mcdv1
                                JOIN template_type_material_configurations ttmc1
                                    ON ttmc1.id = mcdv1.template_type_material_configuration_id
                                WHERE
                                    ttmc1.company_id = p_company_id
                                    AND ttmc1.type_material_template_id = p_type_material_template_id
                                    AND (p_type_template_id IS NULL OR ttmc1.type_template_id = p_type_template_id)
                                    AND mcdv1.material_configuration_detail_id = mcd.id
                                    AND mcdv1.fl_status = TRUE
                                    AND ttmc1.fl_status = TRUE
                                    AND (p_area_id IS NULL OR ttmc1.exam_area_id = p_area_id)
                                ORDER BY mcdv1.updated_at DESC -- Toma el registro más reciente
                                LIMIT 1
                            )
                    END,
                    -- Valor genérico (sin configuración específica)
                    (
                        SELECT mcdv2.value
                        FROM material_configuration_detail_value mcdv2
                        WHERE
                            mcdv2.material_configuration_detail_id = mcd.id
                            AND mcdv2.template_type_material_configuration_id IS NULL
                            AND mcdv2.fl_status = TRUE
                        ORDER BY mcdv2.updated_at DESC -- Toma el registro más reciente
                        LIMIT 1
                    )
                ) AS value
            FROM
                material_configurations mc
            INNER JOIN
                material_configuration_details mcd
                ON mcd.material_configuration_id = mc.id
            WHERE
                mc.id = p_id
                AND mc.fl_status = TRUE
                AND mcd.fl_status = TRUE;
        END;
        $$;


ALTER FUNCTION odiseo.get_material_configuration_details(p_id integer, p_company_id integer, p_type_material_template_id integer, p_type_template_id integer, p_area_id integer) OWNER TO postgres;

--
