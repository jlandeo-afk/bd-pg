-- Function: odiseo.fn_get_failed_question_jobs()

--

CREATE FUNCTION odiseo.fn_get_failed_question_jobs() RETURNS TABLE(status character varying, process_type character varying, question_id bigint)
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    RETURN QUERY
                    WITH latest_jobs AS (
                        SELECT
                            qpj.status,
                            qpj.process_type,
                            qpj.question_id,
                            qpj.updated_at,
                            ROW_NUMBER() OVER(PARTITION BY qpj.question_id ORDER BY qpj.updated_at DESC) as rn
                        FROM
                            question_pdf_jobs qpj
                    )
                    SELECT
                        lj.status,
                        lj.process_type,
                        lj.question_id
                    FROM
                        latest_jobs lj
                    JOIN question q ON q.id = lj.question_id
                    WHERE
                        lj.rn = 1 
                        AND lj.status = 'failed'
                        AND q.status NOT IN('ARCH', 'PEND')
                    ORDER BY
                        lj.updated_at ASC;
                END;
            $$;


ALTER FUNCTION odiseo.fn_get_failed_question_jobs() OWNER TO postgres;

--
