-- Function: questions.fn_delete_index_question(bigint, bigint)

--

CREATE FUNCTION questions.fn_delete_index_question(p_question_id bigint, p_deleted_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_exists_eq BIGINT;
        BEGIN
            SELECT id INTO v_exists_eq
            FROM questions.employee_question
            WHERE question_id = p_question_id
            AND fl_status = true
            LIMIT 1;

            UPDATE questions.employee_question
            SET document_solution = null, board_json = '[]', updated_by = p_deleted_by, updated_at = now()
            WHERE question_id = v_exists_eq;

            IF v_exists_eq IS NOT NULL THEN
                UPDATE questions.employee_question_document
                SET fl_status = false, deleted_by = p_deleted_by, deleted_at = now()
                WHERE employee_question_id = v_exists_eq;
            END IF;
        END;
        $$;


ALTER FUNCTION questions.fn_delete_index_question(p_question_id bigint, p_deleted_by bigint) OWNER TO postgres;

--
