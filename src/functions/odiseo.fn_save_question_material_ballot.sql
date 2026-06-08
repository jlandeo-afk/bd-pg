-- Function: odiseo.fn_save_question_material_ballot(smallint, bigint, smallint, smallint, smallint, bigint, smallint, bigint, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_save_question_material_ballot(p_week smallint, p_question_id bigint, p_subtopic_id smallint, p_level_id smallint, p_position smallint, p_week_type_material_id bigint, p_type_material_id smallint, p_material_id bigint, p_material_distribution_id bigint, p_created_by bigint) RETURNS TABLE(id bigint, material_id bigint, week smallint, type_material_id smallint, week_type_material_id bigint, course_id smallint, code_course character varying, course character varying, "position" smallint, position_initial smallint, subtopic_id smallint, code_subtopic character varying, subtopic character varying, topic_id smallint, code_topic character varying, topic character varying, level_id bigint, level_description character varying, level_name character varying, usage_level_id bigint, question_id bigint, type character varying, usage_status boolean)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_cycle_id bigint;
    v_cycle_start_date date;
    v_university_id smallint;
    v_headquarters_id bigint;
    v_course_id smallint;
    v_topic_id smallint;
    v_type varchar;
    v_history jsonb;
    v_question_history_id bigint;
    v_parent_type_material_id smallint;
BEGIN
    -- Obtener ciclo y universidad del material
    SELECT
        m.cycle_id,
        c.start_date,
        m.university_id,
        m.headquarte_id INTO v_cycle_id,
        v_cycle_start_date,
        v_university_id,
        v_headquarters_id
    FROM
        material m
            INNER JOIN CYCLE c ON m.cycle_id = c.id
        WHERE
            m.id = p_material_id
        LIMIT 1;
    -- Obtener los campos de pregunta
    SELECT
        fqvm.course_id,
        fqvm.topic_id,
        fqvm.type,
        fqvm.history INTO v_course_id,
        v_topic_id,
        v_type,
        v_history
    FROM
        fn_question_verified_material(p_material_id, FALSE) fqvm
WHERE
    fqvm.id = p_question_id
        AND fqvm.subtopic_id = p_subtopic_id
        AND fqvm.level_id = p_level_id
    LIMIT 1;
    -- Traer o registrar historial
    SELECT
        qhc.id INTO v_question_history_id
    FROM
        question_history_cycle qhc
    WHERE
        qhc.question_id = p_question_id
        AND qhc.cycle_id = v_cycle_id
        AND qhc.university_id = v_university_id
        AND qhc.headquarters_id = v_headquarters_id
        AND qhc.fl_status = TRUE
    LIMIT 1;
    -- Si no hay historial se registra
    IF v_question_history_id IS NULL THEN
        INSERT INTO question_history_cycle AS qhc(question_id, cycle_id, university_id, headquarters_id, created_by, created_at, automatic)
            VALUES (p_question_id, v_cycle_id, v_university_id, v_headquarters_id, p_created_by, now(), FALSE)
        RETURNING
            qhc.id INTO v_question_history_id;
    END IF;
    -- Insertar pregunta de balotario & Actualizar distribución (UNIFICADO)
    IF p_material_distribution_id IS NOT NULL THEN
        UPDATE
            odiseo.material_ballot_question mdbq
        SET
            course_id = v_course_id,
            topic_id = v_topic_id,
            subtopic_id = p_subtopic_id,
            level_id = p_level_id,
            usage_level_id = p_level_id,
            question_id = p_question_id,
            question_history_id = v_question_history_id,
            usage_status = FALSE,
            added_in_completion = TRUE,
            fl_is_manual = TRUE,
            state = 'MANUAL_COMPLETED',
            type = v_type,
            updated_by = p_created_by,
            updated_at = NOW()
        WHERE
            mdbq.id = p_material_distribution_id;
    ELSE
        INSERT INTO odiseo.material_ballot_question(
            week_type_material_id, course_id, topic_id, subtopic_id, level_id,
            type, question_id, question_history_id, position, fl_is_manual, state,
            added_in_completion, created_by, created_at
        )
        VALUES (
            p_week_type_material_id, v_course_id, v_topic_id, p_subtopic_id, p_level_id,
            v_type, p_question_id, v_question_history_id, p_position, TRUE, 'MANUAL_COMPLETED',
            TRUE, p_created_by, NOW()
        );
    END IF;
    -- Quitar pregunta de la distribución si está en el balotario
    UPDATE
        detail_week_type_mat dwtmupd
    SET
        url_solution = NULL,
        url_without_solution = NULL,
        fl_process_status = 1,
        fl_process_status_without = 1,
        url_zip_class_mat = NULL,
        fl_process_class_mat = 1,
        fl_process_quality = 1,
        url_quality = NULL,
        fl_process_without_quality = 1,
        url_without_quality = NULL,
        updated_by = p_created_by,
        updated_at = now()
    WHERE
        dwtmupd.id =(
            SELECT
                dwtmupdcp.id
            FROM
                detail_week_type_mat dwtmupdcp
            WHERE
                dwtmupdcp.material_id = p_material_id
                AND dwtmupdcp.week = p_week
                AND dwtmupdcp.type_material_id = p_type_material_id)
    RETURNING
        dwtmupd.parent_type_material_id INTO v_parent_type_material_id;

    RETURN QUERY
    SELECT
        fmdbq.id,
        fmdbq.material_id,
        fmdbq.week,
        fmdbq.type_material_id,
        fmdbq.week_type_material_id,
        fmdbq.course_id,
        fmdbq.code_course,
        fmdbq.course,
        fmdbq.position,
        fmdbq.position_initial,
        fmdbq.subtopic_id,
        fmdbq.code_subtopic,
        fmdbq.subtopic,
        fmdbq.topic_id,
        fmdbq.code_topic,
        fmdbq.topic,
        fmdbq.level_id,
        fmdbq.level_description,
        fmdbq.level_name,
        fmdbq.usage_level_id,
        fmdbq.question_id,
        fmdbq.type,
        fmdbq.usage_status
    FROM
        fn_material_ballot_question(p_material_id, p_week, p_type_material_id, p_week_type_material_id) AS fmdbq;
END;
$$;


ALTER FUNCTION odiseo.fn_save_question_material_ballot(p_week smallint, p_question_id bigint, p_subtopic_id smallint, p_level_id smallint, p_position smallint, p_week_type_material_id bigint, p_type_material_id smallint, p_material_id bigint, p_material_distribution_id bigint, p_created_by bigint) OWNER TO postgres;

--
