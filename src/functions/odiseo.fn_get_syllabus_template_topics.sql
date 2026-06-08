-- Function: odiseo.fn_get_syllabus_template_topics(integer, integer, boolean, integer, integer, bigint)

--

CREATE FUNCTION odiseo.fn_get_syllabus_template_topics(p_university_id integer, p_course_id integer, p_fl_pseudo boolean, p_category_id integer, p_type_text_subcategory_id integer, p_company_id bigint) RETURNS TABLE(syllabus_template_topic_id integer, topic_id smallint, topic_code character varying, name text, category_id bigint, subcategory_id bigint)
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    RETURN QUERY
                    WITH template_topics AS (
                        SELECT
                            stt.id AS syllabus_template_topic_id,
                            stt.topic_id as topic_id,
                            t.code AS topic_code,
                            CONCAT(t.code, ' - ', t.name) AS name,
                            ttt.type_text_id category_id,
                            cas.subcategory_id subcategory_id
                        FROM syllabus_template st
                        INNER JOIN syllabus_template_topic stt ON stt.syllabus_template_id = st.id
                            AND stt.fl_status IS true
                            AND stt.company_id = p_company_id
                        INNER JOIN topic t ON t.id = stt.topic_id
                        LEFT JOIN type_texts_topics ttt ON ttt.topic_id = stt.topic_id
                            AND ttt.type_text_id = p_category_id
                        LEFT JOIN course_assigned_categories cac ON cac.type_text_id = ttt.type_text_id
                            AND cac.course_id = p_course_id
                        LEFT JOIN course_assigned_subcategories cas ON cas.course_assigned_category_id = cac.id
                        WHERE st.university_id = p_university_id
                            AND (
                                (p_fl_pseudo = TRUE AND st.pseudo_course_id = p_course_id)
                                OR
                                (p_fl_pseudo = FALSE AND st.course_id = p_course_id)
                            )
                            AND (p_category_id IS NULL OR ttt.type_text_id = p_category_id)
                            AND (p_type_text_subcategory_id IS NULL OR cas.subcategory_id = p_type_text_subcategory_id)
                            AND st.fl_status IS true
                            AND CASE
                                    WHEN p_course_id NOT IN (6, 13) THEN cas.id IS NULL
                                    ELSE TRUE
                                END
                            AND st.company_id = p_company_id

                        UNION ALL

                        -- Segundo SELECT
                        SELECT
                            stt.id AS syllabus_template_topic_id,
                            stt.topic_id as topic_id,
                            t.code AS topic_code,
                            CONCAT(t.code, ' - ', t.name) AS name,
                            NULL::bigint  category_id,
                            NULL::bigint  subcategory_id
                        FROM syllabus_template st
                        INNER JOIN syllabus_template_topic stt ON st.id = stt.syllabus_template_id
                            AND stt.fl_status IS TRUE
                            AND stt.company_id = p_company_id
                        INNER JOIN topic t ON t.id = stt.topic_id
                        WHERE st.university_id = p_university_id
                            AND (
                                (p_fl_pseudo = TRUE AND st.pseudo_course_id = p_course_id)
                                OR
                                (p_fl_pseudo = FALSE AND st.course_id = p_course_id)
                            )
                            AND stt.topic_id IN (
                                SELECT
                                    st3.topic_id
                                FROM syllabus_topic st3
                                JOIN syllabus s ON st3.syllabus_id = s.id
                                WHERE st3.fl_status = TRUE
                                    AND st3.is_topic_deleted = TRUE
                                    AND s.university_id = p_university_id
                                    AND (
                                        (p_fl_pseudo = TRUE AND s.pseudo_course_id = p_course_id)
                                        OR
                                        (p_fl_pseudo = FALSE AND s.course_id = p_course_id)
                                    )
                            )
                            AND st.company_id = p_company_id
                    )
                    SELECT
                        *
                    FROM template_topics tt
                    ORDER BY CAST(tt.topic_code AS INTEGER);
                END;
                $$;


ALTER FUNCTION odiseo.fn_get_syllabus_template_topics(p_university_id integer, p_course_id integer, p_fl_pseudo boolean, p_category_id integer, p_type_text_subcategory_id integer, p_company_id bigint) OWNER TO postgres;

--
