-- Function: questions.fn_deactive_and_retrieve_questions_for_registering(bigint, boolean, smallint, smallint, smallint, boolean, jsonb, bigint)

--

CREATE FUNCTION questions.fn_deactive_and_retrieve_questions_for_registering(p_material_id bigint, p_fl_validate_code boolean, p_type_material_id smallint, p_start_week smallint, p_end_week smallint, p_fetch_all_courses boolean, p_courses jsonb, p_updated_by bigint) RETURNS TABLE(id bigint, code character varying, course_id smallint, topic_id smallint, level_id smallint, level smallint, type character varying, status character varying, subtopic_id integer, frequent_subtopic boolean, cycle_id integer, week smallint, type_material_id smallint, history jsonb)
    LANGUAGE plpgsql
    AS $$
            BEGIN
            WITH type_materials AS (
                SELECT CASE
                    WHEN EXISTS (SELECT 1 FROM type_material tm WHERE tm.parent_id = p_type_material_id)
                    THEN ARRAY(SELECT tm.id FROM type_material tm WHERE tm.parent_id = p_type_material_id)
                    ELSE ARRAY[p_type_material_id]
                END v_ids_children
            ), get_type_materias AS ( -- Se trae el id de tipo material hijo si los tiene, sino se manda el normal
                SELECT unnest(tm.v_ids_children) AS type_material_id FROM type_materials tm
            ), get_detail_week_type_ids AS (
                SELECT
                    mt.id AS detail_week_type_mat_id
                FROM academic.detail_week_type_mat mt
                WHERE material_id = p_material_id
                AND mt.week BETWEEN p_start_week AND p_end_week
                AND mt.type_material_id IN (SELECT gtm.type_material_id FROM get_type_materias gtm)
            ),deactive_material_ballot_distributions AS (
                    UPDATE material_ballot_question mdbq
                        SET fl_status = FALSE,
                            deleted_by = p_updated_by,
                            deleted_at = NOW()
                    WHERE mdbq.week_type_material_id IN (SELECT detail_week_type_mat_id FROM get_detail_week_type_ids )
                        AND (
                            p_fetch_all_courses = TRUE
                            OR mdbq.course_id = ANY(
                                SELECT value::SMALLINT FROM jsonb_array_elements(p_courses) value
                            )
                        )
                ), deactive_material_ballot_questions AS (
                    UPDATE material_ballot_question mbq
                        SET fl_status = FALSE,
                            deleted_by = p_updated_by,
                            deleted_at = NOW()
                    WHERE mbq.week_type_material_id IN (SELECT detail_week_type_mat_id FROM get_detail_week_type_ids )
                        AND (
                            p_fetch_all_courses = TRUE
                            OR mbq.course_id = ANY(
                                SELECT value::SMALLINT FROM jsonb_array_elements(p_courses) value
                            )
                        )
                    RETURNING mbq.question_history_id
                ) UPDATE question_history_cycle qhc
                    SET
                        fl_status = FALSE,
                        deleted_by = p_updated_by,
                        deleted_at = NOW()
                    WHERE 1 = 1
                    AND qhc.id IN ( SELECT question_history_id FROM deactive_material_ballot_questions )
                    AND NOT EXISTS(
                        SELECT 1 FROM material_ballot_question mqq
                        WHERE 1 = 1
                        AND mqq.fl_status IS TRUE
                        AND mqq.question_history_id = qhc.id
                        AND ( qhc.id NOT IN ( SELECT question_history_id FROM deactive_material_ballot_questions ) )
                    )
                    AND NOT EXISTS(
                        SELECT 1 FROM material_exam_question meq
                        WHERE 1 = 1
                        AND meq.fl_status IS TRUE
                        AND meq.question_history_id = qhc.id
                        AND ( qhc.id NOT IN ( SELECT question_history_id FROM deactive_material_ballot_questions ) )
                    );

                RETURN QUERY
                SELECT
                    *
                FROM fn_get_questions_register_ballot(
                    p_material_id,
                    p_fl_validate_code,
                    p_type_material_id,
                    p_start_week,
                    p_end_week
                );
            END;
            $$;


ALTER FUNCTION questions.fn_deactive_and_retrieve_questions_for_registering(p_material_id bigint, p_fl_validate_code boolean, p_type_material_id smallint, p_start_week smallint, p_end_week smallint, p_fetch_all_courses boolean, p_courses jsonb, p_updated_by bigint) OWNER TO postgres;

--
