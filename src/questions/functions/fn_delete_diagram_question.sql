-- Function: questions.fn_delete_diagram_question(bigint, bigint)

--

CREATE FUNCTION questions.fn_delete_diagram_question(p_question_id bigint, p_deleted_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_exists_edq BIGINT;
        BEGIN
            SELECT id INTO v_exists_edq
            FROM questions.employee_didi_question
            WHERE question_id = p_question_id
            AND fl_status = true
            LIMIT 1;

            UPDATE questions.employee_didi_question
            SET theory_base = null, data_unknown = null, "development " = null, answer = null, url_file = null, deleted_by = p_deleted_by, deleted_at = now()
            WHERE question_id = p_question_id
            AND fl_status = true;

            IF v_exists_edq IS NOT NULL THEN
                UPDATE questions.employee_didi_question_image
                SET fl_status = false, deleted_by = p_deleted_by, deleted_at = now()
                WHERE employee_didi_question_id = v_exists_edq;

                UPDATE questions.employee_didi_question_field
                SET fl_status = false, deleted_by = p_deleted_by, deleted_at = now()
                WHERE employee_didi_question_id = v_exists_edq;

                UPDATE questions.employee_didi_question_field_image
                SET fl_status = false, deleted_by = p_deleted_by, deleted_at = now()
                WHERE employee_didi_question_id = v_exists_edq;
            END IF;
        END;
        $$;


ALTER FUNCTION questions.fn_delete_diagram_question(p_question_id bigint, p_deleted_by bigint) OWNER TO postgres;

--
