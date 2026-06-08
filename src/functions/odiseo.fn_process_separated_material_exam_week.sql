-- Function: odiseo.fn_process_separated_material_exam_week(bigint, smallint, bigint, smallint, smallint, boolean, boolean, bigint)

--

CREATE FUNCTION odiseo.fn_process_separated_material_exam_week(p_material_id bigint, p_type_material_id smallint, p_material_exam_area_week_id bigint, p_exam_area_id smallint, p_week smallint, p_fl_solution boolean, p_fl_quality boolean, p_created_by bigint) RETURNS TABLE(id bigint, material_id bigint, type_material_id smallint, type_material character varying, material_exam_area_week_id smallint, exam_area_id smallint, week smallint, fl_solution boolean, fl_quality boolean, course_id smallint, code_course character varying, name_course character varying, fl_process_status smallint, url_material_class character varying, job_id character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_separated_material_exam_week_id BIGINT;
    v_course_id SMALLINT;
    v_count_course BIGINT;
BEGIN
    FOR v_course_id IN
        SELECT tmc.course_id FROM type_material_course tmc
        WHERE tmc.type_material_id = p_type_material_id
        AND tmc.fl_status = true
        AND tmc.amount_question > 0
        GROUP BY tmc.course_id
        ORDER BY tmc.course_id
    LOOP
        -- Se busca si hay registro de los cursos ya creados o no
        SELECT smew.id INTO v_separated_material_exam_week_id FROM separated_material_exam_week smew
        WHERE smew.material_id = p_material_id AND smew.material_exam_area_week_id = p_material_exam_area_week_id
        AND smew.fl_solution = p_fl_solution AND smew.fl_quality = p_fl_quality
        AND smew.week = p_week AND smew.course_id = v_course_id AND smew.fl_status = true LIMIT 1;

        -- Si busca si hay preguntas registradas con el curso
        -- Elegir preguntas de examen
        SELECT COUNT(meq.*) INTO v_count_course FROM material_exam_question meq
        INNER JOIN material_exam_area_week meaw ON meq.material_exam_area_week_id = meaw.id
        INNER JOIN detail_week_type_mat dwtm ON meaw.week_type_material_id = dwtm.id
        WHERE meq.fl_status = true
        AND meaw.fl_status = true
        AND dwtm.fl_status = true
        AND dwtm.material_id = p_material_id
        AND dwtm.type_material_id = p_type_material_id
        AND meaw.area_id = p_exam_area_id
        AND dwtm.week = p_week
        AND meq.course_id = v_course_id;

        IF v_separated_material_exam_week_id IS NULL THEN
            IF v_count_course > 0 THEN
                INSERT INTO separated_material_exam_week (material_id, material_exam_area_week_id, week, fl_solution, fl_quality, course_id, created_by, created_at)
                VALUES (p_material_id, p_material_exam_area_week_id, p_week, p_fl_solution, p_fl_quality, v_course_id, p_created_by, NOW());
            END IF;
        ELSE
            IF v_count_course > 0 THEN
                UPDATE separated_material_exam_week smew
                SET fl_process_status = 1, url_material = null, job_id = null, updated_by = p_created_by, updated_at = NOW()
                WHERE smew.material_id = p_material_id AND smew.material_exam_area_week_id = p_material_exam_area_week_id
                AND smew.week = p_week AND smew.fl_solution = p_fl_solution AND smew.fl_quality = p_fl_quality
                AND smew.course_id = v_course_id AND smew.fl_status = true;
            ELSE
                UPDATE separated_material_exam_week smew
                SET fl_status = false, deleted_by = p_created_by, deleted_at = NOW()
                WHERE smew.material_id = p_material_id AND smew.material_exam_area_week_id = p_material_exam_area_week_id
                AND smew.week = p_week AND smew.fl_solution = p_fl_solution AND smew.fl_quality = p_fl_quality
                AND smew.course_id = v_course_id AND smew.fl_status = true;
            END IF;
        END IF;
    END LOOP;

    RETURN QUERY
    SELECT
        smw.id,
        smw.material_id,
        dwtm.type_material_id,
        tm.description as type_material,
        smw.material_exam_area_week_id,
        meaw.area_id AS exam_area_id,
        smw.week,
        smw.fl_solution,
        smw.fl_quality,
        smw.course_id,
        cou.code AS code_course,
        cou.name AS name_course,
        smw.fl_process_status,
        smw.url_material,
        smw.job_id
    FROM separated_material_exam_week smw
    INNER JOIN material_exam_area_week meaw ON smw.material_exam_area_week_id = meaw.id
    INNER JOIN detail_week_type_mat dwtm ON meaw.week_type_material_id = dwtm.id
    INNER JOIN material m ON smw.material_id = m.id
    INNER JOIN cycle c ON m.cycle_id = c.id
    INNER JOIN course cou ON smw.course_id = cou.id
    INNER JOIN type_material tm ON dwtm.type_material_id = tm.id
    WHERE dwtm.material_id = p_material_id
    AND smw.material_exam_area_week_id = p_material_exam_area_week_id
    AND smw.week = p_week
    AND smw.fl_solution = p_fl_solution
    AND smw.fl_quality = p_fl_quality
    AND smw.fl_status = true
    AND meaw.fl_status = true
    AND dwtm.fl_status = true
    ORDER BY smw.course_id;
END;
$$;


ALTER FUNCTION odiseo.fn_process_separated_material_exam_week(p_material_id bigint, p_type_material_id smallint, p_material_exam_area_week_id bigint, p_exam_area_id smallint, p_week smallint, p_fl_solution boolean, p_fl_quality boolean, p_created_by bigint) OWNER TO postgres;

--
