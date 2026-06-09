-- Function: materials.fn_get_material_revision_detail(bigint, bigint)

--

CREATE FUNCTION materials.fn_get_material_revision_detail(p_revision_id bigint, p_user_id bigint) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_employee_id bigint;
    v_result      json;
BEGIN
    -- 1. Obtener el employee_id asociado al user_id
    SELECT id INTO v_employee_id
    FROM employees
    WHERE user_id = p_user_id
      AND deleted_at IS NULL;

    -- 2. Construir la estructura jerárquica
    SELECT json_build_object(
        'id', mr.id,
        'status', mr.status,
        'weeks', ARRAY[mr.start_week, mr.end_week],
        'cycle', cyc.description,
        'last_date', mr.delivery_date,
        'limit_questions_to_change', adv.limit_questions_to_change,
        'detail_courses', COALESCE((
            SELECT json_agg(json_build_object(
                'id', mrc.id,
                'course', crs.name,
                'course_id', mrc.course_id,
                'date_verified', mrc.verify_date,
                'status', mrc.status,
                'amount_questions_changed', mrc.amount_questions_changed,
                'materials', (
                    SELECT json_agg(json_build_object(
                        'id', mppc.id,
                        'material_name', CONCAT_WS(' - ',
                            'Material',
                            CASE v.type_name
                                WHEN 'without_solution'        THEN 'Sin Solución - Oficial'
                                WHEN 'review_without_solution' THEN 'Sin Solución - Revisión'
                            END,
                            'Semana (' || mr.start_week || ' - ' || mr.end_week || ')'
                        ),
                        'status', COALESCE(mppc.job_status, 'unprocessed'),
                        'url_pdf', mppc.url,
                        'material_id', mat.id,
                        'type_material_id', mr.type_material_id,
                        'type_url', v.type_name
                    ) ORDER BY v.type_name DESC)
                    FROM (
                        VALUES ('without_solution'), ('review_without_solution')
                    ) AS v(type_name)
                    LEFT JOIN (
                        SELECT mppc.*, mpp.material_id, mpp.type_material_id
                        FROM material_per_period_course mppc
                        JOIN material_per_period_ballot mppb ON mppb.id = mppc.material_per_period_ballot_id
                        JOIN material_per_period mpp ON mpp.id = mppb.material_per_period_id
                        WHERE mpp.material_id = mr.material_id
                          AND mpp.type_material_id = mr.type_material_id
                          AND mppb.start_week = mr.start_week
                          AND mppb.end_week = mr.end_week
                          AND mppc.course_id = mrc.course_id
                          AND mppc.deleted_at IS NULL
                    ) mppc ON mppc.type = v.type_name
                )
            ) ORDER BY crs.name)
            FROM material_revision_courses mrc
            JOIN course crs ON crs.id = mrc.course_id
            LEFT JOIN employee_course ec ON ec.course_id = mrc.course_id
                                              AND ec.teacher_id = v_employee_id
                                              AND ec.fl_status = true
            WHERE mrc.material_revision_id = mr.id
              AND (p_user_id IS NULL OR ec.id IS NOT NULL)
              AND mrc.deleted_at IS NULL
        ), '[]'::json)
    ) INTO v_result
    FROM material_revisions mr
    JOIN material mat ON mat.id = mr.material_id
    JOIN cycle cyc ON cyc.id = mat.cycle_id
    JOIN advanced_settings adv ON adv.company_id = 1 -- odiseo
    WHERE mr.id = p_revision_id
      AND mr.deleted_at IS NULL;

    RETURN v_result;
END;
$$;


ALTER FUNCTION materials.fn_get_material_revision_detail(p_revision_id bigint, p_user_id bigint) OWNER TO postgres;

--
