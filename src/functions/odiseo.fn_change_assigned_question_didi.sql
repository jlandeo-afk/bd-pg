-- Function: odiseo.fn_change_assigned_question_didi(bigint, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_change_assigned_question_didi(p_id bigint, p_employee_id bigint, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_employee_id BIGINT;
BEGIN
    UPDATE question
    SET
        status = 'DASI',
        updated_by = p_updated_by,
        updated_at = now()
    WHERE
        id = p_id;

    PERFORM fn_sync_parent_question_with_subquestions_status(p_id, 'DASI', p_updated_by);

    SELECT
        employee_id
    INTO v_employee_id
    FROM employee_didi_question
    WHERE 1 = 1
      AND question_id = p_id
      AND fl_status = true
    ORDER BY employee_id
    LIMIT 1;

    IF v_employee_id IS NOT NULL AND ( v_employee_id <> p_employee_id ) THEN
        UPDATE employee_didi_question
            SET
                employee_id = p_employee_id,
                updated_by = p_updated_by
            WHERE 1 = 1
              AND question_id = p_id
              AND fl_status IS TRUE;
    ELSE
        INSERT INTO employee_didi_question (employee_id, question_id, week, year, created_by, created_at)
        VALUES (p_employee_id, p_id, date_part('week', now()), date_part('year', now()), p_updated_by, now());
    END IF;
END;
$$;


ALTER FUNCTION odiseo.fn_change_assigned_question_didi(p_id bigint, p_employee_id bigint, p_updated_by bigint) OWNER TO postgres;

--
