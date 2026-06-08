-- Function: odiseo.fn_unassign_missing_question(bigint, bigint)

--

CREATE FUNCTION odiseo.fn_unassign_missing_question(p_detail_id bigint, p_created_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_employee_id BIGINT;
BEGIN
    SELECT employee_id INTO v_employee_id
    FROM material_missing_question_detail
    WHERE id = p_detail_id;

    UPDATE material_missing_question_detail
    SET employee_id = NULL,
        assignment_type = NULL,
        status = 'pending',
        updated_at = now()
    WHERE id = p_detail_id;

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
        v_employee_id,
        'unassigned',
        NULL,
        p_created_by,
        now(),
        now()
    );
END;
$$;


ALTER FUNCTION odiseo.fn_unassign_missing_question(p_detail_id bigint, p_created_by bigint) OWNER TO postgres;

--
