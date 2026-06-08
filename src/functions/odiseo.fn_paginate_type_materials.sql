-- Function: odiseo.fn_paginate_type_materials(integer, integer, character varying, bigint, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_paginate_type_materials(p_perpage integer, p_npage integer, p_search character varying, p_company_id bigint, p_type_material_template_id bigint DEFAULT NULL::bigint, p_cycle_id bigint DEFAULT NULL::bigint) RETURNS TABLE(id bigint, code character varying, description character varying, amount_question integer, fl_status boolean, areas jsonb, cycle_id bigint, name_cycle character varying, fl_exam boolean, fl_class_material boolean, childrens jsonb, thread smallint, percentage numeric, type_material_template_id bigint, total bigint)
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_offset INTEGER;
    v_tmt_name_1 TEXT;
    v_tmt_name_2 TEXT;
    v_tmt_name_3 TEXT;
BEGIN
    -- Obtener nombres de plantillas para el ordenamiento lógico
    SELECT tmt.name INTO v_tmt_name_1 FROM type_material_template tmt WHERE tmt.id = 1;
    SELECT tmt.name INTO v_tmt_name_2 FROM type_material_template tmt WHERE tmt.id = 2;
    SELECT tmt.name INTO v_tmt_name_3 FROM type_material_template tmt WHERE tmt.id = 3;

    v_offset := p_perpage * (p_npage - 1);

    RETURN QUERY
    WITH tbl_type_material_base AS (
        SELECT
            coalesce(t.parent_id, t.id) AS id,
            MAX(coalesce(tp.code, t.code))::VARCHAR AS code,
            MAX(coalesce(tp.description, t.description))::VARCHAR AS description,
            MAX(coalesce(tp.amount_question, t.amount_question)) AS amount_question,
            COALESCE(BOOL_OR(tp.fl_status), FALSE) AS fl_status,
            jsonb_agg(DISTINCT jsonb_build_object('area_id', tma.area_id, 'description', a.description))::JSONB AS areas,
            MAX(coalesce(tp.cycle_id, t.cycle_id)) AS cycle_id,
            MAX(c.description)::VARCHAR AS name_cycle,
            COALESCE(BOOL_OR(tp.fl_exam), FALSE) AS fl_exam,
            COALESCE(BOOL_OR(tp.fl_class_material), FALSE) AS fl_class_material,
            jsonb_agg(DISTINCT jsonb_build_object(
                'material_id', t.id,
                'amount', t.amount_question,
                'name', t.description
            )) FILTER (WHERE t.parent_id IS NOT NULL)::JSONB AS childrens,
            MAX(COALESCE(tp.thread, t.thread))::SMALLINT AS thread,
            MAX(COALESCE(tp.percentage, t.percentage))::NUMERIC AS percentage,
            MAX(COALESCE(tp.type_material_template_id, t.type_material_template_id)) AS type_material_template_id
        FROM type_material t
        LEFT JOIN type_material_area tma ON tma.type_material_id = t.id
        LEFT JOIN exam_area a ON a.id = tma.area_id
        JOIN cycle c ON t.cycle_id = c.id AND c.fl_status = true
        LEFT JOIN type_material tp ON tp.id = t.parent_id
        WHERE t.fl_status = true
          AND c.active IS TRUE
          AND (p_search IS NULL OR (t.code ILIKE '%' || p_search || '%' OR t.description ILIKE '%' || p_search || '%'))
          AND (p_cycle_id IS NULL OR t.cycle_id = p_cycle_id)
          AND t.company_id = p_company_id
        GROUP BY coalesce(t.parent_id, t.id)
    ),
    filtered_materials AS (
        SELECT * FROM tbl_type_material_base ttmb
        WHERE (p_type_material_template_id IS NULL OR ttmb.type_material_template_id = p_type_material_template_id)
    ),
    paginated_results AS (
        SELECT *, COUNT(*) OVER() AS total_count
        FROM filtered_materials fm
        ORDER BY
            fm.cycle_id DESC,
            CASE
                WHEN fm.description = v_tmt_name_1 THEN 0
                WHEN fm.description = v_tmt_name_2 THEN 1
                WHEN fm.description = v_tmt_name_3 THEN 2
                ELSE 3
            END,
            fm.description ASC
        LIMIT p_perpage
        OFFSET v_offset
    )
    SELECT 
        pr.id, pr.code, pr.description, pr.amount_question, pr.fl_status,
        pr.areas, pr.cycle_id, pr.name_cycle, pr.fl_exam, pr.fl_class_material, pr.childrens, 
        pr.thread, pr.percentage, pr.type_material_template_id, pr.total_count 
    FROM paginated_results pr;
END;
$$;


ALTER FUNCTION odiseo.fn_paginate_type_materials(p_perpage integer, p_npage integer, p_search character varying, p_company_id bigint, p_type_material_template_id bigint, p_cycle_id bigint) OWNER TO postgres;

--
