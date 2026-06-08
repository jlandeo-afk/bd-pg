-- Function: odiseo.fn_get_missing_questions_to_regenerate(date, text[])

--

CREATE FUNCTION odiseo.fn_get_missing_questions_to_regenerate(p_since_date date, p_excluded_statuses text[]) RETURNS TABLE(question_id bigint, question_status character varying)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            SELECT
 	            q.id AS question_id,
 	            q.status AS question_status
            FROM odiseo.question q
            LEFT JOIN odiseo.employee_question eq ON q.id = eq.question_id AND eq.fl_status IS TRUE
            LEFT JOIN odiseo.employee_didi_question ed ON q.id = ed.question_id AND ed.fl_status IS TRUE
            WHERE 1 = 1
              AND q.status NOT IN (SELECT UNNEST(p_excluded_statuses))
              AND q.fl_status IS TRUE
              AND (
                    CASE
                        WHEN
                            q.status IN ('SASI', 'ASIG', 'DUPL', 'RESO')
                            AND (
                                q.url_pdf_updated_at IS NULL OR
                                q.url_pdf_updated_at::DATE < p_since_date
                            )
                            THEN TRUE
                        WHEN
                            q.status IN ('INDE', 'RECH', 'DASI')
                            AND (
                                q.url_pdf_updated_at IS NULL OR
                                eq.url_pdf_question_solution_updated_at IS NULL OR
                                q.url_pdf_updated_at::DATE < p_since_date OR
                                eq.url_pdf_question_solution_updated_at::DATE < p_since_date
                            )
                            THEN TRUE
                        WHEN
                            q.status IN ('DIGI', 'OBSE')
                            AND (
                                q.url_pdf_updated_at IS NULL OR
                                eq.url_pdf_question_solution_updated_at IS NULL OR
                                ed.url_file_digitalized_solution_updated_at IS NULL OR
                                q.url_pdf_updated_at::DATE < p_since_date OR
                                eq.url_pdf_question_solution_updated_at::DATE < p_since_date OR
                                ed.url_file_digitalized_solution_updated_at::DATE < p_since_date
                            ) THEN TRUE
                        WHEN
                            q.status IN ('VERI', 'PEND', 'RESV')
                            AND (
                                ed.url_file_digitalized_solution_updated_at IS NULL OR
                                ed.url_file_digitalized_solution_updated_at::DATE < p_since_date
                            )
                            THEN TRUE
                        ELSE FALSE
                    END
                )
            ORDER BY
                CASE
                    WHEN q.status IN ('DIGI', 'OBSE') THEN 0
                    WHEN q.status IN ('VERI', 'PEND', 'RESV') THEN 1
                    ELSE 2
                END
            LIMIT 1;
        END; $$;


ALTER FUNCTION odiseo.fn_get_missing_questions_to_regenerate(p_since_date date, p_excluded_statuses text[]) OWNER TO postgres;

--
