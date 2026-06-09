-- Function: materials.fn_get_type_material_course_details(bigint, character)

--

CREATE FUNCTION materials.fn_get_type_material_course_details(p_tmc_id bigint, p_type_question character) RETURNS TABLE(name character varying, course_id smallint, is_generic boolean, type_question text, type_material_child_id smallint, type_material_id bigint, weeks_detail jsonb)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY 
                SELECT 
                    c.name,
                    c.id AS course_id,
                    CASE 
                        WHEN p_type_question = 'P' THEN tmc.is_generic
                        WHEN p_type_question = 'T' THEN tmc.is_generic_text
                        ELSE true
                    END AS is_generic,
                    p_type_question::TEXT AS type_question,
                    tm.id AS type_material_child_id,
                    COALESCE(tm.parent_id, tm.id) AS type_material_id,
                    COALESCE(
                        (
                            SELECT jsonb_agg(
                                jsonb_build_object(
                                    'week', tmdt.week,
                                    'amount', COALESCE(d_p.amount_question, 0),
                                    'amount_text', COALESCE(d_t.amount_text, 0),
                                    'subquestions', CASE 
                                        WHEN p_type_question = 'T' THEN COALESCE(sub_q.data, '[]'::jsonb)
                                        ELSE '[]'::jsonb 
                                    END
                                ) ORDER BY tmdt.week
                            )
                            FROM type_material_detail_template tmdt
                            
                            -- JOIN PREGUNTAS (P)
                            LEFT JOIN materials.type_material_detail_courses d_p 
                                ON d_p.type_material_detail_template_id = tmdt.id 
                                AND d_p.type_material_course_id = tmc.id 
                                AND d_p.fl_status = true
                                AND p_type_question = 'P' 
                            
                            -- JOIN TEXTOS (T)
                            LEFT JOIN materials.type_material_detail_course_texts d_t 
                                ON d_t.type_material_detail_template_id = tmdt.id 
                                AND d_t.type_material_course_id = tmc.id 
                                AND d_t.fl_status = true
                                AND p_type_question = 'T'

                            -- JOIN SUBPREGUNTAS (Solo si es T)
                            LEFT JOIN LATERAL (
                                SELECT jsonb_agg(
                                    jsonb_build_object(
                                        'position', sq.position, 
                                        'subquestion_amount', sq.subquestion_amount
                                    ) ORDER BY sq.position
                                ) as data
                                FROM materials.type_material_detail_text_subquestions sq
                                WHERE sq.type_material_detail_course_text_id = d_t.id
                                AND sq.deleted_at IS NULL
                            ) sub_q ON p_type_question = 'T'

                            WHERE tmdt.type_material_id = tm.id 
                            AND tmdt.fl_status = true
                        ),
                        '[]'::jsonb
                    ) AS weeks_detail

                FROM type_material_course tmc
                JOIN type_material tm ON tm.id = tmc.type_material_id
                JOIN course c ON c.id = tmc.course_id
                WHERE tmc.id = p_tmc_id;
            END;
            $$;


ALTER FUNCTION materials.fn_get_type_material_course_details(p_tmc_id bigint, p_type_question character) OWNER TO postgres;

--
