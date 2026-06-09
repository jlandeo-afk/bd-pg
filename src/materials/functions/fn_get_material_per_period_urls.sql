-- Function: materials.fn_get_material_per_period_urls(integer, integer, integer, integer)

--

CREATE FUNCTION materials.fn_get_material_per_period_urls(p_material_id integer, p_parent_type_id integer, p_start_week integer, p_end_week integer) RETURNS TABLE(type_material_id integer, type_material character varying, id bigint, material_per_period_ballot_id bigint, type_url character varying, fl_job_process character varying, job_url character varying, job_id character varying, file_name character varying)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                WITH tbl_type_url (id, name) AS (
                    VALUES
                        (1, 'solution'::VARCHAR),
                        (3, 'review_solution'::VARCHAR)
                ), 
                type_material_ids AS (
                    SELECT UNNEST(
                        CASE
                            WHEN EXISTS (SELECT 1 FROM type_material tm WHERE tm.parent_id = p_parent_type_id)
                            THEN ARRAY(SELECT tm.id FROM type_material tm WHERE tm.parent_id = p_parent_type_id)
                            ELSE ARRAY[p_parent_type_id]
                        END
                    ) AS type_material_id
                )
                SELECT 
                    tmi.type_material_id,
                    tm.description type_material,
                    mppbu.id,
                    mppbu.material_per_period_ballot_id,
                    ttu.name AS type_url,
                    COALESCE(mppbu.fl_job_process, 'unprocessed'::VARCHAR) AS fl_job_process,
                    mppbu.job_url,
                    mppbu.job_id::VARCHAR,
                    mppbu.file_name
                FROM type_material_ids tmi
                JOIN type_material tm ON tm.id = tmi.type_material_id AND tm.parent_id IS NOT NULL
                CROSS JOIN tbl_type_url ttu
                LEFT JOIN material_per_period mpp 
                    ON mpp.type_material_id = tmi.type_material_id
                    AND mpp.material_id = p_material_id
                LEFT JOIN material_per_period_ballot mppb 
                    ON mppb.material_per_period_id = mpp.id 
                    AND mppb.start_week = p_start_week 
                    AND mppb.end_week = p_end_week
                LEFT JOIN material_per_period_ballot_url mppbu 
                    ON mppbu.material_per_period_ballot_id = mppb.id 
                    AND mppbu.type_url = ttu.name 
                    AND mppbu.deleted_by IS NULL
                ORDER BY tm.description;
            END;
            $$;


ALTER FUNCTION materials.fn_get_material_per_period_urls(p_material_id integer, p_parent_type_id integer, p_start_week integer, p_end_week integer) OWNER TO postgres;

--
