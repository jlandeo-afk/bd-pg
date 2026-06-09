-- Function: materials.fn_process_material_class_week(bigint, smallint, smallint, smallint, bigint, bigint)

--

CREATE FUNCTION materials.fn_process_material_class_week(p_material_id bigint, p_type_material_id smallint, p_type_material_template_id smallint, p_week smallint, p_cycle_id bigint, p_created_by bigint) RETURNS TABLE(id bigint, material_id bigint, type_material_id smallint, type_material character varying, week_type_material_ids character varying, week smallint, course_id smallint, code_course character varying, name_course character varying, fl_process_status smallint, url_material_class character varying, job_id character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_type_material_id SMALLINT[];
    v_type_material_validate_id SMALLINT[];
    v_detail_week_type_mat_id BIGINT[];
    v_course_id SMALLINT;
    v_material_class_week_id BIGINT;
    v_count_course BIGINT;
BEGIN
    IF p_type_material_template_id IS NOT NULL THEN
        -- Buscar hijos del tipo material
        SELECT ARRAY(
            SELECT tm.id FROM type_material_bound tmb
            INNER JOIN type_material_template tmt ON tmb.type_material_template_extra_id = tmt.id
            INNER JOIN type_material tm ON tmt.id = tm.type_material_template_id
            WHERE tmb.type_material_template_id = p_type_material_template_id
            AND tm.cycle_id = p_cycle_id
        ) INTO v_type_material_id;
    END IF;

    -- Validar si el tipo de material es un tipo de material padre
    IF array_length(v_type_material_id, 1) IS NULL THEN
        SELECT ARRAY(SELECT tm.id FROM type_material tm WHERE tm.id = p_type_material_id) INTO v_type_material_id;
    END IF;

    -- Traer los materiales validados // Por ahora no hace nada
    SELECT ARRAY(
        SELECT dwtm.type_material_id
        FROM detail_week_type_mat dwtm
        WHERE dwtm.material_id = p_material_id
        AND dwtm.week = p_week
        AND dwtm.type_material_id = ANY(v_type_material_id)
        AND dwtm.fl_status = true
    ) INTO v_type_material_validate_id;

    -- Traer los detalles de la tabla detail_week_type_mat
    SELECT ARRAY(
        SELECT dwtm.id
        FROM detail_week_type_mat dwtm
        WHERE dwtm.material_id = p_material_id
        AND dwtm.week = p_week
        AND dwtm.type_material_id = ANY(v_type_material_id)
        AND dwtm.fl_status = true
    ) INTO v_detail_week_type_mat_id;

    FOR v_course_id IN
        SELECT tmc.course_id FROM type_material_course tmc
        WHERE tmc.type_material_id = ANY(v_type_material_id)
        AND tmc.fl_status = true
        AND tmc.amount_question > 0
        GROUP BY tmc.course_id
        ORDER BY tmc.course_id
    LOOP
        -- Se busca si hay registro de los cursos ya creados o no
        SELECT macw.id INTO v_material_class_week_id FROM material_class_week macw
        WHERE macw.material_id = p_material_id AND macw.type_material_id = p_type_material_id
        AND macw.week = p_week
        AND macw.course_id = v_course_id AND macw.fl_status = true LIMIT 1;

        -- Si busca si hay preguntas registradas con el curso
        SELECT COUNT(mbq.*) INTO v_count_course FROM material_ballot_question mbq
        INNER JOIN detail_week_type_mat dwtm ON mbq.week_type_material_id = dwtm.id
        WHERE mbq.fl_status = true
        AND dwtm.fl_status = true
        AND dwtm.material_id = p_material_id
        AND dwtm.type_material_id = ANY(v_type_material_id)
        AND dwtm.week = p_week
        AND mbq.course_id = v_course_id;

        IF v_material_class_week_id IS NULL THEN
            IF v_count_course > 0 THEN
                INSERT INTO material_class_week (material_id, type_material_id, week_type_material_ids, week, course_id, created_by, created_at)
                VALUES (p_material_id, p_type_material_id, v_detail_week_type_mat_id, p_week, v_course_id, p_created_by, NOW());
            END IF;
        ELSE
            IF v_count_course > 0 THEN
                UPDATE material_class_week maclw
                SET fl_process_status = 1, url_material_class = null, job_id = null, week_type_material_ids = v_detail_week_type_mat_id,
                    updated_by = p_created_by, updated_at = NOW()
                WHERE maclw.material_id = p_material_id AND maclw.type_material_id = p_type_material_id
                AND maclw.week = p_week
                AND maclw.course_id = v_course_id AND maclw.fl_status = true;
            ELSE
                UPDATE material_class_week maclw
                SET fl_status = false, deleted_by = p_created_by, deleted_at = NOW()
                WHERE maclw.material_id = p_material_id AND maclw.type_material_id = p_type_material_id
                AND maclw.week = p_week
                AND maclw.course_id = v_course_id AND maclw.fl_status = true;
            END IF;
        END IF;
    END LOOP;

    RETURN QUERY
    SELECT
        mcw.id,
        mcw.material_id,
        mcw.type_material_id,
        tm.description as type_material,
        mcw.week_type_material_ids,
        mcw.week,
        mcw.course_id,
        cou.code AS code_course,
        cou.name AS name_course,
        mcw.fl_process_status,
        mcw.url_material_class,
        mcw.job_id
    FROM material_class_week mcw
    INNER JOIN material m ON mcw.material_id = m.id
    INNER JOIN cycle c ON m.cycle_id = c.id
    INNER JOIN course cou ON mcw.course_id = cou.id
    INNER JOIN type_material tm ON mcw.type_material_id = tm.id
    WHERE mcw.material_id = p_material_id
    AND mcw.type_material_id = p_type_material_id
    AND mcw.week = p_week
    AND mcw.week_type_material_ids = v_detail_week_type_mat_id::VARCHAR
    AND mcw.fl_status = true
    ORDER BY mcw.course_id;
END;
$$;


ALTER FUNCTION materials.fn_process_material_class_week(p_material_id bigint, p_type_material_id smallint, p_type_material_template_id smallint, p_week smallint, p_cycle_id bigint, p_created_by bigint) OWNER TO postgres;

--
