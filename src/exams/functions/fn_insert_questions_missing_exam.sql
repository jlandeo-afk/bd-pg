-- Function: exams.fn_insert_questions_missing_exam(jsonb)

--

CREATE FUNCTION exams.fn_insert_questions_missing_exam(p_missing_exam jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN
            WITH get_missing_question AS (
                SELECT
                    (me->>'exam_area_id')::SMALLINT AS exam_area_id,
                    (me->>'detail_week_mat')::BIGINT AS detail_week_mat,
                    (me->>'course_id')::BIGINT AS course_id,
                    (me->>'level_id')::BIGINT AS level_id,
                    (me->>'user_id')::BIGINT AS user_id
                FROM jsonb_array_elements(p_missing_exam) AS me
            ), get_material_exam_area_week AS (
                SELECT
                    gmq.*,
                    FALSE::BOOLEAN AS fl_is_manual,
                    NOW() AS created_at,
                    meaw.id AS material_exam_area_week_id
                FROM get_missing_question gmq
                JOIN material_exam_area_week meaw ON gmq.detail_week_mat = meaw.week_type_material_id
                    AND gmq.exam_area_id = meaw.area_id
                    AND meaw.fl_status = true
            )
            INSERT INTO material_exam_question (
                material_exam_area_week_id,
                course_id,
                level_id,
                fl_is_manual,
                created_by,
                created_at
            )
            SELECT
                gmeaw.material_exam_area_week_id,
                gmeaw.course_id,
                gmeaw.level_id,
                gmeaw.fl_is_manual,
                gmeaw.user_id,
                gmeaw.created_at
            FROM get_material_exam_area_week gmeaw;
        END;
        $$;


ALTER FUNCTION exams.fn_insert_questions_missing_exam(p_missing_exam jsonb) OWNER TO postgres;

--
