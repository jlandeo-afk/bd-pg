-- Function: odiseo.fn_deactive_parent_questions_exams(bigint, bigint, smallint, smallint, jsonb, bigint)

--

CREATE FUNCTION odiseo.fn_deactive_parent_questions_exams(p_material_id bigint, p_type_material_id bigint, p_course_id smallint, p_week smallint, p_area_ids jsonb, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
        WITH material_exam_area_weeks_ids AS (
            SELECT
                meaw.id AS material_exam_area_week_id
            FROM material_exam_area_week meaw
            JOIN detail_week_type_mat dwtm ON meaw.week_type_material_id = dwtm.id
            WHERE 1 = 1
              AND dwtm.type_material_id = p_type_material_id
              AND dwtm.fl_status IS TRUE
              AND meaw.fl_status IS TRUE
              AND dwtm.material_id = p_material_id
              AND dwtm.week = p_week
              AND meaw.area_id IN ( SELECT JSONB_ARRAY_ELEMENTS_TEXT(p_area_ids)::SMALLINT )
        ), deactive_previous_parents AS (
            UPDATE material_exam_parent_question mpp
            SET
                deleted_at = NOW(),
                deleted_by = p_updated_by
            WHERE 1 =  1
              AND material_exam_area_week_id IN ( SELECT material_exam_area_week_id w FROM material_exam_area_weeks_ids w )
              AND course_id = p_course_id
        )
        UPDATE question_history_usage_exam_parent_question qhuepq
        SET
            updated_at = NOW(),
            updated_by = p_updated_by
        WHERE 1 = 1
          AND updated_at IS NULL
          AND course_id = p_course_id
          AND material_exam_area_week_id IN ( SELECT material_exam_area_week_id w FROM material_exam_area_weeks_ids w );
    END;
    $$;


ALTER FUNCTION odiseo.fn_deactive_parent_questions_exams(p_material_id bigint, p_type_material_id bigint, p_course_id smallint, p_week smallint, p_area_ids jsonb, p_updated_by bigint) OWNER TO postgres;

--
