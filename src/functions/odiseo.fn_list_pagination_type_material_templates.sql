-- Function: odiseo.fn_list_pagination_type_material_templates(integer, integer, text, boolean)

--

CREATE FUNCTION odiseo.fn_list_pagination_type_material_templates(p_per_page integer, p_n_page integer, p_name text, p_fl_exam boolean) RETURNS TABLE(id bigint, name character varying, fl_exam boolean, child_type_material_templates jsonb, created_at timestamp without time zone, total integer, is_children boolean, type_exam_name character varying, type_exam_id bigint, fl_revision boolean)
    LANGUAGE plpgsql
    AS $$
                DECLARE
                    total_count INTEGER;
                    offset_val INTEGER;
                BEGIN
                    offset_val := p_per_page * (p_n_page - 1);

                    SELECT COUNT(*)
                    INTO total_count
                    FROM type_material_template tmt
                    WHERE 1 = 1
                        AND (p_name IS NULL OR tmt.name ILIKE CONCAT('%', p_name, '%'))
                        AND tmt.deleted_at IS NULL AND tmt.fl_status
                        AND (p_fl_exam IS NULL OR tmt.fl_exam = p_fl_exam);

                    RETURN QUERY
                    SELECT
                        tmt.id,
                        tmt.name,
                        tmt.fl_exam,
                        COALESCE(
                            jsonb_agg(
                                DISTINCT
                                jsonb_build_object( 
                                    'id', tmt2.id,
                                    'name', tmt2.name
                                )
                            ) FILTER (WHERE tmt2.id IS NOT NULL),
                            '[]'::JSONB
                        ) AS child_type_material_templates,
                        tmt.created_at,
                        total_count AS total,
                        exists(select 1 from type_material_bound tmb2 where tmb2.type_material_template_extra_id = tmt.id  and tmb2.fl_status = true) as is_children,
                        te.name as type_exam_name,
                        te.id as type_exam_id,
                        tmt.fl_revision
                    FROM type_material_template tmt
                    LEFT JOIN type_material_bound tmb
                        ON tmb.type_material_template_id = tmt.id AND tmb.fl_status = true
                    LEFT JOIN type_material_template tmt2
                        ON tmb.type_material_template_extra_id = tmt2.id
                    LEFT JOIN type_exams te
                        ON te.id = tmt.type_exam_id
                    WHERE 1 = 1
                    AND (p_name IS NULL OR tmt.name ILIKE CONCAT('%', p_name, '%'))
                    AND tmt.deleted_at IS NULL AND tmt.fl_status = true
                    AND (p_fl_exam IS NULL OR tmt.fl_exam = p_fl_exam)
                    GROUP BY
                        tmt.id,
                        tmt.name,
                        tmt.fl_exam,
                        tmt.created_at,
                        te.id
                    ORDER BY tmt.created_at DESC, tmt.name ASC
                    LIMIT p_per_page
                    OFFSET offset_val;
                END;
                $$;


ALTER FUNCTION odiseo.fn_list_pagination_type_material_templates(p_per_page integer, p_n_page integer, p_name text, p_fl_exam boolean) OWNER TO postgres;

--
