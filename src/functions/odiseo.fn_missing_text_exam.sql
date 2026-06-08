-- Function: odiseo.fn_missing_text_exam(integer, integer, integer)

--

CREATE FUNCTION odiseo.fn_missing_text_exam(p_material_id integer, p_type_material_id integer, p_week integer) RETURNS TABLE(course_id smallint, material_exam_id bigint, type_report text, description text)
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
                        SELECT meaw.id material_exam_id, ea.description area 
                        FROM odiseo.detail_week_type_mat AS dwtm
                        JOIN material_exam_area_week meaw ON meaw.week_type_material_id = dwtm.id
                        JOIN exam_area ea ON ea.id = meaw.area_id 
                        WHERE dwtm.type_material_id = p_type_material_id and dwtm.week = p_week
                        AND dwtm.material_id = p_material_id
                    ),
                    missing_text AS (
                        SELECT 
                            mepq.course_id,
                            aa.area,
                            aa.material_exam_id ,
                            jsonb_array_length(mepq.subquestion) total_subquestion,
                            mepq.expected_level 
                        FROM material_exam_parent_question mepq 
                        LEFT JOIN parent_question pq ON pq.id = mepq.parent_question_id 
                        JOIN all_areas aa ON aa.material_exam_id = mepq.material_exam_area_week_id
                        WHERE mepq.deleted_at IS NULL AND mepq.parent_question_id IS NULL
                    ),
                    report_levels AS (
                        SELECT 
                            'by_level' as type_report,
                            'Falta ' || COUNT(*) || ' texto(s) nivel ' || mt.expected_level as description,
                            mt.course_id,
                            mt.material_exam_id
                        FROM missing_text mt
                        GROUP BY mt.course_id, mt.material_exam_id, mt.expected_level
                    ),
                    report_subquestions AS (
                        SELECT 
                            'by_subquestion' as type_report,
                            'Falta ' || COUNT(*) || ' texto(s) con ' || mt.total_subquestion || ' subpreguntas' as description,
                            mt.course_id,
                            mt.material_exam_id
                        FROM missing_text mt
                        GROUP BY mt.course_id, mt.material_exam_id, mt.total_subquestion
                    )
                    SELECT rl.course_id, rl.material_exam_id, rl.type_report, rl.description
                    FROM report_levels rl
                    UNION ALL
                    SELECT rs.course_id, rs.material_exam_id, rs.type_report, rs.description
                    FROM report_subquestions rs
                    ORDER BY course_id, material_exam_id, type_report;
                END;
            $$;


ALTER FUNCTION odiseo.fn_missing_text_exam(p_material_id integer, p_type_material_id integer, p_week integer) OWNER TO postgres;

--
