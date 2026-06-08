-- Function: odiseo.fn_list_topics_by_universities_and_course_or_pseudo(jsonb, bigint, boolean, bigint, integer, integer, jsonb, integer, boolean)

--

CREATE FUNCTION odiseo.fn_list_topics_by_universities_and_course_or_pseudo(f_university_ids jsonb, f_course_id bigint, p_fl_pseudo boolean, p_option_id bigint, p_start_year integer, p_end_year integer, p_areas jsonb, p_company_id integer, p_show_frequent boolean DEFAULT true) RETURNS TABLE(id smallint, code character varying, name character varying, exist_topic boolean, course_id smallint, frecuency_intensity text, details jsonb, total_detail bigint)
    LANGUAGE plpgsql
    AS $$
                            DECLARE
                                v_courses_ids BIGINT[];
                                v_university_ids BIGINT[];
                            BEGIN
                                v_university_ids := ARRAY(SELECT jsonb_array_elements_text(f_university_ids)::BIGINT);

                                IF p_fl_pseudo IS TRUE THEN
                                    SELECT ARRAY(
                                        SELECT cpc.course_id AS id_course
                                        FROM course_pseudo_courses cpc
                                        WHERE 1 = 1
                                        AND cpc.fl_status IS TRUE
                                        AND cpc.pseudo_course_id = f_course_id
                                        ORDER BY cpc.order
                                    ) INTO v_courses_ids;
                                ELSE
                                    SELECT ARRAY[f_course_id] INTO v_courses_ids;
                                END IF;

                                RETURN QUERY
                                WITH modality_options_cte as (
                                    SELECT
                                        mo.id,
                                        mo.fl_allows_mark_frequent_topic,
                                        ou.id as option_university_id
                                    FROM modality_options mo
                                    INNER JOIN option_university ou ON mo.option_university_id = ou.id AND ou.university_id = ANY(v_university_ids) 
                                    WHERE mo.deleted_at IS NULL
                                    AND (
                                        p_option_id IS NULL
                                        OR ou.id = p_option_id
                                    )
                                ),frecuency_details AS (
                                    SELECT
                                        t.id topic_id,
                                        JSONB_AGG(
                                            JSON_BUILD_OBJECT(
                                                'year', oq."year",
                                                'version', fn_number_to_roman(oq."version"),
                                                'areas', (
                                                    SELECT array_to_string(
                                                        ARRAY(
                                                            SELECT json_array_elements_text(oq.areas::json)
                                                        ),
                                                        ' - '
                                                    )
                                                )
                                            ) ORDER BY oq.year DESC
                                        ) AS details,
                                        COUNT(*) total_detail
                                    FROM origin_question oq
                                    JOIN question q ON q.id = oq.question_id
                                    JOIN question_subtopic qs ON qs.question_id = q.id AND qs.fl_status = true
                                    JOIN subtopic s ON s.id = qs.subtopic_id
                                    JOIN topic t ON t.id = s.topic_id
                                    JOIN modality_options_cte m ON m.id = oq.modality_option_id
                                    JOIN option_university ou ON ou.id = m.option_university_id
                                    WHERE ou.university_id = ANY(v_university_ids)
                                    AND m.fl_allows_mark_frequent_topic = true
                                    AND (p_start_year IS NULL OR oq.year::integer >= p_start_year)
                                    AND (p_end_year IS NULL OR oq.year::integer <= p_end_year)
                                    AND (p_areas IS NULL OR p_areas = '[]' OR oq.areas::jsonb ?| array(SELECT jsonb_array_elements_text(p_areas)))
                                    AND oq.fl_status = true
                                    GROUP BY t.id
                                )
                                SELECT
                                    t.id,
                                    t.code,
                                    t.name,
                                    CASE
                                        WHEN tbl_template_topic.topic_id IS NULL
                                            THEN FALSE
                                        ELSE TRUE
                                    END AS exist_topic,
                                    t.course_id,
                                    CASE
                                        WHEN p_show_frequent = FALSE THEN NULL
                                        WHEN fd.total_detail >= 1 AND fd.total_detail <= 2 THEN 'low_frequency'
                                        WHEN fd.total_detail > 2 AND fd.total_detail <= 4 THEN 'medium_frequency'
                                        WHEN fd.total_detail > 4 THEN 'high_frequency'
                                    END AS frecuency_intensity,
                                    fd.details,
                                    fd.total_detail
                                FROM topic t
                                LEFT JOIN
                                (
                                    SELECT
                                        stt.topic_id
                                    FROM syllabus_template_topic stt
                                    LEFT JOIN syllabus_template st ON stt.syllabus_template_id = st.id AND st.company_id = p_company_id
                                    WHERE 1 = 1
                                    AND st.university_id = ANY(v_university_ids)
                                    AND st.course_id = f_course_id
                                    AND stt.fl_status IS TRUE
                                    AND st.fl_status IS TRUE
                                    AND stt.company_id = p_company_id
                                ) AS tbl_template_topic ON tbl_template_topic.topic_id = t.id
                                LEFT JOIN frecuency_details fd ON fd.topic_id = t.id
                                WHERE 1 = 1
                                AND t.course_id = ANY(v_courses_ids)
                                AND t.fl_status = TRUE
                                AND t.deleted_at IS NULL
                                GROUP BY
                                    t.id,
                                    t.code,
                                    t.name,
                                    t.course_id,
                                    exist_topic,
                                    fd.details,
                                    fd.total_detail
                                ORDER BY t.course_id, t.code, exist_topic DESC, unaccent(t.name) ASC;
                            END;
                            $$;


ALTER FUNCTION odiseo.fn_list_topics_by_universities_and_course_or_pseudo(f_university_ids jsonb, f_course_id bigint, p_fl_pseudo boolean, p_option_id bigint, p_start_year integer, p_end_year integer, p_areas jsonb, p_company_id integer, p_show_frequent boolean) OWNER TO postgres;

--
