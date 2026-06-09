-- Function: materials.list_type_material_template_children(bigint)

--

CREATE FUNCTION materials.list_type_material_template_children(p_type_material_template_id bigint) RETURNS SETOF materials.type_material_template
    LANGUAGE plpgsql
    AS $$
        DECLARE
        BEGIN
            RETURN QUERY SELECT distinct tmb_child.*
            FROM materials.type_material_bound as tmb
            LEFT JOIN materials.type_material_template as tmb_child
            ON tmb.type_material_template_extra_id = tmb_child.id
            AND tmb_child.fl_status AND tmb_child.deleted_at IS NULL
            WHERE tmb.type_material_template_id = p_type_material_template_id
            AND tmb.fl_status
            AND tmb.deleted_at IS NULL;
        END;
        $$;


ALTER FUNCTION materials.list_type_material_template_children(p_type_material_template_id bigint) OWNER TO postgres;

--
