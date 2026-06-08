-- Function: odiseo.fn_employee_question_document(integer)

--

CREATE FUNCTION odiseo.fn_employee_question_document(p_question_id integer) RETURNS TABLE(id bigint, employee_question_id bigint, type_archive_id smallint, document text, document_refuzed text, fl_refuzed boolean, fl_status boolean, created_by bigint, updated_by bigint, deleted_by bigint, created_at timestamp without time zone, updated_at timestamp without time zone, deleted_at timestamp without time zone, type_archive character varying, extension character varying, teacher_id bigint, question_id bigint, user_name character varying, user_email odiseo.email_citext)
    LANGUAGE plpgsql
    AS $$
                        BEGIN
                            RETURN QUERY
                            SELECT
                                d.id,
                                d.employee_question_id,
                                d.type_archive_id,
                                d.document,
                                d.document_refuzed,
                                d.fl_refuzed,
                                d.fl_status,
                                d.created_by,
                                d.updated_by,
                                d.deleted_by,
                                d.created_at,
                                d.created_at,
                                d.created_at,
                                t.name as type_archive,
                                t.extension,
                                eq.teacher_id,
                                eq.question_id,
                                u.user as user_name,
                                u.email as user_email
                            FROM employee_question_document d
                            INNER JOIN employee_question eq ON d.employee_question_id = eq.id AND eq.fl_status = TRUE
                            LEFT JOIN type_archive t ON d.type_archive_id = t.id
                            LEFT JOIN users u ON d.created_by = u.id
                            WHERE d.fl_status = TRUE
                            AND d.deleted_at IS NULL
                            AND eq.question_id = p_question_id
                            ORDER BY d.id ASC;
                        END;
                        $$;


ALTER FUNCTION odiseo.fn_employee_question_document(p_question_id integer) OWNER TO postgres;

--
