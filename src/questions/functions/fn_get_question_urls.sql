-- Function: questions.fn_get_question_urls(bigint)

--

CREATE FUNCTION questions.fn_get_question_urls(p_question_id bigint) RETURNS TABLE(id bigint, url_pdf character varying, employee_question_didi bigint, url_pdf_question_solution character varying, employee_didi_question_didi bigint, url_file character varying, url_file_digitalized_solution character varying, status character varying)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            SELECT
                q.id,
                q.url_pdf,
                eq.id AS employee_question_id,
                eq.url_pdf_question_solution,
                ed.id AS employee_didi_question_id,
                ed.url_file,
                ed.url_file_digitalized_solution,
                q.status
            FROM questions.question q
            LEFT JOIN questions.employee_question eq ON q.id = eq.question_id AND eq.fl_status = true
            LEFT JOIN questions.employee_didi_question ed ON q.id = ed.question_id AND ed.fl_status = true
            WHERE q.id = p_question_id;
        END;
        $$;


ALTER FUNCTION questions.fn_get_question_urls(p_question_id bigint) OWNER TO postgres;

--
