-- Function: questions.fn_change_assigned_question(integer, integer, integer, integer, integer)

--

CREATE FUNCTION questions.fn_change_assigned_question(p_id integer, p_employee_id integer, p_week integer, p_year integer, p_updated_by integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_question_id INTEGER;
            v_teacher_id INTEGER;
            v_employee_question_id INTEGER;
        BEGIN
            UPDATE questions.question
            SET
                status = 'ASIG',
                teacher_id = p_employee_id,
                updated_by = p_updated_by,
                updated_at = now()
            WHERE
                id = p_id
            RETURNING id INTO v_question_id;

            SELECT teacher_id INTO v_teacher_id
            FROM questions.employee_question
            WHERE question_id = p_id
            AND fl_status = true;

            IF v_teacher_id <> p_employee_id OR v_teacher_id IS NULL THEN
                UPDATE questions.employee_question
                SET
                    fl_status = false,
                    deleted_by = p_updated_by,
                    deleted_at = now()
                WHERE question_id = p_id
                AND fl_status = true
                RETURNING id INTO v_employee_question_id;

                UPDATE questions.employee_question_document
                SET
                    fl_status = false,
                    deleted_by = p_updated_by,
                    deleted_at = now()
                WHERE employee_question_id = v_employee_question_id
                AND fl_status = true;

                INSERT INTO questions.employee_question (teacher_id, question_id, week, year, created_by, created_at)
                VALUES (p_employee_id, p_id, p_week, p_year, p_updated_by, now());

                RETURN v_question_id;
            ELSE
                RETURN NULL;
            END IF;
        END;
        $$;


ALTER FUNCTION questions.fn_change_assigned_question(p_id integer, p_employee_id integer, p_week integer, p_year integer, p_updated_by integer) OWNER TO postgres;

--
