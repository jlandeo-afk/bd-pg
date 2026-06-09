-- Function: materials.fn_get_parent_type_material(bigint, bigint)

--

CREATE FUNCTION materials.fn_get_parent_type_material(p_type_material_id bigint, p_material_id bigint) RETURNS TABLE(material_ids json)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_cycle_id BIGINT;
        BEGIN
            SELECT
                m.cycle_id INTO v_cycle_id
            FROM material m
            WHERE m.id = p_material_id
            LIMIT 1;

            RETURN QUERY
            WITH find_type_material_template_id AS (
                SELECT
                type_material_template_id
                FROM type_material
                WHERE id = p_type_material_id
            ), parent_type_material_ids AS (
                SELECT 
                    DISTINCT tm.id AS t_material_ids
                FROM type_material_bound tmb
                INNER JOIN type_material tm
                    ON tmb.type_material_template_id = tm.type_material_template_id
                WHERE 1 = 1
                    AND tmb.type_material_template_extra_id = (SELECT * FROM find_type_material_template_id)
                    AND tmb.fl_status = true
                    AND tm.cycle_id = v_cycle_id
            ), tbl_type_material AS (
				SELECT
                	COALESCE(t_material_ids, p_type_material_id) AS type_material_id
            	FROM parent_type_material_ids
			)
            SELECT *
			FROM fn_get_children_material_type_ids(
			    (SELECT type_material_id FROM tbl_type_material LIMIT 1),
			    v_cycle_id
			);
        END;
        $$;


ALTER FUNCTION materials.fn_get_parent_type_material(p_type_material_id bigint, p_material_id bigint) OWNER TO postgres;

--
