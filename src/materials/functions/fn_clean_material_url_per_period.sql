-- Function: materials.fn_clean_material_url_per_period(bigint, bigint, smallint, bigint)

--

CREATE FUNCTION materials.fn_clean_material_url_per_period(p_material_id bigint, p_type_material_id bigint, p_week smallint, p_updated_by bigint) RETURNS TABLE(id bigint, material_id bigint, type_material_id smallint, start_week smallint, end_week smallint)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        WITH get_parent_type_material AS (
            SELECT CASE
                WHEN EXISTS (SELECT 1 FROM type_material tm WHERE tm.id = p_type_material_id AND tm.parent_id IS NOT NULL)
                THEN ARRAY(SELECT tm.parent_id FROM type_material tm WHERE tm.id = p_type_material_id AND tm.parent_id IS NOT NULL)
                ELSE ARRAY[p_type_material_id]
            END AS parent_type_material_id
        ), get_material_per_period_ballot AS (
            SELECT
                mppb.id
            FROM materials.material_per_period_ballot mppb
            JOIN material_per_period mpp ON mpp.id = mppb.material_per_period_id
            WHERE mpp.material_id = p_material_id
                AND mpp.type_material_id IN (SELECT unnest(gptm.parent_type_material_id) FROM get_parent_type_material gptm)
                AND p_week BETWEEN mppb.start_week AND mppb.end_week
                AND mppb.deleted_by IS NULL
            LIMIT 1
        ), clean_urls_per_period_ballot AS (
            UPDATE material_per_period_ballot_url mppbu
            SET job_url = null,
                job_id = null,
                file_name = null,
                fl_job_process = 'unprocessed',
                number_pages = null,
                retries = 0,
                updated_by = p_updated_by,
                updated_at = now()
            WHERE mppbu.material_per_period_ballot_id = (SELECT gmpb.id FROM get_material_per_period_ballot gmpb)
            AND mppbu.deleted_by IS NULL
        ), clean_week_courses AS (
            UPDATE material_per_period_week_course mppwc
            SET url = NULL,
                job_id = NULL,
                updated_by = p_updated_by,
                updated_at = NOW(),
                job_status = 'unprocessed'
            WHERE mppwc.material_per_period_ballot_id = (SELECT gmpb.id FROM get_material_per_period_ballot gmpb)
        ), clean_courses AS (
            UPDATE material_per_period_course mppc
            SET url = NULL,
                job_id = NULL,
                updated_by = p_updated_by,
                updated_at = NOW(),
                job_status = 'unprocessed',
                pages = 0,
                retries = 0
            WHERE mppc.material_per_period_ballot_id = (SELECT gmpb.id FROM get_material_per_period_ballot gmpb)
        )
        SELECT
            mppb.id,
            mpp.material_id,
            mpp.type_material_id,
            mppb.start_week,
            mppb.end_week
        FROM material_per_period_ballot mppb
        JOIN material_per_period mpp ON mpp.id = mppb.material_per_period_id
        WHERE mppb.id = (SELECT gmpb.id FROM get_material_per_period_ballot gmpb)
            AND mppb.deleted_by IS NULL;
    END;
    $$;


ALTER FUNCTION materials.fn_clean_material_url_per_period(p_material_id bigint, p_type_material_id bigint, p_week smallint, p_updated_by bigint) OWNER TO postgres;

--
