-- Function: materials.fn_process_separated_material_week(bigint, smallint, jsonb, bigint[], smallint, boolean, boolean, bigint)

--

CREATE FUNCTION materials.fn_process_separated_material_week(p_material_id bigint, p_type_material_id smallint, p_type_material_jsonb jsonb, p_week_type_material_ids bigint[], p_week smallint, p_fl_solution boolean, p_fl_quality boolean, p_created_by bigint) RETURNS TABLE(id bigint, material_id bigint, type_material_template_id bigint, type_material_template character varying, type_material_id smallint, type_material character varying, week_type_material_ids character varying, week smallint, fl_solution boolean, fl_quality boolean, course_id smallint, code_course character varying, name_course character varying, fl_process_status smallint, url_material_class character varying, job_id character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_separated_material_week_id BIGINT;
    v_course_id SMALLINT;
    v_count_course BIGINT;
BEGIN
    FOR v_course_id IN
        SELECT tmc.course_id FROM type_material_course tmc
        WHERE tmc.type_material_id = ANY(SELECT jsonb_array_elements_text(p_type_material_jsonb)::BIGINT)
        AND tmc.fl_status = true
        AND (tmc.amount_question > 0 OR tmc.amount_text > 0)
        GROUP BY tmc.course_id
        ORDER BY tmc.course_id
    LOOP
        -- Se busca si hay registro de los cursos ya creados o no
        SELECT smw.id INTO v_separated_material_week_id FROM separated_material_week smw
        WHERE smw.material_id = p_material_id AND smw.type_material_id = p_type_material_id
        AND smw.fl_solution = p_fl_solution AND smw.fl_quality = p_fl_quality
        AND smw.week = p_week AND smw.course_id = v_course_id AND smw.fl_status = true LIMIT 1;

        -- Si busca si hay preguntas registradas con el curso
        -- Elegir preguntas de balotario
        SELECT COUNT(mbq.*) INTO v_count_course FROM material_ballot_question mbq
        INNER JOIN detail_week_type_mat dwtm ON mbq.week_type_material_id = dwtm.id
        WHERE mbq.fl_status = true
        AND dwtm.fl_status = true
        AND dwtm.material_id = p_material_id
        AND dwtm.type_material_id = ANY(SELECT jsonb_array_elements_text(p_type_material_jsonb)::BIGINT)
        AND dwtm.week = p_week
        AND mbq.course_id = v_course_id;

        IF v_separated_material_week_id IS NULL THEN
            IF v_count_course > 0 THEN
                INSERT INTO separated_material_week (material_id, type_material_id, week, fl_solution, fl_quality, week_type_material_ids, course_id, created_by, created_at)
                VALUES (p_material_id, p_type_material_id, p_week, p_fl_solution, p_fl_quality, p_week_type_material_ids, v_course_id, p_created_by, NOW());
            END IF;
        ELSE
            IF v_count_course > 0 THEN
                UPDATE separated_material_week smw
                SET fl_process_status = 1, url_material = null, job_id = null, week_type_material_ids = p_week_type_material_ids,
                    updated_by = p_created_by, updated_at = NOW()
                WHERE smw.material_id = p_material_id AND smw.type_material_id = p_type_material_id
                AND smw.week = p_week AND smw.fl_solution = p_fl_solution AND smw.fl_quality = p_fl_quality
                AND smw.course_id = v_course_id AND smw.fl_status = true;
            ELSE
                UPDATE separated_material_week smw
                SET fl_status = false, deleted_by = p_created_by, deleted_at = NOW()
                WHERE smw.material_id = p_material_id AND smw.type_material_id = p_type_material_id
                AND smw.week = p_week AND smw.fl_solution = p_fl_solution AND smw.fl_quality = p_fl_quality
                AND smw.course_id = v_course_id AND smw.fl_status = true;
            END IF;
        END IF;
    END LOOP;

    RETURN QUERY
    SELECT
        smw.id,
        smw.material_id,
        tmt.id as type_material_template_id,
        tmt.name as type_material_template,
        smw.type_material_id,
        tm.description as type_material,
        smw.week_type_material_ids,
        smw.week,
        smw.fl_solution,
        smw.fl_quality,
        smw.course_id,
        cou.code AS code_course,
        cou.name AS name_course,
        smw.fl_process_status,
        smw.url_material,
        smw.job_id
    FROM separated_material_week smw
    INNER JOIN material m ON smw.material_id = m.id
    INNER JOIN cycle c ON m.cycle_id = c.id
    INNER JOIN course cou ON smw.course_id = cou.id
    INNER JOIN type_material tm ON smw.type_material_id = tm.id
    INNER JOIN type_material_template tmt ON tmt.id = tm.type_material_template_id
    WHERE smw.material_id = p_material_id
    AND smw.type_material_id = p_type_material_id
    AND smw.week = p_week
    AND smw.fl_solution = p_fl_solution
    AND smw.fl_quality = p_fl_quality
    AND smw.fl_status = true
    ORDER BY smw.course_id;
END;
$$;


ALTER FUNCTION materials.fn_process_separated_material_week(p_material_id bigint, p_type_material_id smallint, p_type_material_jsonb jsonb, p_week_type_material_ids bigint[], p_week smallint, p_fl_solution boolean, p_fl_quality boolean, p_created_by bigint) OWNER TO postgres;

--
