-- Function: academic.fn_list_subtopics_by_universities_and_topic_and_course(jsonb, smallint, smallint, boolean, bigint, integer, integer, jsonb, integer, boolean)

--

CREATE FUNCTION academic.fn_list_subtopics_by_universities_and_topic_and_course(f_university_ids jsonb, f_course_id smallint, f_topic_id smallint, p_fl_pseudo boolean, p_option_id bigint, p_start_year integer, p_end_year integer, p_areas jsonb, p_company_id integer, p_show_frequent boolean DEFAULT true) RETURNS TABLE(id smallint, code character varying, name character varying, exist_subtopics boolean, pseuodo_course_id bigint, course_id smallint, is_frequent boolean, frecuency_intensity text, details jsonb, total_detail bigint, method character varying)
    LANGUAGE plpgsql
    AS $$
                            DECLARE
                                v_courses_ids SMALLINT[];
                                v_university_ids SMALLINT[];
                            BEGIN
                                v_university_ids := ARRAY(SELECT jsonb_array_elements_text(f_university_ids)::SMALLINT);

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
                                ), frecuency_details AS (
                                    SELECT
                                        s.id subtopic_id,
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
                                            )  ORDER BY oq.year DESC
                                        ) AS details,
                                        COUNT(*) total_detail
                                    FROM origin_question oq
                                    JOIN question q ON q.id = oq.question_id
                                    JOIN question_subtopic qs ON qs.question_id = q.id AND qs.fl_status = true
                                    JOIN subtopic s ON s.id = qs.subtopic_id
                                    JOIN modality_options_cte m ON m.id = oq.modality_option_id
                                    JOIN option_university ou ON ou.id = m.option_university_id
                                    WHERE ou.university_id = ANY(v_university_ids)
                                    AND m.fl_allows_mark_frequent_topic = true
                                    AND (p_start_year IS NULL OR oq.year::integer >= p_start_year)
                                    AND (p_end_year IS NULL OR oq.year::integer <= p_end_year)
                                    AND (p_areas IS NULL OR p_areas = '[]' OR oq.areas::jsonb ?| array(SELECT jsonb_array_elements_text(p_areas)))
                                    AND oq.fl_status = true
                                    GROUP BY s.id
                                )
                                SELECT
                                    s.id,
                                    s.code,
                                    s.name,
                                    CASE WHEN tbl_template_subtopics.subtopic_id IS NULL THEN FALSE ELSE TRUE END AS exist_subtopics,
                                    tbl_template_subtopics.course_id AS pseuodo_course_id,
                                    t.course_id,
                                    COALESCE(fuc.is_frequent, FALSE) is_frequent,
                                    CASE
                                            WHEN p_show_frequent = FALSE THEN NULL
                                            WHEN fd.total_detail >= 1 AND fd.total_detail <= 2 THEN 'low_frequency'
                                            WHEN fd.total_detail > 2 AND fd.total_detail <= 4 THEN 'medium_frequency'
                                            WHEN fd.total_detail > 4 THEN 'high_frequency'
                                        END AS frecuency_intensity,
                                    fd.details,
                                    fd.total_detail,
                                    fuc.method
                                FROM subtopic s
                                LEFT JOIN (
                                    SELECT stts.subtopic_id, st.course_id
                                    FROM syllabus_template_topic_subtopic stts
                                    INNER JOIN syllabus_template_topic stt ON stts.syllabus_template_topic_id = stt.id AND stt.company_id = p_company_id
                                    INNER JOIN syllabus_template st ON stt.syllabus_template_id = st.id  AND st.company_id = p_company_id
                                    WHERE 1 = 1
                                    AND stts.fl_status IS TRUE
                                    AND stt.fl_status IS TRUE
                                    AND st.fl_status IS TRUE
                                    AND st.university_id = ANY(v_university_ids)
                                    AND stt.topic_id = f_topic_id
                                    AND st.course_id = f_course_id
                                    AND stts.company_id = p_company_id
                                ) AS tbl_template_subtopics ON s.id = tbl_template_subtopics.subtopic_id
                                LEFT JOIN frequent_university_subtopic fuc ON fuc.subtopic_id = s.id AND fuc.university_id = ANY(v_university_ids) AND fuc.fl_status IS TRUE
                                JOIN topic t ON s.topic_id  = t.id
                                LEFT JOIN frecuency_details fd ON fd.subtopic_id = s.id
                                WHERE 1 = 1
                                AND t.course_id = ANY(v_courses_ids)
                                AND s.fl_status
                                AND t.id = f_topic_id
                                AND t.fl_status
                                ORDER BY exist_subtopics DESC, unaccent(t.name);
                            END;
                            $$;


ALTER FUNCTION academic.fn_list_subtopics_by_universities_and_topic_and_course(f_university_ids jsonb, f_course_id smallint, f_topic_id smallint, p_fl_pseudo boolean, p_option_id bigint, p_start_year integer, p_end_year integer, p_areas jsonb, p_company_id integer, p_show_frequent boolean) OWNER TO postgres;

--
