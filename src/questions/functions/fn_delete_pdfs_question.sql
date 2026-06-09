-- Function: questions.fn_delete_pdfs_question(bigint, bigint)

--

CREATE FUNCTION questions.fn_delete_pdfs_question(p_question_id bigint, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
            BEGIN
                UPDATE questions.question SET url_pdf = null, updated_by = p_updated_by, updated_at = now() WHERE id = p_question_id;

                UPDATE questions.employee_question SET url_pdf_question_solution = null, updated_by = p_updated_by, updated_at = now() WHERE question_id = p_question_id AND fl_status = true;

                UPDATE questions.employee_didi_question SET url_file_digitalized_solution = null, updated_by = p_updated_by, updated_at = now() WHERE question_id = p_question_id AND fl_status = true;
            END;
            $$;


ALTER FUNCTION questions.fn_delete_pdfs_question(p_question_id bigint, p_updated_by bigint) OWNER TO postgres;

--
