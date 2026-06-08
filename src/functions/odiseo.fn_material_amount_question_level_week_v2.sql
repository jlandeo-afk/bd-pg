-- Function: odiseo.fn_material_amount_question_level_week_v2(bigint, smallint, smallint, jsonb)

--

CREATE FUNCTION odiseo.fn_material_amount_question_level_week_v2(p_material_id bigint, p_type_material_id smallint, p_week smallint, p_courses jsonb) RETURNS TABLE(type_material_id bigint, amount_type_mat integer, level_id bigint, level_description character varying, level_name character varying, type_question character varying, week smallint, headquarter_id bigint, course_id bigint, code_course character varying, course character varying)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_cycle_id BIGINT;
            v_university_id SMALLINT;
            v_headquarte_id BIGINT;
        BEGIN
            -- Obtener ciclo y universidad del material mandado
            SELECT m.cycle_id, m.university_id, m.headquarte_id INTO v_cycle_id, v_university_id, v_headquarte_id FROM odiseo.material m WHERE m.id = p_material_id LIMIT 1;

            RETURN QUERY
            SELECT
                dlsw.type_material_id,
                dlsw.number_questions AS amount_type_mat,
                dlsw.level_id,
                l.description AS level_description,
                l.name AS level_name,
                dlsw.type_question,
                lsw.week,
                ls.headquarter_id,
                ls.course_id,
                c.code AS code_course,
                c.name AS course
            FROM odiseo.detail_level_syllabus_weeks dlsw
            INNER JOIN odiseo.level_syllabus_weeks lsw
                ON dlsw.level_syllabus_weeks_id = lsw.id AND lsw.fl_status = true
            INNER JOIN odiseo.level_syllabus ls
                ON lsw.level_syllabus_id = ls.id
            INNER JOIN odiseo.course c
                ON ls.course_id = c.id
            INNER JOIN odiseo.level l
                ON dlsw.level_id = l.id
            WHERE dlsw.fl_status = true
                AND ls.fl_status = true
                AND dlsw.type_material_id = p_type_material_id
                AND ls.headquarter_id = v_headquarte_id
                AND ls.cycle_id = v_cycle_id
                AND ls.university_id = v_university_id
                AND ls.course_id IN (SELECT jsonb_array_elements_text(p_courses)::smallint)
                AND lsw.week = p_week
            ORDER BY ls.course_id ASC, dlsw.level_id ASC, dlsw.type_question ASC;
        END;
        $$;


ALTER FUNCTION odiseo.fn_material_amount_question_level_week_v2(p_material_id bigint, p_type_material_id smallint, p_week smallint, p_courses jsonb) OWNER TO postgres;

--
