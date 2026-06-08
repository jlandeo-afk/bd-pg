-- Function: odiseo.fn_get_matching_type_material_weeks(integer, integer, integer)

--

CREATE FUNCTION odiseo.fn_get_matching_type_material_weeks(p_course_id integer, p_week integer, p_cycle_id integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
                    DECLARE
                        v_matching_weeks JSONB;
                    BEGIN
                        WITH weekly_material_loads AS (
                        SELECT 
                            tmdt.week,
                            tmt.name AS material_name,
                            SUM(
                                CASE 
                                    WHEN tmc.is_generic = true THEN tmc.amount_question
                                    ELSE COALESCE(tmdc.amount_question, 0)
                                END
                            ) AS total_question,
                            SUM( 
                                CASE 
                                    WHEN tmc.is_generic_text = true THEN tmc.amount_text
                                    ELSE COALESCE(tmdct.amount_text, 0)
                                END
                            ) AS total_text
                        FROM type_material tm
                        JOIN type_material_detail_template tmdt ON tmdt.type_material_id = tm.id
                        JOIN type_material_template tmt ON tmt.id = tm.type_material_template_id 
                        JOIN type_material_course tmc ON tmc.type_material_id = tm.id
                        LEFT JOIN type_material_detail_courses tmdc ON tmdc.type_material_course_id = tmc.id 
                            AND tmdc.type_material_detail_template_id = tmdt.id
                        LEFT JOIN type_material_detail_course_texts tmdct ON tmdct.type_material_course_id = tmc.id 
                            AND tmdct.type_material_detail_template_id = tmdt.id
                        WHERE tm.cycle_id = p_cycle_id
                        AND tmc.course_id = p_course_id
                        AND tm.fl_exam = false
                        and tmdt.deleted_at IS NULL
                        GROUP BY tmdt.week, tmt.name
                    ),
                    week_signatures AS (
                        SELECT 
                            week,
                            jsonb_agg(
                                jsonb_build_object(
                                    'name', material_name,
                                    'q', total_question,
                                    't', total_text
                                ) ORDER BY material_name
                            ) AS signature
                        FROM weekly_material_loads
                        GROUP BY week
                    ),
                    target_signature AS (
                        SELECT signature 
                        FROM week_signatures 
                        WHERE week = p_week
                    )
                    SELECT COALESCE(jsonb_agg(ws.week ORDER BY ws.week), '[]'::jsonb)
                    INTO v_matching_weeks
                    FROM week_signatures ws
                    JOIN target_signature ts ON ws.signature = ts.signature
                    WHERE ws.week != p_week;

                    RETURN v_matching_weeks;
                    END;
                    $$;


ALTER FUNCTION odiseo.fn_get_matching_type_material_weeks(p_course_id integer, p_week integer, p_cycle_id integer) OWNER TO postgres;

--
