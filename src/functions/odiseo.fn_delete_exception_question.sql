-- Function: odiseo.fn_delete_exception_question(bigint, character varying, bigint)

--

CREATE FUNCTION odiseo.fn_delete_exception_question(p_question_id bigint, p_status_old character varying, p_deleted_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_employee_question BIGINT;
        BEGIN
            IF p_status_old = 'OBSE' THEN
                UPDATE odiseo.question_observation SET fl_status = false, deleted_by = p_deleted_by, deleted_at = now()
                WHERE question_id = p_question_id AND type = 'OBSE' AND fl_status = true;
            ELSIF p_status_old = 'RECH' THEN
                UPDATE odiseo.question_refuzed SET fl_status = false, deleted_by = p_deleted_by, deleted_at = now()
                WHERE question_id = p_question_id AND fl_status = true;

                SELECT id INTO v_employee_question FROM odiseo.employee_question
                WHERE question_id = p_question_id AND fl_status = true LIMIT 1;

                UPDATE odiseo.employee_question SET board_refuzed = null, fl_refuzed = false, url_pdf_question_solution = null, updated_by = p_deleted_by, updated_at = now() WHERE question_id = p_question_id AND fl_status = true;

                IF v_employee_question IS NOT NULL THEN
                    UPDATE odiseo.employee_question_document SET document_refuzed = null, fl_refuzed = false, updated_by = p_deleted_by, updated_at = now() WHERE employee_question_id = v_employee_question AND fl_status = true;
                END IF;
            END IF;
        END;
        $$;


ALTER FUNCTION odiseo.fn_delete_exception_question(p_question_id bigint, p_status_old character varying, p_deleted_by bigint) OWNER TO postgres;

--
