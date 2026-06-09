-- Function: academic.get_syllabus_text(integer, integer, integer)

--

CREATE FUNCTION academic.get_syllabus_text(p_syllabus_id integer, p_week integer, p_company_id integer) RETURNS TABLE(material_id smallint, material character varying, categories jsonb)
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    RETURN QUERY
                    
                    WITH subtopic_details AS (
                        SELECT
                            stc.syllabus_text_id ,
                            jsonb_agg(
                                jsonb_build_object(
                                    'subtopic_id', stc.subtopic_id,
                                    'subtopic', CONCAT(s.code, ' - ', s.name),
                                    'quantity', stc.quantity,
                                    'topic_id', t.id,
                                    'topic_name', CONCAT(t.code, ' - ', t.name)
                                ) ORDER BY s.name
                            ) AS subtopics
                        FROM syllabus_text_content stc
                        JOIN subtopic s ON s.id = stc.subtopic_id
                        JOIN topic t ON t.id = s.topic_id
                        WHERE stc.fl_status = true
                            AND stc.company_id = p_company_id
                        GROUP BY stc.syllabus_text_id
                    ),
                    subcategory_details AS (
                        SELECT
                            st.syllabus_text_distribution_id,
                            st.type_text_id,
                            jsonb_agg(
                                jsonb_build_object(
                                    'subcategory_id', st.type_text_subcategory_id,
                                    'subcategory', tts.name,
                                    'position', st.position,
                                    'subtopics', COALESCE(sd.subtopics, '[]'::jsonb),
                                    'style_quantity',std.quantity,
                                    'style_type',std.style_type
                                ) ORDER BY st.position
                            ) AS subcategories
                        FROM syllabus_texts st
                        JOIN type_text_subcategories tts ON tts.id = st.type_text_subcategory_id
                        LEFT JOIN subtopic_details sd ON sd.syllabus_text_id = st.id
                        LEFT JOIN syllabus_text_detail std ON std.syllabus_text_id = st.id 
                        WHERE st.fl_status = true
                            AND st.company_id = p_company_id
                        GROUP BY st.syllabus_text_distribution_id, st.type_text_id
                    ),
                    categories_by_material AS (
                        SELECT
                            std.type_material_id,
                            jsonb_agg(
                                DISTINCT jsonb_build_object(
                                    'category_id', unique_texts.type_text_id,
                                    'category_name', tt.name,
                                    'subcategories', scd.subcategories
                                )
                            ) FILTER (
                                WHERE scd.subcategories IS NOT NULL
                                AND jsonb_array_length(scd.subcategories) > 0
                            ) AS categories
                        FROM syllabus_text_distributions std
                        JOIN (
                            SELECT DISTINCT
                                st.syllabus_text_distribution_id, st.type_text_id
                            FROM syllabus_texts st
                            JOIN syllabus_text_distributions std_filter ON std_filter.id = st.syllabus_text_distribution_id
                                AND std_filter.company_id = p_company_id
                            JOIN syllabus_text_weeks stw_filter ON stw_filter.id = std_filter.syllabus_text_week_id
                                AND stw_filter.company_id = p_company_id
                            WHERE stw_filter.syllabus_id = p_syllabus_id
                                AND stw_filter.week = p_week
                                AND st.company_id = p_company_id
                                AND stw_filter.fl_status = true
                        ) AS unique_texts ON unique_texts.syllabus_text_distribution_id = std.id
                        JOIN type_text tt ON tt.id = unique_texts.type_text_id
                        LEFT JOIN subcategory_details scd ON scd.syllabus_text_distribution_id = unique_texts.syllabus_text_distribution_id
                            AND scd.type_text_id = unique_texts.type_text_id
                        WHERE std.company_id = p_company_id
                        GROUP BY std.type_material_id
                    )
                    SELECT
                        tm.id AS material_id,
                        tm.description AS material,
                        COALESCE(cbm.categories, '[]'::jsonb) AS categories
                    FROM syllabus s
                    JOIN syllabus_text_weeks stw ON stw.syllabus_id = s.id
                        AND stw.company_id = p_company_id
                    JOIN syllabus_text_distributions std ON std.syllabus_text_week_id = stw.id
                        AND std.company_id = p_company_id
                    JOIN type_material tm ON tm.id = std.type_material_id
                    LEFT JOIN categories_by_material cbm ON cbm.type_material_id = tm.id
                    WHERE s.id = p_syllabus_id
                        AND stw.week = p_week
                        AND s.company_id = p_company_id
                    GROUP BY tm.id, tm.description, cbm.categories;

                END;
                $$;


ALTER FUNCTION academic.get_syllabus_text(p_syllabus_id integer, p_week integer, p_company_id integer) OWNER TO postgres;

--
