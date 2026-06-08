-- Function: odiseo.list_type_material_template_children(bigint)

--

CREATE FUNCTION odiseo.list_type_material_template_children(p_type_material_template_id bigint) RETURNS SETOF odiseo.type_material_template
    LANGUAGE plpgsql
    AS $$
        DECLARE
        BEGIN
            RETURN QUERY SELECT distinct tmb_child.*
            FROM odiseo.type_material_bound as tmb
            LEFT JOIN odiseo.type_material_template as tmb_child
            ON tmb.type_material_template_extra_id = tmb_child.id
            AND tmb_child.fl_status AND tmb_child.deleted_at IS NULL
            WHERE tmb.type_material_template_id = p_type_material_template_id
            AND tmb.fl_status
            AND tmb.deleted_at IS NULL;
        END;
        $$;


ALTER FUNCTION odiseo.list_type_material_template_children(p_type_material_template_id bigint) OWNER TO postgres;

--
