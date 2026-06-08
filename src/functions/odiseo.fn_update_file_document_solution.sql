-- Function: odiseo.fn_update_file_document_solution(bigint, bigint, character varying, smallint, integer)

--

CREATE FUNCTION odiseo.fn_update_file_document_solution(p_question_id bigint, p_document_id bigint, p_path character varying, p_type_archive_id smallint, p_user integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_employee_question_id INT;

        BEGIN
            SELECT eq.id
            INTO v_employee_question_id
            FROM odiseo.employee_question eq
            WHERE eq.question_id = p_question_id
            AND eq.fl_status = TRUE
            AND eq.deleted_at IS NULL;

            IF p_document_id IS NULL THEN
                INSERT INTO odiseo.employee_question_document (
                    employee_question_id,
                    type_archive_id,
                    "document",
                    created_by,
                    created_at
                )
                VALUES (
                    v_employee_question_id,
                    p_type_archive_id,
                    p_path,
                    p_user,
                    NOW()
                );
            ELSE
                UPDATE odiseo.employee_question_document
                SET type_archive_id = p_type_archive_id,
                    "document" = p_path,
                    document_refuzed = NULL,
                    fl_refuzed = FALSE,
                    updated_by = p_user,
                    updated_at = NOW()
                WHERE employee_question_id = v_employee_question_id
                AND id = p_document_id;
            END IF;
        END;
        $$;


ALTER FUNCTION odiseo.fn_update_file_document_solution(p_question_id bigint, p_document_id bigint, p_path character varying, p_type_archive_id smallint, p_user integer) OWNER TO postgres;

--
