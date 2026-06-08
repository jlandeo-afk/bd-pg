-- Function: odiseo.fn_assign_questions_docente(bigint, jsonb, smallint, smallint, bigint)

--

CREATE FUNCTION odiseo.fn_assign_questions_docente(p_teacher_id bigint, p_question_ids jsonb, p_week smallint, p_year smallint, p_created_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
        -- Insertar registros en employee_question
        INSERT INTO employee_question (
            teacher_id,
            question_id,
            week,
            year,
            created_by,
            created_at
        )
        SELECT
            p_teacher_id,
            value::BIGINT,
            p_week,
            p_year,
            p_created_by,
            now()
        FROM jsonb_array_elements(p_question_ids) AS value;

        -- Actualizar el estado de las preguntas
        UPDATE question
        SET
            "status" = 'ASIG',
            updated_by = p_created_by,
            updated_at = now()
        WHERE id IN (
            SELECT value::BIGINT FROM jsonb_array_elements(p_question_ids)
        );

    END;
    $$;


ALTER FUNCTION odiseo.fn_assign_questions_docente(p_teacher_id bigint, p_question_ids jsonb, p_week smallint, p_year smallint, p_created_by bigint) OWNER TO postgres;

--
