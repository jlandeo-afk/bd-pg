-- Function: odiseo.fn_get_report_missing_text_exam(integer, integer, integer)

--

CREATE FUNCTION odiseo.fn_get_report_missing_text_exam(p_material_id integer, p_type_material_id integer, p_week integer) RETURNS TABLE(course_id smallint, course character varying, material_exam_id integer, area character varying, type_text_id smallint, type_text_subcategory_id smallint, category character varying, subcategory character varying, topics jsonb)
    LANGUAGE plpgsql
    AS $$
                            BEGIN
                            RETURN QUERY
                            WITH material_data AS (
                                SELECT m.cycle_id, m.university_id 
                                FROM material m
                                WHERE m.id = p_material_id
                            ),
                            all_areas AS (
                                SELECT meaw.id material_exam_id, ea.description area, meaw.area_id FROM odiseo.detail_week_type_mat AS dwtm
                                JOIN material_exam_area_week meaw ON meaw.week_type_material_id = dwtm.id
                                JOIN exam_area ea ON ea.id = meaw.area_id 
                                WHERE dwtm.type_material_id = p_type_material_id and dwtm.week = p_week
                                AND dwtm.material_id = p_material_id
                            ),
                            type_exam AS (
                                SELECT DISTINCT te.name type  FROM material_exam_area_week meaw 
                                JOIN detail_week_type_mat dwtm ON dwtm.id = meaw.week_type_material_id 
                                JOIN type_material tm ON tm.id = dwtm.type_material_id 
                                JOIN type_material_template tmt ON tmt.id = tm.type_material_template_id 
                                JOIN type_exams te ON te.id = tmt.type_exam_id 
                                WHERE dwtm.type_material_id = p_type_material_id and dwtm.week = p_week
                                AND dwtm.material_id = p_material_id
                                LIMIT 1
                            ),
                            special_courses AS (
                                SELECT c.id FROM course c WHERE c.apply_text = TRUE
                            ),
                            syllabus_main AS (
                                SELECT s.id, s.course_id , c."name" course
                                FROM syllabus s 
                                JOIN course c ON c.id = s.course_id 
                                WHERE s.cycle_id = (SELECT cycle_id FROM material_data)
                                AND s.university_id = (SELECT university_id FROM material_data)
                                AND s.fl_status = true
                                AND s.course_id IN (select sc.id from special_courses sc)
                            ), 
                            syllabus_by_week AS (
                                SELECT 
                                    stw.*, 
                                    sm.course, 
                                    sm.course_id 
                                FROM syllabus_text_weeks stw
                                JOIN syllabus_main sm ON sm.id = stw.syllabus_id
                                CROSS JOIN type_exam te 
                                WHERE stw.fl_status = true
                                AND (
                                    (te.type = 'Tipo 1' AND stw.week = p_week)
                                    OR
                                    (te.type = 'Tipo 2' AND stw.week <= p_week)
                                )
                            ),
                            syllabus_by_categories AS (
                                SELECT DISTINCT 
                                    st.type_text_id, 
                                    st.type_text_subcategory_id, 
                                    tt."name" AS category,  
                                    tts."name" AS subcategory,
                                    sbw.course ,
                                    sbw.course_id 
                                FROM syllabus_text_distributions std 
                                JOIN syllabus_by_week sbw ON sbw.id = std.syllabus_text_week_id 
                                JOIN syllabus_texts st ON st.syllabus_text_distribution_id = std.id AND st.fl_status = true
                                JOIN type_text tt ON tt.id = st.type_text_id 
                                JOIN type_text_subcategories tts ON tts.id = st.type_text_subcategory_id 
                                ORDER BY sbw.course_id
                            ),
                            syllabus_topics_and_subtopics AS (
                                SELECT DISTINCT stc.subtopic_id, s."name" subtopic, t.id topic_id, t."name" topic, sbw.course , sbw.course_id 
                                FROM syllabus_text_distributions std 
                                JOIN syllabus_by_week sbw ON sbw.id = std.syllabus_text_week_id 
                                JOIN syllabus_texts st ON st.syllabus_text_distribution_id = std.id AND st.fl_status = true
                                JOIN type_text tt ON tt.id = st.type_text_id 
                                JOIN syllabus_text_content stc ON st.id = stc.syllabus_text_id AND stc.fl_status = true
                                JOIN subtopic s ON s.id = stc.subtopic_id 
                                JOIN topic t ON t.id = s.topic_id 
                            ),
                            unique_categories AS (
                                SELECT DISTINCT sbc.type_text_id, sbc.category, sbc.course_id, sbc.course 
                                FROM syllabus_by_categories sbc
                            ),
                            unique_subcategories AS (
                                SELECT DISTINCT sbc.type_text_subcategory_id, sbc.subcategory, sbc.course_id, sbc.course 
                                FROM syllabus_by_categories sbc
                            ),
                            full_matrix AS (
                                SELECT 
                                    c.type_text_id,
                                    s.type_text_subcategory_id,
                                    c.category,
                                    s.subcategory,
                                    c.course,
                                    c.course_id 
                                FROM unique_categories c
                                CROSS JOIN unique_subcategories s
                                WHERE c.course_id = s.course_id 
                            ),
                            selected_text AS (
                                SELECT 
                                    pq.type_text_id, 
                                    pq.type_text_subcategory_id,
                                    aa.material_exam_id,
                                    aa.area,
                                    aa.area_id
                                FROM material_exam_parent_question mepq 
                                JOIN parent_question pq ON pq.id = mepq.parent_question_id 
                                JOIN all_areas aa ON aa.material_exam_id = mepq.material_exam_area_week_id
                                WHERE mepq.deleted_at IS NULL
                            ),
                            all_mix_area AS (
                                SELECT * FROM full_matrix fm
                                CROSS JOIN all_areas aa
                            )
                            SELECT
                                ama.course_id::smallint,
                                ama.course,
                                ama.material_exam_id::integer,
                                ama.area,
                                ama.type_text_id::smallint, 
                                ama.type_text_subcategory_id::smallint,
                                ama.category,
                                ama.subcategory,
                                (SELECT jsonb_agg(
                                            json_build_object(
                                                'topic', stas.topic,
                                                'subtopic', stas.subtopic 
                                            )
                                        )
                                FROM syllabus_topics_and_subtopics stas
                                WHERE stas.course_id = ama.course_id) topics
                            FROM all_mix_area ama
                            WHERE NOT EXISTS (
                                SELECT 1 
                                FROM selected_text st 
                                WHERE st.type_text_id = ama.type_text_id 
                                AND st.type_text_subcategory_id = ama.type_text_subcategory_id
                                AND st.material_exam_id = ama.material_exam_id 
                            )
                            AND EXISTS (
                                SELECT 1
                                FROM material_exam_parent_question mepq_check
                                WHERE mepq_check.material_exam_area_week_id = ama.material_exam_id
                                AND mepq_check.course_id = ama.course_id
                                AND mepq_check.parent_question_id IS NULL
                                AND mepq_check.deleted_at IS NULL
                            )
                            ORDER BY ama.course_id, ama.area_id, ama.type_text_id, ama.type_text_subcategory_id;

                            END;
                        $$;


ALTER FUNCTION odiseo.fn_get_report_missing_text_exam(p_material_id integer, p_type_material_id integer, p_week integer) OWNER TO postgres;

--
