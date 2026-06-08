-- Function: odiseo.fn_update_manual_assignment_teacher(jsonb, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_update_manual_assignment_teacher(p_material_missing_question_ids jsonb, p_teacher_id bigint, p_created_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    WITH material_missing_questions AS (
        SELECT jsonb_array_elements_text(p_material_missing_question_ids)::BIGINT AS id
    ), manual_assigned_teacher AS (
        UPDATE material_missing_question_detail mmqd
        SET employee_id = p_teacher_id,
            status = 'assigned',
            assignment_type = 'manual',
            updated_at = now()
        FROM material_missing_questions mmq
        WHERE mmqd.id = mmq.id
        RETURNING mmqd.id
    )
    INSERT INTO material_missing_question_tracking (
        material_missing_question_detail_id,
        employee_id,
        action,
        assignment_type,
        created_by,
        created_at
    )
    SELECT
        mat.id,
        p_teacher_id,
        'assigned',
        'manual',
        p_created_by,
        now()
    FROM manual_assigned_teacher mat;
END;
$$;


ALTER FUNCTION odiseo.fn_update_manual_assignment_teacher(p_material_missing_question_ids jsonb, p_teacher_id bigint, p_created_by bigint) OWNER TO postgres;

--
