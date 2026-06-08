-- Function: odiseo.fn_find_syllabus_detail_text(integer, integer, integer, integer)

--

CREATE FUNCTION odiseo.fn_find_syllabus_detail_text(p_syllabus_id integer, p_category_id integer, p_week integer, p_company_id integer) RETURNS TABLE(material_name character varying, subcategories jsonb)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                WITH base_data AS (
                    SELECT
                        tm.description AS material_name,
                        tts.name AS subcategory_name,
                        t.name AS topic_name,
                        t.id AS topic_id,
                        s2.name AS subtopic_name,
                        stc.quantity AS quantity,
                        st.position,
                        t.code topic_code,
                        s2.code subtopic_code
                    FROM syllabus s
                    JOIN syllabus_text_weeks stw ON stw.syllabus_id = s.id
                        AND stw.fl_status = TRUE
                        AND stw.company_id = p_company_id
                    JOIN syllabus_text_distributions std ON std.syllabus_text_week_id = stw.id
                        AND std.fl_status = TRUE
                        AND std.company_id = p_company_id
                    JOIN type_material tm ON tm.id = std.type_material_id
                    JOIN syllabus_texts st ON st.syllabus_text_distribution_id = std.id
                        AND st.fl_status = TRUE
                        AND st.company_id = p_company_id
                    JOIN type_text_subcategories tts ON tts.id = st.type_text_subcategory_id
                    JOIN syllabus_text_content stc ON stc.syllabus_text_id = st.id
                        AND stc.company_id = p_company_id
                    JOIN subtopic s2 ON s2.id = stc.subtopic_id
                    JOIN topic t ON t.id = s2.topic_id
                    WHERE
                        stw.week = p_week
                        AND st.type_text_id = p_category_id
                        AND s.company_id = p_company_id
                        AND s.id = p_syllabus_id
                ),
                topics_by_instance AS (
                    SELECT
                        bd.material_name,
                        bd.subcategory_name,
                        bd.position,
                        jsonb_build_object(
                            'id', bd.topic_id,
                            'name', CONCAT(bd.topic_code, ' - ', bd.topic_name),
                            'subtopics', jsonb_agg(
                                jsonb_build_object(
                                    'name', CONCAT(bd.subtopic_code, ' - ', bd.subtopic_name),
                                    'quantity', bd.quantity,
                                    'topicName', CONCAT(bd.topic_code, ' - ', bd.topic_name)
                                )
                            )
                        ) AS topic_object
                    FROM base_data bd
                    GROUP BY
                        bd.material_name,
                        bd.subcategory_name,
                        bd.position,
                        bd.topic_id,
                        bd.topic_name,
                        bd.topic_code
                ),
                instances_by_subcategory AS (
                    SELECT
                        tbi.material_name,
                        tbi.subcategory_name,
                        jsonb_build_object(
                            'name', tbi.subcategory_name || ' #' || tbi.position,
                            'topics', jsonb_agg(tbi.topic_object)
                        ) AS instance_object
                    FROM topics_by_instance tbi
                    GROUP BY
                        tbi.material_name,
                        tbi.subcategory_name,
                        tbi.position
                ),
                subcategories_by_material AS (
                    SELECT
                        ibi.material_name,
                        jsonb_build_object(
                            'name', ibi.subcategory_name,
                            'instances', jsonb_agg(ibi.instance_object ORDER BY ibi.instance_object->>'name')
                        ) AS subcategory_object
                    FROM instances_by_subcategory ibi
                    GROUP BY
                        ibi.material_name,
                        ibi.subcategory_name
                ),
                final_structure AS (
                    SELECT
                        sbm.material_name,
                        jsonb_agg(sbm.subcategory_object) AS subcategories
                    FROM subcategories_by_material sbm
                    GROUP BY
                        sbm.material_name
                ) SELECT fs.material_name, fs.subcategories as subcategories FROM final_structure as fs;

            END;
        $$;


ALTER FUNCTION odiseo.fn_find_syllabus_detail_text(p_syllabus_id integer, p_category_id integer, p_week integer, p_company_id integer) OWNER TO postgres;

--
