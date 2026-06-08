-- Function: odiseo.fn_clean_ballor_url_period(bigint, character varying, bigint)

--

CREATE FUNCTION odiseo.fn_clean_ballor_url_period(p_material_per_period_ballot_id bigint, p_type character varying, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
        WITH clean_urls_per_period_ballot AS (
            UPDATE material_per_period_ballot_url mppbu
            SET job_url = NULL,
                job_id = NULL,
                file_name = NULL,
                fl_job_process = 'unprocessed',
                number_pages = null,
                retries = 0,
                updated_by = p_updated_by,
                updated_at = now()
            WHERE mppbu.material_per_period_ballot_id = p_material_per_period_ballot_id
                AND (p_type IS NULL OR mppbu.type_url = p_type)
        ), clean_week_courses AS (
            UPDATE material_per_period_week_course mppwc
            SET url = NULL,
                job_id = NULL,
                updated_at = NOW(),
                updated_by = p_updated_by,
                job_status = 'unprocessed'
            WHERE mppwc.material_per_period_ballot_id = p_material_per_period_ballot_id
            AND (p_type IS NULL OR mppwc.type = p_type)
        )
        UPDATE material_per_period_course mppc
        SET url = NULL,
            job_id = NULL,
            updated_at = NOW(),
            updated_by = p_updated_by,
            job_status = 'unprocessed',
            pages = 0,
            retries = 0
        WHERE mppc.material_per_period_ballot_id = p_material_per_period_ballot_id
        AND (p_type IS NULL OR mppc.type = p_type);
    END;
    $$;


ALTER FUNCTION odiseo.fn_clean_ballor_url_period(p_material_per_period_ballot_id bigint, p_type character varying, p_updated_by bigint) OWNER TO postgres;

--
