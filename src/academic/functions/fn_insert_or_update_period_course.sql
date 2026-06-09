-- Function: academic.fn_insert_or_update_period_course(bigint, smallint, character varying, character varying, bigint)

--

CREATE FUNCTION academic.fn_insert_or_update_period_course(p_material_per_period_ballot_id bigint, p_course_id smallint, p_type character varying, p_job_id character varying, p_created_by bigint) RETURNS TABLE(id bigint, material_per_period_ballot_id bigint, weeks jsonb, type_material_template_id bigint, type_material_template character varying, type_template_id bigint)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                WITH insert_or_update_course AS (
                    INSERT INTO material_per_period_course AS mwc (
                        material_per_period_ballot_id,
                        course_id,
                        type,
                        job_id,
                        created_by
                    )
                    VALUES (
                        p_material_per_period_ballot_id,
                        p_course_id,
                        p_type,
                        p_job_id,
                        p_created_by
                    )
                    ON CONFLICT ON CONSTRAINT period_id_course_type
                    DO UPDATE
                    SET
                        url = NULL,
                        job_id = p_job_id,
                        job_status = 'unprocessed',
                        pages = 0, -- <-- Version 1.1,
                        retries = 0, -- <-- Version 1.1,
                        updated_by = p_created_by,
                        updated_at = NOW(),
                        deleted_by = NULL,
                        deleted_at = NULL
                    RETURNING mwc.id
                )
                SELECT
                    iouc.id,
                    mppb.id AS material_per_period_ballot_id,
                    (
                        SELECT JSONB_AGG(JSONB_BUILD_OBJECT('week', gs))
                        FROM generate_series(mppb.start_week::INT, mppb.end_week::INT) gs
                    ) AS weeks,
                    tm.type_material_template_id,
                    tmt.name AS type_material_template,
                    c.type_template_id
                FROM material_per_period_ballot mppb
                JOIN insert_or_update_course iouc ON 1 = 1
                JOIN material_per_period mpp ON mppb.material_per_period_id = mpp.id
                JOIN type_material tm ON mpp.type_material_id = tm.id
                JOIN cycle c ON tm.cycle_id = c.id
                JOIN type_material_template tmt ON tm.type_material_template_id = tmt.id
                WHERE mppb.id = p_material_per_period_ballot_id;
            END;
            $$;


ALTER FUNCTION academic.fn_insert_or_update_period_course(p_material_per_period_ballot_id bigint, p_course_id smallint, p_type character varying, p_job_id character varying, p_created_by bigint) OWNER TO postgres;

--
