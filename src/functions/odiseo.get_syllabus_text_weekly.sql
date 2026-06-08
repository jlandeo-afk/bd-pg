-- Function: odiseo.get_syllabus_text_weekly(integer, integer)

--

CREATE FUNCTION odiseo.get_syllabus_text_weekly(p_syllabus_id integer, p_company_id integer) RETURNS TABLE(syllabus_text_payload jsonb)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                WITH
                    subtopics_agg AS (
                        SELECT
                            stc.syllabus_text_id,
                            jsonb_agg(jsonb_build_object('subtopic_id', stc.subtopic_id, 'quantity', stc.quantity) ORDER BY stc.id) AS subtopics
                        FROM syllabus_text_content stc
                        WHERE stc.fl_status = true
                        AND stc.company_id = p_company_id
                        GROUP BY stc.syllabus_text_id
                    ),
                    texts_agg AS (
                        SELECT
                            st.syllabus_text_distribution_id,
                            jsonb_agg(jsonb_build_object(
                            'category_id', st.type_text_id, 
                            'subcategory_id', st.type_text_subcategory_id, 
                            'position', st.position, 
                            'subtopics', COALESCE(sa.subtopics, '[]'::jsonb),
                            'style_type', std.style_type,
                            'style_quantity', std.quantity
                        ) ORDER BY st.position) AS texts
                        FROM syllabus_texts st
                        LEFT JOIN subtopics_agg sa ON sa.syllabus_text_id = st.id
                        LEFT JOIN syllabus_text_detail std ON std.syllabus_text_id = st.id
                        WHERE st.fl_status = true
                        AND st.company_id = p_company_id
                        GROUP BY st.syllabus_text_distribution_id
                    ),
                    distributions_agg AS (
                        SELECT
                            std.syllabus_text_week_id,
                            jsonb_agg(
                                jsonb_build_object(
                                    'material_id', std.type_material_id,
                                    'texts', COALESCE(ta.texts, '[]'::jsonb)
                                ) ORDER BY std.id
                            ) AS distributions
                        FROM syllabus_text_distributions std
                        LEFT JOIN texts_agg ta ON ta.syllabus_text_distribution_id = std.id
                        WHERE std.fl_status = true
                        AND std.company_id = p_company_id
                        GROUP BY std.syllabus_text_week_id
                    )
                SELECT
                    COALESCE(jsonb_agg(
                        jsonb_build_object(
                            'week', stw.week,
                            'distributions', COALESCE(da.distributions, '[]'::jsonb)
                        )
                    ), '[]'::jsonb) AS syllabus_text_payload
                FROM
                    syllabus_text_weeks stw
                    LEFT JOIN distributions_agg da ON da.syllabus_text_week_id = stw.id
                WHERE
                    stw.syllabus_id = p_syllabus_id AND stw.fl_status = true
                AND
                    stw.company_id = p_company_id;
            END;
        $$;


ALTER FUNCTION odiseo.get_syllabus_text_weekly(p_syllabus_id integer, p_company_id integer) OWNER TO postgres;

--
