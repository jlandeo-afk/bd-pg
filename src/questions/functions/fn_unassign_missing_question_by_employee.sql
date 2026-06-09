-- Function: questions.fn_unassign_missing_question_by_employee(bigint, bigint)

--

CREATE FUNCTION questions.fn_unassign_missing_question_by_employee(p_employee_id bigint, p_created_by bigint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_count INTEGER;
BEGIN
    WITH unassigned_details AS (
        UPDATE material_missing_question_detail
        SET employee_id = NULL,
            assignment_type = NULL,
            status = 'pending',
            updated_at = now()
        WHERE employee_id = p_employee_id
          AND status = 'assigned'
        RETURNING id
    )
    INSERT INTO material_missing_question_tracking (
        material_missing_question_detail_id,
        employee_id,
        action,
        assignment_type,
        created_by,
        created_at,
        updated_at
    )
    SELECT
        ud.id,
        p_employee_id,
        'unassigned',
        NULL,
        p_created_by,
        now(),
        now()
    FROM unassigned_details ud;

    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$;


ALTER FUNCTION questions.fn_unassign_missing_question_by_employee(p_employee_id bigint, p_created_by bigint) OWNER TO postgres;

--
