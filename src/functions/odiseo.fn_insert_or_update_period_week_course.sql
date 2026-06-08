-- Function: odiseo.fn_insert_or_update_period_week_course(bigint, smallint, smallint, character varying, character varying, bigint)

--

CREATE FUNCTION odiseo.fn_insert_or_update_period_week_course(p_material_per_period_ballot_id bigint, p_course_id smallint, p_week smallint, p_type character varying, p_job_id character varying, p_created_by bigint) RETURNS TABLE(id bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    INSERT INTO material_per_period_week_course AS mwc (material_per_period_ballot_id, course_id, week, job_id, type, created_by)
        VALUES (p_material_per_period_ballot_id, p_course_id, p_week, p_job_id, p_type, p_created_by)
        ON CONFLICT ON CONSTRAINT period_id_course_type_week
        DO UPDATE
            SET
                url = NULL,
                job_id = p_job_id,
                job_status = 'unprocessed',
                updated_by = p_created_by,
                updated_at = NOW(),
                deleted_by = NULL,
                deleted_at = NULL
    RETURNING mwc.id;
END;
$$;


ALTER FUNCTION odiseo.fn_insert_or_update_period_week_course(p_material_per_period_ballot_id bigint, p_course_id smallint, p_week smallint, p_type character varying, p_job_id character varying, p_created_by bigint) OWNER TO postgres;

--
