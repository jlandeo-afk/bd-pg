-- Function: odiseo.fn_reassign_missing_question(bigint, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_reassign_missing_question(p_detail_id bigint, p_new_employee_id bigint, p_created_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_old_employee_id BIGINT;
BEGIN
    SELECT employee_id INTO v_old_employee_id
    FROM material_missing_question_detail
    WHERE id = p_detail_id;

    UPDATE material_missing_question_detail
    SET employee_id = p_new_employee_id,
        assignment_type = 'manual',
        status = 'assigned',
        updated_at = now()
    WHERE id = p_detail_id;

    -- Tracking: unassigned del empleado anterior
    INSERT INTO material_missing_question_tracking (
        material_missing_question_detail_id,
        employee_id,
        action,
        assignment_type,
        created_by,
        created_at,
        updated_at
    ) VALUES (
        p_detail_id,
        v_old_employee_id,
        'unassigned',
        NULL,
        p_created_by,
        now(),
        now()
    );

    -- Tracking: reassigned al nuevo empleado
    INSERT INTO material_missing_question_tracking (
        material_missing_question_detail_id,
        employee_id,
        action,
        assignment_type,
        created_by,
        created_at,
        updated_at
    ) VALUES (
        p_detail_id,
        p_new_employee_id,
        'reassigned',
        'manual',
        p_created_by,
        now(),
        now()
    );
END;
$$;


ALTER FUNCTION odiseo.fn_reassign_missing_question(p_detail_id bigint, p_new_employee_id bigint, p_created_by bigint) OWNER TO postgres;

--
