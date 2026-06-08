-- Function: odiseo.fn_get_material_revision_list(integer, integer, bigint, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_get_material_revision_list(p_perpage integer, p_npage integer, p_user_id bigint, p_cycle_id bigint DEFAULT NULL::bigint, p_company_id bigint DEFAULT NULL::bigint) RETURNS TABLE(id bigint, cycle_id bigint, cycle character varying, type_material_id smallint, type_material_description character varying, weeks json, delivery_date timestamp without time zone, verify_date timestamp without time zone, status character varying, course_total bigint, course_amount_verified bigint, total bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    offset_val INTEGER;
BEGIN
    offset_val := p_perpage * (p_npage - 1);

    RETURN QUERY
    WITH cte_revision AS (
        SELECT
            mr.id,
            c.id                                          AS cycle_id,
            c.description                                 AS cycle,
            tm.id                                         AS type_material_id,
            tm.description                                AS type_material_description,
            json_build_object(
                'start_week', mr.start_week,
                'end_week',   mr.end_week
            )                                             AS weeks,
            mr.delivery_date,
            mr.verify_date,
            mr.status,
            COUNT(mrc.id)                                 AS course_total,
            SUM(CASE WHEN mrc.status = 'verified' THEN 1 ELSE 0 END) AS course_amount_verified
        FROM material_revisions mr
        JOIN material mat         ON mat.id = mr.material_id
        JOIN cycle c              ON c.id = mat.cycle_id
        JOIN type_material tm     ON tm.id = mr.type_material_id
        JOIN material_revision_courses mrc
                                         ON mr.id = mrc.material_revision_id
        LEFT JOIN employees emp    ON emp.user_id = p_user_id
                                        AND emp.deleted_at IS NULL
        LEFT JOIN employee_course ec ON ec.teacher_id = emp.id
                                        AND ec.course_id = mrc.course_id
                                        AND ec.fl_status = true
                                        AND ec.deleted_at IS NULL
        WHERE mr.deleted_at  IS NULL
          AND mrc.deleted_at IS NULL
          AND mr.status != 'queued'
          AND (p_user_id IS NULL OR ec.id IS NOT NULL)
          AND (p_cycle_id IS NULL OR c.id = p_cycle_id)
          AND (p_company_id IS NULL OR c.company_id = p_company_id)
        GROUP BY mr.id, c.id, c.description, tm.id, tm.description, mr.start_week, mr.end_week,
                 mr.delivery_date, mr.verify_date, mr.status
    )
    SELECT chq.*, COUNT(*) OVER() AS total
    FROM cte_revision chq
    ORDER BY chq.delivery_date DESC
    LIMIT  p_perpage
    OFFSET offset_val;
END;
$$;


ALTER FUNCTION odiseo.fn_get_material_revision_list(p_perpage integer, p_npage integer, p_user_id bigint, p_cycle_id bigint, p_company_id bigint) OWNER TO postgres;

--
