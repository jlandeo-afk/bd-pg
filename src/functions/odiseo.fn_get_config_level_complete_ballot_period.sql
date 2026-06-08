-- Function: odiseo.fn_get_config_level_complete_ballot_period(bigint, smallint, smallint, smallint)

--

CREATE FUNCTION odiseo.fn_get_config_level_complete_ballot_period(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint) RETURNS TABLE(id bigint, type_material_id bigint, amount_type_mat integer, level_id bigint, level_description character varying, level_name character varying, type_question character varying, week smallint, headquarter_id bigint, course_id bigint, code_course character varying, course character varying, course_position smallint)
    LANGUAGE plpgsql
    AS $$
                DECLARE
                    v_ids_children INT[];
                BEGIN
                    SELECT CASE
                        WHEN EXISTS (SELECT 1 FROM type_material tm WHERE tm.parent_id = p_type_material_id)
                        THEN ARRAY(SELECT tm.id FROM type_material tm WHERE tm.parent_id = p_type_material_id)
                        ELSE ARRAY[p_type_material_id]
                    END INTO v_ids_children;

                    RETURN QUERY
                    WITH tbl_material AS ( -- Se obtiene el ciclo y universidad del material
                        SELECT
                            m.cycle_id,
                            m.university_id
                        FROM material m
                        WHERE m.id = p_material_id
                    ), template_type_material AS (
                        SELECT
                            tm.type_material_template_id
                        FROM type_material tm
                        WHERE tm.id = p_type_material_id
                    ), courses_ordering AS (
                        SELECT
                            cor.course_id,
                            cor.position AS course_position
                        FROM template_type_material_courses_order cor
                        WHERE cor.deleted_at IS NULL
                            AND cor.template_type_material_id IN (SELECT tmt.type_material_template_id FROM template_type_material tmt)
                            AND cor.university_id IS NULL -- Se valida por el parametro university_id nulo como valor por defecto
                    ), get_type_materias AS ( -- Se trae el id de tipo material hijo si los tiene, sino se manda el normal
                        SELECT unnest(v_ids_children) AS type_material_id
                    ), get_type_material_courses_generic AS ( -- Se trae los cursos de tipo material
                        SELECT
                            tmc.type_material_id,
                            tmc.course_id
                        FROM type_material_course tmc
                        WHERE tmc.type_material_id IN (SELECT gtm.type_material_id FROM get_type_materias gtm)
                            AND tmc.amount_question > 0
                            AND tmc.is_generic IS TRUE
                            AND tmc.fl_status = true
                    ), get_type_material_courses_not_generic AS (
                        SELECT DISTINCT
                            tmc.type_material_id,
                            tmc.course_id
                        FROM type_material_course tmc
                        JOIN type_material_detail_template tmdt ON tmc.type_material_id = tmdt.type_material_id
                            AND tmdt.fl_status = true
                        JOIN odiseo.type_material_detail_courses tmdc ON tmc.id = tmdc.type_material_course_id
                            AND tmdt.id = tmdc.type_material_detail_template_id
                            AND tmdc.fl_status = true
                        WHERE tmc.type_material_id IN (SELECT gtm.type_material_id FROM get_type_materias gtm)
                            AND tmdc.amount_question > 0
                            AND tmc.is_generic IS FALSE
                            AND tmc.fl_status = true
                            AND tmdt.week BETWEEN p_start_week AND p_end_week
                    ), get_type_material_courses AS (
                        SELECT * FROM get_type_material_courses_generic
                        UNION ALL
                        SELECT * FROM get_type_material_courses_not_generic
                    ), get_type_material_week AS ( -- Se trae las semanas del tipo material
                        SELECT
                            tmdt.week
                        FROM type_material_detail_template tmdt
                        WHERE tmdt.type_material_id = p_type_material_id
                            AND tmdt.week BETWEEN p_start_week AND p_end_week
                            AND tmdt.fl_status = true
                        ORDER BY tmdt.week ASC
                    ), get_courses_not_register_ballot AS (
                        SELECT DISTINCT
                            gtmc.course_id
                        FROM get_type_material_courses gtmc
                        LEFT JOIN (
                            SELECT DISTINCT
                                mdbq.course_id
                            FROM detail_week_type_mat dwtm
                            JOIN material_ballot_question mdbq
                                ON dwtm.id = mdbq.week_type_material_id
                            WHERE mdbq.material_id = p_material_id
                                AND dwtm.week BETWEEN p_start_week AND p_end_week
                                AND dwtm.type_material_id IN (SELECT gtm.type_material_id FROM get_type_materias gtm)
                                AND mdbq.fl_status = true
                                AND mdbq.type_text_id IS NULL
                        ) AS existing_courses
                        ON gtmc.course_id = existing_courses.course_id
                        WHERE existing_courses.course_id IS NULL
                    )
                    SELECT
                        dlsw.id,
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
                        c.name AS course,
                        ccor.course_position
                    FROM detail_level_syllabus_weeks dlsw
                    INNER JOIN level_syllabus_weeks lsw ON dlsw.level_syllabus_weeks_id = lsw.id
                        AND lsw.fl_status = true
                    INNER JOIN level_syllabus ls ON lsw.level_syllabus_id = ls.id
                    INNER JOIN course c ON ls.course_id = c.id
                    INNER JOIN level l ON dlsw.level_id = l.id
                    LEFT JOIN courses_ordering ccor ON ls.course_id = ccor.course_id
                    WHERE 1 = 1
                        AND dlsw.fl_status = true
                        AND ls.fl_status = true
                        AND dlsw.type_material_id IN (SELECT gtm.type_material_id FROM get_type_materias gtm)
                        AND ls.cycle_id IN (SELECT tm.cycle_id FROM tbl_material tm)
                        AND ls.university_id IN (SELECT tm.university_id FROM tbl_material tm)
                        AND ls.course_id IN (SELECT gcnrb.course_id FROM get_courses_not_register_ballot gcnrb)
                        AND lsw.week IN (SELECT gtmw.week FROM get_type_material_week gtmw)
                    ORDER BY ccor.course_position ASC, ls.course_id ASC, dlsw.level_id ASC, dlsw.type_question ASC, lsw.week ASC;
                END;
                $$;


ALTER FUNCTION odiseo.fn_get_config_level_complete_ballot_period(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint) OWNER TO postgres;

--
