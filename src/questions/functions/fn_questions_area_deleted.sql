-- Function: questions.fn_questions_area_deleted(bigint, smallint, bigint)

--

CREATE FUNCTION questions.fn_questions_area_deleted(p_material_id bigint, p_week smallint, p_type_material_id bigint) RETURNS TABLE(id bigint, code character varying, course_id smallint, topic_id smallint, level_id smallint, level smallint, type character varying, status character varying, subtopic_id integer, frequent_subtopic boolean, cycle_id integer, week smallint, type_material_id smallint, history jsonb)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_university_id SMALLINT;
        BEGIN
            SELECT m.university_id INTO v_university_id
            FROM material m WHERE m.id = p_material_id LIMIT 1;

            RETURN QUERY
            WITH tbl_questions_area AS (
                SELECT
                    meq.question_id,
                    COUNT(meq.question_id) AS total
                FROM material_exam_question meq
				INNER JOIN material_exam_area_week meaw ON meq.material_exam_area_week_id = meaw.id
				INNER JOIN detail_week_type_mat dwtm ON meaw.week_type_material_id = dwtm.id
				WHERE dwtm.material_id = p_material_id
                    AND dwtm.week = p_week
                    AND dwtm.type_material_id = p_type_material_id
                    AND dwtm.fl_status = true
                    AND meaw.fl_status = true
                    AND meq.fl_status = true
				GROUP BY meq.question_id
				HAVING COUNT(meq.question_id) > 1
				ORDER BY total DESC, meq.question_id ASC
            ), tbl_question AS (
                SELECT
                    q.id,
                    q.code,
                    q.course_id,
                    q.topic_id,
                    q.level_id,
                    l.name::SMALLINT AS level,
                    q.type,
                    q.status,
                    qs.subtopic_id,
                    COALESCE(fus.is_frequent, false) AS frequent_subtopic,
                    qt.cycle_id,
                    qt.week_id AS week,
                    qt.type_material_id,
                    '[]'::JSONB AS history
                FROM question q
                LEFT JOIN question_subtopic qs ON qs.question_id = q.id AND qs.fl_status = true
                LEFT JOIN question_temporary qt ON qt.question_id = q.id AND qt.fl_status = true
                LEFT JOIN level l ON l.id = q.level_id
                LEFT JOIN frequent_university_subtopic fus ON fus.university_id = v_university_id AND fus.subtopic_id = qs.subtopic_id AND fus.fl_status = true
                INNER JOIN (
                    SELECT meq.question_id, COUNT(meq.question_id) AS total FROM material_exam_question meq
                    INNER JOIN material_exam_area_week meaw ON meq.material_exam_area_week_id = meaw.id
                    INNER JOIN detail_week_type_mat dwtm ON meaw.week_type_material_id = dwtm.id
                    WHERE dwtm.material_id = p_material_id
                    AND dwtm.week = p_week
                    AND dwtm.type_material_id = p_type_material_id
                    AND dwtm.fl_status = true
                    AND meaw.fl_status = true
                    AND meq.fl_status = true
                    GROUP BY meq.question_id
                    HAVING COUNT(meq.question_id) > 1
                    ORDER BY total DESC, meq.question_id ASC
                ) question_area ON q.id = question_area.question_id
                WHERE q.status = 'VERI'
                AND q.fl_status = true
                AND l.fl_status = true
                AND (
                    q.number_question IS NULL
                    OR q.number_question NOT ILIKE 'D%'
                )
            ), tbl_question_final AS (
                SELECT tbl.* FROM tbl_question tbl
                INNER JOIN tbl_questions_area tba ON tbl.id = tba.question_id
            )
            SELECT * FROM tbl_question_final ORDER BY topic_id ASC, subtopic_id ASC;
        END;
        $$;


ALTER FUNCTION questions.fn_questions_area_deleted(p_material_id bigint, p_week smallint, p_type_material_id bigint) OWNER TO postgres;

--
