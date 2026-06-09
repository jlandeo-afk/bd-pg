-- Function: materials.fn_material_amount_question_subtopic_examen_v2(bigint, jsonb, jsonb)

--

CREATE FUNCTION materials.fn_material_amount_question_subtopic_examen_v2(p_material_id bigint, p_weeks jsonb, p_courses jsonb) RETURNS TABLE(course_id bigint, code_course character varying, course character varying, topic_id smallint, code_topic character varying, topic character varying, subtopic_id smallint, code_subtopic character varying, subtopic character varying, week smallint, frequent_subtopic boolean, type_week_id bigint, type_week character varying)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
			WITH tbl_material AS (
                SELECT
                    m.cycle_id,
                    m.university_id,
                    m.headquarte_id
                FROM material m
                WHERE m.id = p_material_id
            ), tbl_subtopics AS (
				SELECT DISTINCT ON (ds.subtopic_id)
	                s.course_id,
	                co.code AS code_course,
	                co.name AS course,
	                st.topic_id,
	                top.code AS code_topic,
	                top.name AS topic,
	                ds.subtopic_id,
	                su.code AS code_subtopic,
	                su.name AS subtopic,
	                tw.week,
                    COALESCE(fus.is_frequent, false) AS frequent_subtopic,
					cw.type_week_id,
					twe.description AS type_week
	            FROM syllabus_subtopic_type_material stm
	            INNER JOIN syllabus_detail_subtopic ds ON stm.syllabus_detail_subtopic_id = ds.id AND ds.fl_status = true
	            INNER JOIN syllabus_topic_week tw ON ds.syllabus_topic_week_id = tw.id AND tw.fl_status = true
	            INNER JOIN syllabus_topic st ON tw.syllabus_topic_id = st.id AND st.fl_status = true
	            INNER JOIN syllabus s ON st.syllabus_id = s.id
	            INNER JOIN course co ON s.course_id = co.id
	            INNER JOIN topic top ON st.topic_id = top.id
	            INNER JOIN subtopic su ON ds.subtopic_id = su.id
                LEFT JOIN frequent_university_subtopic fus ON ds.subtopic_id = fus.subtopic_id
                    AND fus.is_frequent = true
                    AND fus.university_id IN (SELECT tm.university_id FROM tbl_material tm)
                    AND fus.fl_status = true
				LEFT JOIN cycle_weeks cw ON s.cycle_id = cw.cycle_id AND tw.week = cw.week AND cw.fl_status IS TRUE
				LEFT JOIN type_week twe ON cw.type_week_id = twe.id
	            WHERE s.cycle_id IN (SELECT tm.cycle_id FROM tbl_material tm)
		            AND stm.fl_status = true
		            AND s.university_id IN (SELECT tm.university_id FROM tbl_material tm)
		            AND s.course_id IN (SELECT jsonb_array_elements_text(p_courses)::SMALLINT)
		            AND (
	                    p_weeks IS NULL
	                    OR p_weeks = '[]'
	                    OR tw.week IN (SELECT jsonb_array_elements_text(p_weeks)::SMALLINT)
	                )
	            ORDER BY ds.subtopic_id ASC, tw.week DESC
			)
			SELECT * FROM tbl_subtopics
			ORDER BY course_id ASC, topic_id ASC, subtopic_id ASC;
        END;
        $$;


ALTER FUNCTION materials.fn_material_amount_question_subtopic_examen_v2(p_material_id bigint, p_weeks jsonb, p_courses jsonb) OWNER TO postgres;

--
