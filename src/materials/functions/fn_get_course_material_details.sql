-- Function: materials.fn_get_course_material_details(smallint, integer, integer)

--

CREATE FUNCTION materials.fn_get_course_material_details(p_course_id smallint, p_week integer, p_cycle_id integer) RETURNS TABLE(type_material_id smallint, type_material text, is_generic boolean, is_generic_text boolean, amount_question integer, amount_text integer, subquestions jsonb)
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    RETURN QUERY
                    SELECT 
                        tm.id AS type_material_id,
                        tmt.name::TEXT AS type_material,
                        tmc.is_generic,
                        tmc.is_generic_text,
                        CASE 
                            WHEN tmc.is_generic = true THEN tmc.amount_question
                            ELSE COALESCE(tmdc.amount_question, 0)
                        END AS final_amount_question,
                        
                        CASE 
                            WHEN tmc.is_generic_text = true THEN tmc.amount_text
                            ELSE COALESCE(tmdct.amount_text, 0)
                        END AS final_amount_text,

                        CASE 
                            WHEN tmc.is_generic_text = true THEN (
                                SELECT jsonb_agg(
                                    jsonb_build_object(
                                        'position', ttmtc.position, 
                                        'subquestion_amount', ttmtc.subquestion_amount
                                    ) ORDER BY ttmtc.position
                                )
                                FROM type_text_material_type_course ttmtc 
                                WHERE ttmtc.type_material_id = tm.id 
                                AND ttmtc.course_id = tmc.course_id 
                                AND ttmtc.deleted_at IS NULL
                            )
                            ELSE (
                                SELECT jsonb_agg(
                                    jsonb_build_object(
                                        'position', sq.position, 
                                        'subquestion_amount', sq.subquestion_amount
                                    ) ORDER BY sq.position
                                )
                                FROM type_material_detail_text_subquestions sq
                                WHERE sq.type_material_detail_course_text_id = tmdct.id 
                                AND sq.deleted_at IS NULL
                            )
                        END AS subquestions

                    FROM type_material tm
                    JOIN type_material_template tmt ON tmt.id = tm.type_material_template_id
                    JOIN type_material_detail_template tmdt ON tmdt.type_material_id = tm.id
                    JOIN type_material_course tmc ON tmc.type_material_id = tm.id
                    LEFT JOIN type_material_detail_courses tmdc ON tmdc.type_material_course_id = tmc.id 
                        AND tmdc.type_material_detail_template_id = tmdt.id
                    LEFT JOIN type_material_detail_course_texts tmdct ON tmdct.type_material_course_id = tmc.id 
                        AND tmdct.type_material_detail_template_id = tmdt.id
                    WHERE tm.cycle_id = p_cycle_id
                    AND tmc.course_id = p_course_id
                    AND tmdt.week = p_week
                    AND tm.fl_exam = false
                    AND tm.fl_status = true
                    AND (
                        tm.parent_id IS NOT NULL
                        OR
                        tm.id NOT IN (SELECT parent_id FROM type_material WHERE cycle_id = p_cycle_id AND parent_id IS NOT NULL)
                    )
                    ORDER BY tmt.name
                    ;
                END;
                $$;


ALTER FUNCTION materials.fn_get_course_material_details(p_course_id smallint, p_week integer, p_cycle_id integer) OWNER TO postgres;

--
