-- Function: materials.fn_get_regeneration_pdfs_progress(date)

--

CREATE FUNCTION materials.fn_get_regeneration_pdfs_progress(p_since_date date) RETURNS TABLE(digitalized_questions_completed bigint, digitalized_questions_uncompleted bigint, digitalized_regeneration_percentage numeric, verified_questions_completed bigint, verified_questions_uncompleted bigint, verified_regeneration_percentage numeric, completed bigint, uncompleted bigint, regeneration_percentage numeric)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            WITH question_pdf_migration_status AS (
                SELECT
                    q.status,
                    CASE
                        WHEN
                            q.status IN ('SASI', 'ASIG', 'DUPL', 'RESO')
                            AND q.url_pdf_updated_at IS NOT NULL
                            AND q.url_pdf_updated_at::DATE >= p_since_date THEN TRUE
                        WHEN 
                            q.status IN ('INDE', 'RECH', 'DASI')
                            AND q.url_pdf_updated_at IS NOT NULL
                            AND q.url_pdf_updated_at::DATE >= p_since_date
                            AND eq.url_pdf_question_solution_updated_at IS NOT NULL
                            AND eq.url_pdf_question_solution_updated_at::DATE >= p_since_date THEN TRUE
                        WHEN
                       		q.status IN ('DIGI', 'OBSE')
                       		AND q.url_pdf_updated_at IS NOT NULL
                            AND q.url_pdf_updated_at::DATE >= p_since_date
                            AND eq.url_pdf_question_solution_updated_at IS NOT NULL
                            AND eq.url_pdf_question_solution_updated_at::DATE >= p_since_date
                            AND ed.url_file_digitalized_solution_updated_at IS NOT NULL
                            AND ed.url_file_digitalized_solution_updated_at::DATE >= p_since_date THEN TRUE
                        WHEN
                            q.status IN ('VERI', 'PEND', 'RESV')
                            AND ed.url_file_digitalized_solution_updated_at IS NOT NULL
                            AND ed.url_file_digitalized_solution_updated_at::DATE >= p_since_date THEN TRUE
                        ELSE FALSE
                    END AS it_has_all_the_pdfs
                FROM questions.question q
                LEFT JOIN questions.employee_question eq ON q.id = eq.question_id AND eq.fl_status IS TRUE
                LEFT JOIN questions.employee_didi_question ed ON q.id = ed.question_id AND ed.fl_status IS TRUE
                WHERE 1 = 1
                  AND q.status <> 'ARCH'
                  AND q.fl_status IS TRUE
            ), regeneration_amount_by_status AS (
                SELECT
                    SUM(CASE WHEN status IN ('DIGI', 'OBSE') AND it_has_all_the_pdfs IS TRUE THEN 1 ELSE 0 END) digitalized_questions_completed,
                    SUM(CASE WHEN status IN ('DIGI', 'OBSE') AND it_has_all_the_pdfs IS FALSE THEN 1 ELSE 0 END) digitalized_questions_uncompleted,
                    SUM(CASE WHEN status IN ('VERI', 'PEND', 'RESV') AND it_has_all_the_pdfs IS TRUE THEN 1 ELSE 0 END) verified_questions_completed,
                    SUM(CASE WHEN status IN ('VERI', 'PEND', 'RESV') AND it_has_all_the_pdfs IS FALSE THEN 1 ELSE 0 END) verified_questions_uncompleted,
                    SUM(CASE WHEN it_has_all_the_pdfs IS TRUE THEN 1 ELSE 0 END) AS completed,
                    SUM(CASE WHEN it_has_all_the_pdfs IS FALSE THEN 1 ELSE 0 END) AS uncompleted
                FROM question_pdf_migration_status
            ) SELECT
                /* Digitalized questions */
                r.digitalized_questions_completed,
                r.digitalized_questions_uncompleted,
                ROUND((r.digitalized_questions_completed::DECIMAL / NULLIF(r.digitalized_questions_completed + r.digitalized_questions_uncompleted, 0) * 100), 2) AS digitalized_regeneration_percentage,
                /* Verified questions */
                r.verified_questions_completed,
                r.verified_questions_uncompleted,
                ROUND((r.verified_questions_completed::DECIMAL / NULLIF(r.verified_questions_completed + r.verified_questions_uncompleted, 0) * 100), 2) AS verified_regeneration_percentage,
                /* All questions */
                r.completed,
                r.uncompleted,
                ROUND((r.completed::DECIMAL / NULLIF(r.completed + r.uncompleted, 0) * 100), 2) AS regeneration_percentage
              FROM regeneration_amount_by_status r;
            END; $$;


ALTER FUNCTION materials.fn_get_regeneration_pdfs_progress(p_since_date date) OWNER TO postgres;

--
