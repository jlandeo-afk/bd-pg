-- Function: odiseo.fn_save_question_material_exam(bigint, bigint, smallint, smallint, smallint, bigint, smallint, smallint, bigint)

--

CREATE FUNCTION odiseo.fn_save_question_material_exam(p_id bigint, p_material_id bigint, p_type_material_id smallint, p_week smallint, p_area_id smallint, p_question_id bigint, p_subtopic_id smallint, p_level_id smallint, p_created_by bigint) RETURNS TABLE(id bigint, question_id bigint, question_history_id bigint, type_material_id smallint, type_material character varying, week smallint, course_id smallint, code_course character varying, course character varying, topic_id smallint, code_topic character varying, topic character varying, subtopic_id smallint, code_subtopic character varying, subtopic character varying, level_id bigint, level_description character varying, level_name character varying, area_id smallint, exam_area character varying, data_incomplete_questions character varying, material_exam_area_week_id bigint, week_type_material_id bigint, type character varying, "position" smallint, fl_is_manual boolean)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        WITH tbl_material AS (
            SELECT
                dwtm.material_id,
                m.cycle_id,
                m.university_id,
                m.headquarte_id,
                dwtm.type_material_id,
                dwtm.week,
                meaw.area_id,
                meaw.id AS material_exam_area_week_id
            FROM material m
            JOIN detail_week_type_mat dwtm ON m.id = dwtm.material_id
            JOIN material_exam_area_week meaw ON dwtm.id = meaw.week_type_material_id
            WHERE dwtm.material_id = p_material_id
                AND dwtm.type_material_id = p_type_material_id
                AND dwtm.week = p_week
                AND dwtm.fl_status = true
                AND meaw.area_id = p_area_id
                AND meaw.fl_status = true
            LIMIT 1
        ), tbl_question_data AS (
            SELECT
                fqvtmw.course_id,
                fqvtmw.topic_id,
                fqvtmw.subtopic_id,
                fqvtmw.level_id,
                fqvtmw.type,
                fqvtmw.history
            FROM tbl_material tm
            CROSS JOIN LATERAL fn_questions_verified_by_type_material_week(
                tm.material_id,
                tm.type_material_id,
                tm.week,
                tm.area_id
            ) fqvtmw
            WHERE fqvtmw.id = p_question_id
                AND fqvtmw.subtopic_id = p_subtopic_id
                AND fqvtmw.level_id = p_level_id
            LIMIT 1
        ), find_history AS (
            SELECT
                qhc.id AS question_history_id
            FROM question_history_cycle qhc, tbl_material tm
            WHERE qhc.question_id = p_question_id
                AND qhc.cycle_id = tm.cycle_id
                AND qhc.university_id = tm.university_id
                AND qhc.headquarters_id = tm.headquarte_id
                AND qhc.fl_status = true
            LIMIT 1
        ), insert_history_if_not_exists AS (
            INSERT INTO question_history_cycle AS qhc (
                question_id,
                cycle_id,
                university_id,
                headquarters_id,
                created_by,
                created_at
            )
            SELECT
                p_question_id,
                tm.cycle_id,
                tm.university_id,
                tm.headquarte_id,
                p_created_by,
                NOW()
            FROM tbl_material tm
            WHERE NOT EXISTS (SELECT 1 FROM find_history)
            RETURNING qhc.id AS question_history_id
        ), history_data AS (
            SELECT fh.question_history_id FROM find_history fh
            UNION ALL
            SELECT ih.question_history_id FROM insert_history_if_not_exists ih
            LIMIT 1
        ), tbl_position_final AS (
            SELECT COALESCE(MAX(meqpos.position), 0) AS position_final
            FROM material_exam_question meqpos
            WHERE meqpos.material_exam_area_week_id IN (SELECT tm.material_exam_area_week_id FROM tbl_material tm)
                AND meqpos.course_id IN (SELECT tqd.course_id FROM tbl_question_data tqd)
                AND meqpos.fl_status = true
        ), update_question_exam AS (
            UPDATE material_exam_question meq
            SET
                course_id = tqd.course_id,
                topic_id = tqd.topic_id,
                subtopic_id = p_subtopic_id,
                level_id = p_level_id,
                type = tqd.type,
                question_id = p_question_id,
                question_history_id = hd.question_history_id,
                position = tpf.position_final + 1,
                fl_is_manual = true,
                updated_by = p_created_by,
                updated_at = NOW()
            FROM tbl_question_data tqd,
                history_data hd,
                tbl_position_final tpf
            WHERE meq.id = p_id
            RETURNING
                meq.id,
                meq.course_id,
                meq.topic_id,
                meq.subtopic_id,
                meq.level_id,
                meq.type,
                meq.question_id,
                meq.question_history_id,
                meq.position,
                meq.fl_is_manual,
                meq.material_exam_area_week_id
        )
        SELECT
            uqe.id,
            uqe.question_id,
            uqe.question_history_id,
            dwtm.type_material_id,
            tm.description AS type_material,
            dwtm.week,
            uqe.course_id,
            c.code AS code_course,
            c.name AS course,
            uqe.topic_id,
            t.code AS code_topic,
            t.name AS topic,
            uqe.subtopic_id,
            st.code AS code_subtopic,
            st.name AS subtopic,
            uqe.level_id,
            l.description AS level_description,
            l.name AS level_name,
            meaw.area_id,
            ea.description AS exam_area,
            meaw.data_incomplete_questions,
            meaw.id AS material_exam_area_week_id,
            dwtm.id AS week_type_material_id,
            uqe.type,
            uqe.position,
            uqe.fl_is_manual
        FROM update_question_exam uqe
        JOIN material_exam_area_week meaw ON uqe.material_exam_area_week_id = meaw.id
        JOIN detail_week_type_mat dwtm ON meaw.week_type_material_id = dwtm.id
        JOIN course c ON uqe.course_id = c.id
        JOIN type_material tm ON dwtm.type_material_id = tm.id
        JOIN exam_area ea ON meaw.area_id = ea.id
        LEFT JOIN topic t ON uqe.topic_id = t.id
        LEFT JOIN subtopic st ON uqe.subtopic_id = st.id
        LEFT JOIN level l ON uqe.level_id = l.id;
    END;
    $$;


ALTER FUNCTION odiseo.fn_save_question_material_exam(p_id bigint, p_material_id bigint, p_type_material_id smallint, p_week smallint, p_area_id smallint, p_question_id bigint, p_subtopic_id smallint, p_level_id smallint, p_created_by bigint) OWNER TO postgres;

--
