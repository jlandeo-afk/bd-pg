-- Function: materials.fn_create_or_update_url_material_ballot_per_period(bigint, character varying, character varying, character varying, character varying, character varying, bigint)

--

CREATE FUNCTION materials.fn_create_or_update_url_material_ballot_per_period(p_material_per_period_ballot_id bigint, p_type_url character varying, p_job_id character varying, p_fl_job_process character varying, p_job_url character varying, p_file_name character varying, p_created_by bigint) RETURNS TABLE(id bigint)
    LANGUAGE plpgsql
    AS $$
    DECLARE
        v_material_ballot_url_id BIGINT;
        v_number_pages SMALLINT;
    BEGIN
        SELECT
            mppbu.id INTO v_material_ballot_url_id
        FROM material_per_period_ballot_url mppbu
        WHERE mppbu.material_per_period_ballot_id = p_material_per_period_ballot_id
            AND mppbu.type_url = p_type_url
            AND mppbu.deleted_by IS NULL
        LIMIT 1;

        -- Obtener la cantidad de paginas
        SELECT
            COALESCE(MAX(mppb.pages), 0) INTO v_number_pages
        FROM material_per_period_course mppb
        WHERE mppb.material_per_period_ballot_id = p_material_per_period_ballot_id
            AND mppb.type = p_type_url
            AND mppb.deleted_by IS NULL;

        IF v_material_ballot_url_id IS NULL THEN
            INSERT INTO material_per_period_ballot_url AS mppbuc (
                material_per_period_ballot_id,
                type_url,
                job_id,
                fl_job_process,
                job_url,
                file_name,
                number_pages,
                created_by,
                created_at
            )
            VALUES (
                p_material_per_period_ballot_id,
                p_type_url,
                p_job_id,
                p_fl_job_process,
                p_job_url,
                p_file_name,
                v_number_pages,
                p_created_by,
                NOW()
            )
            RETURNING mppbuc.id INTO v_material_ballot_url_id;
        ELSE
            UPDATE material_per_period_ballot_url mppbu1
            SET type_url = p_type_url,
                job_id = p_job_id,
                fl_job_process = p_fl_job_process,
                job_url = p_job_url,
                file_name = p_file_name,
                number_pages = v_number_pages,
                updated_by = p_created_by,
                updated_at = NOW()
            WHERE mppbu1.id = v_material_ballot_url_id
            RETURNING mppbu1.id INTO v_material_ballot_url_id;
        END IF;

        RETURN QUERY
        SELECT v_material_ballot_url_id;
    END;
    $$;


ALTER FUNCTION materials.fn_create_or_update_url_material_ballot_per_period(p_material_per_period_ballot_id bigint, p_type_url character varying, p_job_id character varying, p_fl_job_process character varying, p_job_url character varying, p_file_name character varying, p_created_by bigint) OWNER TO postgres;

--
