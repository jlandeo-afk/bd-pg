-- Function: materials.fn_get_children_material_type_ids(bigint, bigint)

--

CREATE FUNCTION materials.fn_get_children_material_type_ids(p_type_material_id bigint, p_cycle_id bigint) RETURNS TABLE(material_ids json)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY

                WITH find_type_material_template_id AS (
                    SELECT
                    type_material_template_id
                    FROM type_material
                    WHERE id = p_type_material_id
                ), children_type_material_ids AS (
                    SELECT 
                        JSON_AGG(DISTINCT tm.id) t_material_ids
                    FROM type_material_bound tmb
                    INNER JOIN type_material tm
                       ON tmb.type_material_template_extra_id = tm.type_material_template_id
                    WHERE 1 = 1
                      AND tmb.type_material_template_id = (SELECT * FROM find_type_material_template_id)
                      AND tmb.fl_status = true
                      AND tm.cycle_id = p_cycle_id
                )
                SELECT
                    COALESCE(t_material_ids, JSON_BUILD_ARRAY(p_type_material_id)) AS material_ids
                FROM children_type_material_ids;
            END;
        $$;


ALTER FUNCTION materials.fn_get_children_material_type_ids(p_type_material_id bigint, p_cycle_id bigint) OWNER TO postgres;

--
