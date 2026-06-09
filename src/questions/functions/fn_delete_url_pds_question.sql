-- Function: questions.fn_delete_url_pds_question(bigint, smallint, bigint)

--

CREATE FUNCTION questions.fn_delete_url_pds_question(p_question_id bigint, p_type smallint, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN
            PERFORM id FROM question WHERE id = p_question_id FOR UPDATE;
            PERFORM question_id FROM employee_question WHERE question_id = p_question_id AND fl_status = true FOR UPDATE;
            PERFORM question_id FROM employee_didi_question WHERE question_id = p_question_id AND fl_status = true FOR UPDATE;
            
            IF p_type IN (1, 2, 3) THEN
                UPDATE employee_didi_question
                    SET
                        url_file_digitalized_solution = null,
                        url_file_digitalized_solution_updated_at = NOW(),
                        url_file_digitalized_images = null,
                        updated_by = p_updated_by,
                        updated_at = now()
                WHERE 1 = 1 
                  AND question_id = p_question_id
                  AND fl_status = true;
            END IF;

            IF p_type IN (1, 2) THEN
                UPDATE employee_question
                    SET
                        url_pdf_question_solution = null,
                        url_pdf_question_solution_updated_at = NOW(),
                        updated_by = p_updated_by,
                        updated_at = now() 
                WHERE 1 = 1
                  AND question_id = p_question_id
                  AND fl_status = true;
            END IF;

            IF p_type = 1 THEN
                UPDATE question
                    SET
                        url_pdf = null,
                        url_pdf_updated_at = NOW(),
                        updated_by = p_updated_by,
                        updated_at = now()
                    WHERE 1 = 1
                      AND id = p_question_id;
            END IF;
        END;
        $$;


ALTER FUNCTION questions.fn_delete_url_pds_question(p_question_id bigint, p_type smallint, p_updated_by bigint) OWNER TO postgres;

--
