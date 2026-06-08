-- Function: odiseo.fn_auto_assign_missing_questions_to_teacher(bigint, bigint, integer)

--

CREATE FUNCTION odiseo.fn_auto_assign_missing_questions_to_teacher(p_employee_id bigint, p_course_id bigint, p_limit integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_assigned_count INTEGER;
BEGIN
    WITH available_questions AS (
        SELECT mmqd.id
        FROM material_missing_question_detail mmqd
        JOIN material_ballot_question mdbq
            ON mmqd.material_ballot_question_id = mdbq.id
        JOIN material_missing_question mmq
            ON mmqd.material_missing_question_id = mmq.id
        WHERE mmqd.employee_id IS NULL
          AND mmqd.question_id IS NULL
          AND mmqd.status = 'pending'
          AND mmqd.deleted_at IS NULL
          AND mmq.deleted_at IS NULL
          AND mdbq.course_id = p_course_id
          AND mdbq.fl_status = true
          AND mdbq.deleted_at IS NULL
        ORDER BY
            mmq.request_date ASC,
            mmqd.id ASC
        LIMIT p_limit
        FOR UPDATE OF mmqd SKIP LOCKED
    ),
    -- Solo asignar si se cumple la cantidad exacta del límite
    validated_questions AS (
        SELECT id 
        FROM available_questions
        WHERE (SELECT COUNT(*) FROM available_questions) = p_limit
    ),
    -- Actualizar el detalle
    assigned_questions AS (
        UPDATE material_missing_question_detail mmqd
        SET employee_id = p_employee_id,
            assignment_type = 'auto',
            status = 'assigned',
            updated_at = now()
        FROM validated_questions vq
        WHERE mmqd.id = vq.id
        RETURNING mmqd.id
    )
    -- Registrar en tracking
    INSERT INTO material_missing_question_tracking (
        material_missing_question_detail_id,
        employee_id,
        action,
        assignment_type,
        created_at,
        updated_at
    )
    SELECT
        aq.id,
        p_employee_id,
        'assigned',
        'auto',
        now(),
        now()
    FROM assigned_questions aq;

    GET DIAGNOSTICS v_assigned_count = ROW_COUNT;
    RETURN v_assigned_count;
END;
$$;


ALTER FUNCTION odiseo.fn_auto_assign_missing_questions_to_teacher(p_employee_id bigint, p_course_id bigint, p_limit integer) OWNER TO postgres;

--
