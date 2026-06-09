-- Function: questions.fn_save_url_file_digitalized_images(bigint, text, bigint)

--

CREATE FUNCTION questions.fn_save_url_file_digitalized_images(p_question_id bigint, p_images text, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN
            UPDATE questions.employee_didi_question SET url_file_digitalized_images = p_images, updated_by = p_updated_by, updated_at = now() WHERE question_id = p_question_id AND fl_status = true;
        END;
        $$;


ALTER FUNCTION questions.fn_save_url_file_digitalized_images(p_question_id bigint, p_images text, p_updated_by bigint) OWNER TO postgres;

--
