-- Function: odiseo.fn_remove_question_all_areas_from_material_exam(bigint, bigint, smallint, smallint, bigint)

--

CREATE FUNCTION odiseo.fn_remove_question_all_areas_from_material_exam(p_question_id bigint, p_material_id bigint, p_type_material_id smallint, p_week smallint, p_updated_by bigint) RETURNS TABLE(id bigint, question_id bigint, question_history_id bigint, type_material_id smallint, type_material character varying, week smallint, course_id smallint, code_course character varying, course character varying, topic_id smallint, code_topic character varying, topic character varying, subtopic_id smallint, code_subtopic character varying, subtopic character varying, level_id bigint, level_description character varying, level_name character varying, area_id smallint, exam_area character varying, data_incomplete_questions character varying, material_exam_area_week_id bigint, week_type_material_id bigint, type character varying)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        WITH context_material AS (
            SELECT
                meaw.id as material_exam_area_week_id,
                meaw.week_type_material_id,
                meaw.area_id
            FROM detail_week_type_mat dwtm
            JOIN material_exam_area_week meaw ON dwtm.id = meaw.week_type_material_id
            WHERE dwtm.material_id = p_material_id
                AND dwtm.type_material_id = p_type_material_id
                AND dwtm.week = p_week
                AND meaw.fl_status = TRUE
        ), week_type_material AS (
            SELECT
                cm.week_type_material_id
            FROM context_material cm
        ), all_occurrences_to_delete AS (
            SELECT
                meq.id,
                meq.question_id,
                meq.question_history_id
            FROM material_exam_question meq
            JOIN material_exam_area_week meaw ON meq.material_exam_area_week_id = meaw.id
            WHERE meq.fl_status = TRUE
                AND meq.question_id = p_question_id
                AND meaw.week_type_material_id IN (SELECT cm.week_type_material_id FROM context_material cm)
        ), get_questions_deleted AS (
            SELECT
                meq.id,
                meq.question_id,
                meq.question_history_id,
                dwtm.type_material_id,
                tm.description AS type_material,
                dwtm.week,
                meq.course_id,
                c.code AS code_course,
                c.name AS course,
                meq.topic_id,
                t.code AS code_topic,
                t.name AS topic,
                meq.subtopic_id,
                st.code AS code_subtopic,
                st.name AS subtopic,
                meq.level_id,
                l.description AS level_description,
                l.name AS level_name,
                meaw.area_id,
                ea.description AS exam_area,
                meaw.data_incomplete_questions,
                meaw.id AS material_exam_area_week_id,
                dwtm.id AS week_type_material_id,
                meq.type
            FROM material_exam_question meq
            JOIN material_exam_area_week meaw ON meq.material_exam_area_week_id = meaw.id
            JOIN detail_week_type_mat dwtm ON meaw.week_type_material_id = dwtm.id
            JOIN exam_area ea ON meaw.area_id = ea.id
            JOIN type_material tm ON dwtm.type_material_id = tm.id
            JOIN course c ON meq.course_id = c.id
            LEFT JOIN topic t ON meq.topic_id = t.id
            LEFT JOIN subtopic st ON meq.subtopic_id = st.id
            LEFT JOIN level l ON meq.level_id = l.id
            WHERE meq.fl_status = TRUE
                AND meq.question_id = p_question_id
                AND meaw.week_type_material_id IN (SELECT cm.week_type_material_id FROM context_material cm)
        ), exam_update_result AS (
            UPDATE material_exam_question meq
            SET
                topic_id = null,
                subtopic_id = null,
                question_id = null,
                question_history_id = null,
                fl_is_manual = true,
                type = null,
                updated_by = p_updated_by,
                updated_at = now()
            FROM all_occurrences_to_delete aod
            WHERE meq.id = aod.id
            RETURNING
                meq.id, meq.question_id, meq.question_history_id,
                meq.material_exam_area_week_id, meq.course_id,
                meq.subtopic_id, meq.topic_id, meq.level_id
        ), update_history AS (
            UPDATE question_history_cycle qhc
            SET
                fl_status = FALSE,
                deleted_by = p_updated_by,
                deleted_at = NOW()
            WHERE qhc.id IN (SELECT actd.question_history_id FROM all_occurrences_to_delete actd)
            AND NOT EXISTS (
                SELECT 1 FROM material_ballot_question mbq
                WHERE mbq.question_history_id = qhc.id AND mbq.fl_status = TRUE
            )
            AND NOT EXISTS (
                SELECT 1 FROM material_exam_question meq
                WHERE meq.question_history_id = qhc.id AND meq.fl_status = TRUE
                    AND meq.id NOT IN (SELECT actd.id FROM all_occurrences_to_delete actd)
            )
        )
        SELECT
            gqd.*
        FROM get_questions_deleted gqd;
    END;
    $$;


ALTER FUNCTION odiseo.fn_remove_question_all_areas_from_material_exam(p_question_id bigint, p_material_id bigint, p_type_material_id smallint, p_week smallint, p_updated_by bigint) OWNER TO postgres;

--
