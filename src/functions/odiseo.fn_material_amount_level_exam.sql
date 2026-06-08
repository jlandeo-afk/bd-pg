-- Function: odiseo.fn_material_amount_level_exam(bigint, smallint, jsonb)

--

CREATE FUNCTION odiseo.fn_material_amount_level_exam(p_material_id bigint, p_type_material_id smallint, p_courses jsonb) RETURNS TABLE(id smallint, type_material_id bigint, exam_area_id bigint, exam_area character varying, amount_type_mat integer, level_id bigint, level_description character varying, level_name character varying, course_id bigint, code_course character varying, course character varying, amount_type_d integer)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_cycle_id BIGINT;
            v_university_id SMALLINT;
            v_exam_area_id SMALLINT;
            v_exam_areas SMALLINT[] := ARRAY[]::SMALLINT[];
        BEGIN
            -- Obtener ciclo y universidad del material mandado
            SELECT m.cycle_id, m.university_id INTO v_cycle_id, v_university_id FROM material m WHERE m.id = p_material_id LIMIT 1;

            -- Obtener areas del tipo material
            FOR v_exam_area_id IN
                SELECT tma.area_id FROM type_material_area tma WHERE tma.type_material_id = p_type_material_id AND tma.fl_status = true
            LOOP
                v_exam_areas := array_append(v_exam_areas, v_exam_area_id);
            END LOOP;


            RETURN QUERY
            SELECT
                cacl.id,
                emc.type_material_id,
                cac.exam_area_id,
                ea.description AS exam_area,
                cacl.amount_question AS amount_type_mat,
                cacl.level_id,
                l.description AS level_description,
                l.name AS level_name,
                cac.course_id,
                c.code AS code_course,
                c.name AS course,
                cac.amount_type_d
            FROM exam_material_config_area_course_levels cacl
            INNER JOIN exam_material_config_area_courses cac ON cacl.exam_material_config_area_course_id = cac.id AND cac.fl_status = true
            INNER JOIN exam_material_configurations emc ON cac.exam_material_config_id = emc.id AND emc.fl_status = true
            INNER JOIN course c ON cac.course_id = c.id
            INNER JOIN level l ON cacl.level_id = l.id
            INNER JOIN exam_area ea ON cac.exam_area_id = ea.id
            WHERE emc.type_material_id = p_type_material_id
            AND cacl.fl_status = true
            AND emc.cycle_id = v_cycle_id
            AND cac.course_id IN (SELECT jsonb_array_elements_text(p_courses)::BIGINT)
            AND cac.exam_area_id = ANY(v_exam_areas)
            ORDER BY cac.exam_area_id ASC, cac.course_id ASC, cacl.level_id ASC;
        END;
        $$;


ALTER FUNCTION odiseo.fn_material_amount_level_exam(p_material_id bigint, p_type_material_id smallint, p_courses jsonb) OWNER TO postgres;

--
