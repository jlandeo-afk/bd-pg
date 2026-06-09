-- Function: materials.fn_get_type_material_data(smallint, smallint)

--

CREATE FUNCTION materials.fn_get_type_material_data(p_type_material_id smallint, p_exam_area_id smallint) RETURNS TABLE(id smallint, code character varying, description character varying, amount_question integer, cycle_id bigint, fl_exam boolean, type_material_template_id bigint, fl_class_material boolean, type_exam_id bigint, exam_type character varying, type_template_id bigint, type_material_template character varying, total_number_questions integer, area_id smallint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH material_base AS (
        SELECT
            tm.id,
            tm.code,
            tm.description,
            tm.amount_question,
            tm.cycle_id,
            tm.fl_exam,
            tm.type_material_template_id,
            tm.fl_class_material,
            c.type_template_id,
            tmt.type_exam_id,
            tmt.name AS type_material_template,
            te.name AS exam_type
        FROM type_material tm
        LEFT JOIN type_material_template tmt ON tm.type_material_template_id = tmt.id
        LEFT JOIN cycle c ON tm.cycle_id = c.id
        LEFT JOIN type_exams te ON te.id = tmt.type_exam_id
        WHERE tm.id = p_type_material_id
    ), tbl_amount_course_exam_text AS (
        SELECT
            SUM(ttmtca.subquestion_amount)::INTEGER AS amount_question,
            ttmtca.type_material_id,
            ttmtca.exam_area_id
        FROM type_text_material_type_course_area ttmtca
        WHERE ttmtca.type_material_id = p_type_material_id
            AND ttmtca.exam_area_id = p_exam_area_id
            AND ttmtca.deleted_at IS NULL
            AND ttmtca.subquestion_amount > 0
        GROUP BY
            ttmtca.type_material_id,
            ttmtca.exam_area_id
    ), tbl_amount_course_exam AS (
        SELECT
            SUM(tmc.amount_question)::INTEGER AS amount_question, -- <-- Se suma la cantidad de textos a las cantidad de preguntas
            tmc.type_material_id,
            tma.area_id as exam_area_id
        FROM type_material_course tmc
        INNER JOIN type_material_area_courses tmac ON tmc.id = tmac.type_material_course_id
            AND tmac.fl_status = true
        INNER JOIN type_material_area tma ON tmac.type_material_area_id = tma.id
            AND tma.fl_status = TRUE
        WHERE tmc.fl_status = true
            AND tma.area_id = p_exam_area_id
            AND tma.type_material_id = p_type_material_id
            AND tmc.amount_question > 0
        GROUP BY
            tmc.type_material_id,
            tma.area_id
    ), tbl_amount_total AS (
        SELECT tace.*
        FROM tbl_amount_course_exam tace

        UNION ALL

        SELECT tacet.*
        FROM tbl_amount_course_exam_text tacet
    ), tbl_sum_total AS (
        SELECT
            SUM(tat.amount_question)::INTEGER AS total_number_questions,
            tat.type_material_id,
            tat.exam_area_id
        FROM tbl_amount_total tat
        GROUP BY
            tat.type_material_id,
            tat.exam_area_id
    )
    SELECT
        mb.id,
        mb.code,
        mb.description,
        mb.amount_question,
        mb.cycle_id,
        mb.fl_exam,
        mb.type_material_template_id,
        mb.fl_class_material,
        mb.type_exam_id,
        mb.exam_type,
        mb.type_template_id,
        mb.type_material_template,
        CASE
            WHEN p_exam_area_id IS NULL
                THEN mb.amount_question
            ELSE tst.total_number_questions
        END AS total_number_questions,
        tst.exam_area_id AS area_id
    FROM material_base mb
    LEFT JOIN tbl_sum_total tst ON tst.type_material_id = mb.id;
END;
$$;


ALTER FUNCTION materials.fn_get_type_material_data(p_type_material_id smallint, p_exam_area_id smallint) OWNER TO postgres;

--
