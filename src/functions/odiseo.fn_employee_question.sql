-- Function: odiseo.fn_employee_question(integer)

--

CREATE FUNCTION odiseo.fn_employee_question(p_question_id integer) RETURNS TABLE(id bigint, teacher_id bigint, question_id bigint, alternative_id bigint, fl_status boolean, created_by bigint, updated_by bigint, deleted_by bigint, created_at timestamp without time zone, updated_at timestamp without time zone, deleted_at timestamp without time zone, type character varying, document_solution text, board_json text, board_refuzed text, fl_refuzed boolean, week integer, year integer, solved boolean, url_pdf_question_solution character varying, user_name character varying, user_email odiseo.email_citext)
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    RETURN QUERY
                    SELECT
                        eq.id,
                        eq.teacher_id,
                        eq.question_id,
                        eq.alternative_id,
                        eq.fl_status,
                        eq.created_by,
                        eq.updated_by,
                        eq.deleted_by,
                        eq.created_at,
                        eq.updated_at,
                        eq.deleted_at,
                        eq.type,
                        eq.document_solution,
                        eq.board_json,
                        eq.board_refuzed,
                        eq.fl_refuzed,
                        eq.week,
                        eq.year,
                        eq.solved,
                        eq.url_pdf_question_solution,
                        u.user as user_name,
                        u.email as user_email
                    FROM employee_question eq
                    LEFT JOIN users u ON eq.created_by = u.id
                    WHERE eq.fl_status = TRUE
                    AND eq.deleted_at IS NULL
                    AND eq.question_id = p_question_id
                    ORDER BY eq.id ASC;
                END;
                $$;


ALTER FUNCTION odiseo.fn_employee_question(p_question_id integer) OWNER TO postgres;

--
