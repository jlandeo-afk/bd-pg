-- Function: odiseo.fn_deactive_ballot_per_course_url(bigint, bigint)

--

CREATE FUNCTION odiseo.fn_deactive_ballot_per_course_url(p_material_revision_course_id bigint, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_material_id BIGINT;
    v_type_material_id BIGINT;
    v_start_week SMALLINT;
    v_end_week SMALLINT;
    v_course_id SMALLINT;
    v_period_ballot_id BIGINT;
BEGIN
    -- 1. Obtener datos de la revisión del curso y del material
    SELECT 
        mr.material_id,
        mr.type_material_id,
        mr.start_week,
        mr.end_week,
        mrc.course_id
    INTO 
        v_material_id,
        v_type_material_id,
        v_start_week,
        v_end_week,
        v_course_id
    FROM material_revision_courses mrc
    JOIN material_revisions mr ON mr.id = mrc.material_revision_id
    WHERE mrc.id = p_material_revision_course_id;

    -- 2. Obtener el material_per_period_ballot_id
    SELECT mppb.id INTO v_period_ballot_id
    FROM material_per_period mpp
    JOIN material_per_period_ballot mppb ON mpp.id = mppb.material_per_period_id
    WHERE mpp.type_material_id = v_type_material_id
      AND mpp.material_id = v_material_id
      AND mppb.start_week = v_start_week
      AND mppb.end_week = v_end_week;

    IF v_period_ballot_id IS NOT NULL THEN
        -- 3. Limpiar url general del balotario
        UPDATE material_per_period_ballot_url
        SET job_url = null,
            job_id = null,
            file_name = null,
            fl_job_process = 'unprocessed',
            number_pages = null,
            updated_by = p_updated_by,
            updated_at = now()
        WHERE material_per_period_ballot_id = v_period_ballot_id
          AND deleted_by IS NULL;

        -- 4. Limpiar la url y resetear páginas/reintentos a nivel del curso específico
        UPDATE material_per_period_course
        SET pages = 0,
            retries = 0,
            url = null,
            job_id = null,
            job_status = 'unprocessed',
            updated_by = p_updated_by,
            updated_at = now()
        WHERE material_per_period_ballot_id = v_period_ballot_id
          AND course_id = v_course_id
          AND deleted_by IS NULL;
    END IF;
END;
$$;


ALTER FUNCTION odiseo.fn_deactive_ballot_per_course_url(p_material_revision_course_id bigint, p_updated_by bigint) OWNER TO postgres;

--
