-- Function: odiseo.fn_deactive_ballot_per_period_url(bigint, bigint, smallint, smallint)

--

CREATE FUNCTION odiseo.fn_deactive_ballot_per_period_url(p_material_id bigint, p_type_material_id bigint, p_start_week smallint, p_end_week smallint) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    WITH material_per_period_ballot_id AS (
        SELECT
            mppb.id AS period_ballot_id
        FROM odiseo.material_per_period mpp
        JOIN odiseo.material_per_period_ballot mppb ON mpp.id = mppb.material_per_period_id
        WHERE 1 = 1
          AND mpp.type_material_id = p_type_material_id
          AND material_id = p_material_id
          AND mppb.start_week = p_start_week
          AND mppb.end_week = p_end_week
    ), update_unprocesses_ballot_url AS (
        UPDATE material_per_period_ballot_url mppbu
        SET job_url = null,
            job_id = null,
            file_name = null,
            fl_job_process = 'unprocessed',
            number_pages = null,
            updated_by = 1,
            updated_at = now()
        WHERE mppbu.material_per_period_ballot_id IN (SELECT period_ballot_id FROM material_per_period_ballot_id)
        AND mppbu.deleted_by IS NULL
    )
    UPDATE material_per_period_course mppc
    SET pages = 0,
        retries = 0
    WHERE mppc.material_per_period_ballot_id IN (SELECT period_ballot_id FROM material_per_period_ballot_id)
    AND mppc.deleted_by IS NULL;
END;
$$;


ALTER FUNCTION odiseo.fn_deactive_ballot_per_period_url(p_material_id bigint, p_type_material_id bigint, p_start_week smallint, p_end_week smallint) OWNER TO postgres;

--
