-- Function: materials.fn_paginate_material_generated(integer, integer, integer, integer, integer, date, date)

--

CREATE FUNCTION materials.fn_paginate_material_generated(p_perpage integer, p_npage integer, p_company_id integer, p_cycle_id integer, p_type_material_template_id integer, p_start_date date, p_end_date date) RETURNS TABLE(material_id bigint, cycle_id bigint, cycle character varying, type_material_id smallint, type_material_description character varying, start_week smallint, end_week smallint, status character varying, created_at date, initial_total_questions bigint, initial_missing_questions bigint, completed_by_system bigint, completed_manually bigint, manually_removed bigint, current_total_questions bigint, current_missing_questions bigint, total_count bigint)
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_offset integer;
BEGIN
    v_offset := p_perpage * (p_npage - 1);

    RETURN QUERY
    WITH unified_questions AS (
        SELECT 
            mbq.material_id,
            COALESCE(dwtm.parent_type_material_id, mbq.type_material_id) AS root_type_material_id,
            mbq.week,
            mbq.entity_type,
            COALESCE(mbs.state, mbq.state) AS effective_state,
            COALESCE(dwtm.updated_at::date, dwtm.created_at::date) AS created_at
        FROM material_ballot_question mbq
        JOIN material m ON m.id = mbq.material_id AND m.fl_status = true AND m.deleted_at IS NULL
        JOIN cycle c ON c.id = m.cycle_id AND c.fl_status = true AND c.deleted_at IS NULL
        JOIN detail_week_type_mat dwtm 
            ON dwtm.id = mbq.week_type_material_id 
           AND dwtm.fl_status = true 
           AND dwtm.deleted_at IS NULL
        JOIN type_material tm ON tm.id = COALESCE(dwtm.parent_type_material_id, mbq.type_material_id)
        JOIN type_material_template tmt ON tmt.id = tm.type_material_template_id
        LEFT JOIN material_ballot_subquestions mbs 
            ON mbs.material_ballot_question_id = mbq.id
           AND mbs.fl_status = true 
           AND mbs.deleted_at IS NULL
        WHERE 
            (p_type_material_template_id IS NULL OR tmt.id = p_type_material_template_id)
            AND (p_cycle_id IS NULL OR m.cycle_id = p_cycle_id)
            AND (p_company_id IS NULL OR c.company_id = p_company_id)
            AND (p_start_date IS NULL OR COALESCE(dwtm.updated_at::date, dwtm.created_at::date) >= p_start_date)
            AND (p_end_date IS NULL OR COALESCE(dwtm.updated_at::date, dwtm.created_at::date) <= p_end_date)
            AND mbq.fl_status = true 
            AND mbq.deleted_at IS NULL
            AND (
                mbq.entity_type = 'QUESTION' 
                OR mbs.id IS NOT NULL
            )
    ),
    report_data AS (
        SELECT 
            m.id AS material_id,
            c.id AS cycle_id,
            c.description::varchar AS cycle,
            tm_root.id AS type_material_id,
            tm_root.description::varchar AS type_material_description,
            mppb.start_week,
            mppb.end_week,
            mr.status::varchar AS status,
            uq.created_at,
            COUNT(*) FILTER (WHERE uq.effective_state IN ('GENERATED', 'MANUAL_REMOVED')) AS initial_total_questions,
            COUNT(*) FILTER (WHERE uq.effective_state IN ('AUTO_COMPLETED', 'MANUAL_COMPLETED', 'MISSING')) AS initial_missing_questions,
            COUNT(*) FILTER (WHERE uq.effective_state = 'AUTO_COMPLETED') AS completed_by_system,
            COUNT(*) FILTER (WHERE uq.effective_state = 'MANUAL_COMPLETED') AS completed_manually,
            COUNT(*) FILTER (WHERE uq.effective_state = 'MANUAL_REMOVED') AS manually_removed,
            COUNT(*) FILTER (WHERE uq.effective_state NOT IN ('MISSING', 'MANUAL_REMOVED')) AS current_total_questions,
            COUNT(*) FILTER (WHERE uq.effective_state IN ('MISSING', 'MANUAL_REMOVED')) AS current_missing_questions
        FROM unified_questions uq
        JOIN material m ON m.id = uq.material_id
        JOIN cycle c ON c.id = m.cycle_id
        JOIN type_material tm_root ON tm_root.id = uq.root_type_material_id
        JOIN material_per_period mpp 
            ON mpp.material_id = m.id 
            AND mpp.type_material_id = uq.root_type_material_id
            AND mpp.deleted_at IS NULL
        JOIN material_per_period_ballot mppb 
            ON mppb.material_per_period_id = mpp.id
            AND uq.week BETWEEN mppb.start_week AND mppb.end_week
            AND mppb.deleted_at IS NULL
        LEFT JOIN material_revisions mr 
            ON mr.material_id = m.id
            AND tm_root.id = mr.type_material_id
            AND mppb.start_week = mr.start_week
            AND mppb.end_week = mr.end_week
        GROUP BY 
            m.id, 
            c.id, 
            c.description, 
            tm_root.id, 
            tm_root.description, 
            mppb.start_week, 
            mppb.end_week, 
            mr.status, 
            uq.created_at
    ),
    counted_data AS (
        SELECT *, COUNT(*) OVER () AS total_count
        FROM report_data
    )
    SELECT 
        cd.material_id,
        cd.cycle_id,
        cd.cycle,
        cd.type_material_id,
        cd.type_material_description,
        cd.start_week,
        cd.end_week,
        cd.status,
        cd.created_at,
        cd.initial_total_questions,
        cd.initial_missing_questions,
        cd.completed_by_system,
        cd.completed_manually,
        cd.manually_removed,
        cd.current_total_questions,
        cd.current_missing_questions,
        cd.total_count
    FROM counted_data cd
    ORDER BY cd.created_at DESC, cd.cycle, cd.type_material_description, cd.start_week
    LIMIT p_perpage
    OFFSET v_offset;
END;
$$;


ALTER FUNCTION materials.fn_paginate_material_generated(p_perpage integer, p_npage integer, p_company_id integer, p_cycle_id integer, p_type_material_template_id integer, p_start_date date, p_end_date date) OWNER TO postgres;

--
