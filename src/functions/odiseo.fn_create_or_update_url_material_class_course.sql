-- Function: odiseo.fn_create_or_update_url_material_class_course(bigint, smallint, character varying, character varying, character varying, character varying, bigint)

--

CREATE FUNCTION odiseo.fn_create_or_update_url_material_class_course(p_material_per_period_ballot_url_id bigint, p_course_id smallint, p_job_id character varying, p_fl_job_process character varying, p_job_url character varying, p_file_name character varying, p_created_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_material_ballot_class_url_id BIGINT;
        BEGIN
            SELECT
                mppbc.id INTO v_material_ballot_class_url_id
            FROM material_per_period_ballot_class mppbc
            WHERE mppbc.material_per_period_ballot_url_id = p_material_per_period_ballot_url_id
                AND mppbc.course_id = p_course_id
                AND mppbc.deleted_by IS NULL
            LIMIT 1;

            IF v_material_ballot_class_url_id IS NULL THEN
                INSERT INTO material_per_period_ballot_class (
                    material_per_period_ballot_url_id,
                    course_id,
                    job_id,
                    fl_job_process,
                    job_url,
                    file_name,
                    created_by,
                    created_at
                )
                VALUES (
                    p_material_per_period_ballot_url_id,
                    p_course_id,
                    p_job_id,
                    p_fl_job_process,
                    p_job_url,
                    p_file_name,
                    p_created_by,
                    NOW()
                );
            ELSE
                UPDATE material_per_period_ballot_class mppbc1
                SET course_id = p_course_id,
                    job_id = p_job_id,
                    fl_job_process = p_fl_job_process,
                    job_url = p_job_url,
                    file_name = p_file_name,
                    updated_by = p_created_by,
                    updated_at = NOW()
                WHERE mppbc1.id = v_material_ballot_class_url_id;
            END IF;
        END;
        $$;


ALTER FUNCTION odiseo.fn_create_or_update_url_material_class_course(p_material_per_period_ballot_url_id bigint, p_course_id smallint, p_job_id character varying, p_fl_job_process character varying, p_job_url character varying, p_file_name character varying, p_created_by bigint) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
