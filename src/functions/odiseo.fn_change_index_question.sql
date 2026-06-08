-- Function: odiseo.fn_change_index_question(bigint, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_change_index_question(p_question_id bigint, p_answer_id bigint, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_employee_question_id BIGINT;
        BEGIN
            UPDATE question
            SET
                status = 'DASI',
                updated_by = p_updated_by,
                updated_at = NOW()
            WHERE id = p_question_id;

            PERFORM fn_sync_parent_question_with_subquestions_status(p_question_id, 'DASI', p_updated_by);

            UPDATE question_refuzed
            SET
                fl_active = FALSE,
                deleted_by = p_updated_by,
                deleted_at = NOW()
            WHERE question_id = p_question_id
              AND fl_status = TRUE;

            SELECT eq.id
            INTO v_employee_question_id
            FROM employee_question eq
            WHERE eq.question_id = p_question_id
              AND eq.fl_status = TRUE
            LIMIT 1;

            UPDATE employee_question
            SET
                board_refuzed = NULL,
                fl_refuzed = FALSE,
                url_pdf_question_solution = NULL,
                updated_by = p_updated_by,
                updated_at = NOW()
            WHERE question_id = p_question_id
              AND fl_status = TRUE;

            IF v_employee_question_id IS NOT NULL THEN
                UPDATE employee_question_document
                SET
                    document_refuzed = NULL,
                    fl_refuzed = FALSE,
                    updated_by = p_updated_by,
                    updated_at = NOW()
                WHERE employee_question_id = v_employee_question_id;
            END IF;

            UPDATE question
            SET
                answer_id = p_answer_id,
                updated_by = p_updated_by,
                updated_at = NOW()
            WHERE id = p_question_id;
        END;
        $$;


ALTER FUNCTION odiseo.fn_change_index_question(p_question_id bigint, p_answer_id bigint, p_updated_by bigint) OWNER TO postgres;

--
