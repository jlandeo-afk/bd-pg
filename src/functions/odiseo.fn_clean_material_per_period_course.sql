-- Function: odiseo.fn_clean_material_per_period_course(bigint, jsonb, bigint, character varying)

--

CREATE FUNCTION odiseo.fn_clean_material_per_period_course(p_material_per_period_ballot_id bigint, p_courses jsonb, p_updated_by bigint, p_type character varying DEFAULT NULL::character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
        WITH clean_material_per_period_course AS (
            UPDATE material_per_period_course mppc
            SET url = NULL,
                job_id = NULL,
                updated_at = NOW(),
                updated_by = p_updated_by,
                job_status = 'unprocessed'
            WHERE mppc.material_per_period_ballot_id = p_material_per_period_ballot_id
            AND (p_type IS NULL OR mppc.type = p_type)
            AND (
                mppc.course_id IS NULL
                OR mppc.course_id = ANY (
                    SELECT (jsonb_array_elements_text(p_courses))::SMALLINT
                )
            )
        )
        UPDATE material_per_period_week_course mppwc
        SET url = NULL,
            job_id = NULL,
            updated_at = NOW(),
            updated_by = p_updated_by,
            job_status = 'unprocessed'
        WHERE mppwc.material_per_period_ballot_id = p_material_per_period_ballot_id
        AND (p_type IS NULL OR mppwc.type = p_type)
        AND (
            mppwc.course_id IS NULL
            OR mppwc.course_id = ANY (
                SELECT (jsonb_array_elements_text(p_courses))::SMALLINT
            )
        );
    END;
    $$;


ALTER FUNCTION odiseo.fn_clean_material_per_period_course(p_material_per_period_ballot_id bigint, p_courses jsonb, p_updated_by bigint, p_type character varying) OWNER TO postgres;

--
