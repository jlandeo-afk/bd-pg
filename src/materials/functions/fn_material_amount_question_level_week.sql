-- Function: materials.fn_material_amount_question_level_week(bigint, smallint, smallint, jsonb)

--

CREATE FUNCTION materials.fn_material_amount_question_level_week(p_material_id bigint, p_type_material_id smallint, p_week smallint, p_courses jsonb) RETURNS TABLE(num bigint, type_material_id bigint, amount_type_mat integer, level_id bigint, level_description character varying, level_name character varying, type_question character varying, week smallint, headquarter_id bigint, course_id bigint, code_course character varying, course character varying)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_cycle_id BIGINT;
            v_university_id SMALLINT;
            v_headquarte_id BIGINT;
        BEGIN
            -- Obtener ciclo y universidad del material mandado
            SELECT m.cycle_id, m.university_id, m.headquarte_id INTO v_cycle_id, v_university_id, v_headquarte_id FROM materials.material m WHERE m.id = p_material_id LIMIT 1;

            RETURN QUERY
            SELECT
                ROW_NUMBER() OVER (PARTITION BY subquery.amount_type_mat) AS num,
                subquery.type_material_id,
                subquery.amount_type_mat,
                subquery.level_id,
                subquery.level_description,
                subquery.level_name,
                subquery.type_question,
                subquery.week,
                subquery.headquarter_id,
                subquery.course_id,
                subquery.code_course,
                subquery.course
            FROM (
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
                FROM academic.detail_level_syllabus_weeks dlsw
                INNER JOIN academic.level_syllabus_weeks lsw
                    ON dlsw.level_syllabus_weeks_id = lsw.id AND lsw.fl_status = true
                INNER JOIN academic.level_syllabus ls
                    ON lsw.level_syllabus_id = ls.id
                INNER JOIN academic.course c
                    ON ls.course_id = c.id
                INNER JOIN academic.level l
                    ON dlsw.level_id = l.id
                WHERE dlsw.fl_status = true
                    AND ls.fl_status = true
                    AND dlsw.type_material_id = p_type_material_id
                    AND ls.headquarter_id = v_headquarte_id
                    AND ls.cycle_id = v_cycle_id
                    AND ls.university_id = v_university_id
                    AND ls.course_id IN (SELECT jsonb_array_elements_text(p_courses)::smallint)
                    AND lsw.week = p_week
                    AND dlsw.number_questions > 0
                    AND dlsw.number_questions = 1 -- Solo las filas originales con number_questions = 1
                UNION ALL
                SELECT
                    dlsw.type_material_id,
                    1 AS amount_type_mat, -- Replicamos cada fila con un amount_type_mat de 1
                    dlsw.level_id,
                    l.description AS level_description,
                    l.name AS level_name,
                    dlsw.type_question,
                    lsw.week,
                    ls.headquarter_id,
                    ls.course_id,
                    c.code AS code_course,
                    c.name AS course
                FROM academic.detail_level_syllabus_weeks dlsw
                INNER JOIN academic.level_syllabus_weeks lsw
                    ON dlsw.level_syllabus_weeks_id = lsw.id AND lsw.fl_status = true
                INNER JOIN academic.level_syllabus ls
                    ON lsw.level_syllabus_id = ls.id
                INNER JOIN academic.course c
                    ON ls.course_id = c.id
                INNER JOIN academic.level l
                    ON dlsw.level_id = l.id
                CROSS JOIN generate_series(0, dlsw.number_questions - 1) AS gs -- Generamos series para replicar filas
                WHERE dlsw.fl_status = true
                    AND ls.fl_status = true
                    AND dlsw.type_material_id = p_type_material_id
                    AND ls.headquarter_id = v_headquarte_id
                    AND ls.cycle_id = v_cycle_id
                    AND ls.university_id = v_university_id
                    AND ls.course_id IN (SELECT jsonb_array_elements_text(p_courses)::smallint)
                    AND lsw.week = p_week
                    AND dlsw.number_questions > 1 -- Solo replicamos filas con number_questions > 1
            ) AS subquery
            ORDER BY subquery.course_id ASC, subquery.level_id ASC, subquery.type_question ASC;
        END;
        $$;


ALTER FUNCTION materials.fn_material_amount_question_level_week(p_material_id bigint, p_type_material_id smallint, p_week smallint, p_courses jsonb) OWNER TO postgres;

--
