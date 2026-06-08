-- Function: odiseo.fn_frequent_subtopics_list(bigint, integer, integer, jsonb, smallint, smallint, integer, bigint, integer, integer, character varying, character varying)

--

CREATE FUNCTION odiseo.fn_frequent_subtopics_list(p_option_id bigint, p_start_year integer, p_end_year integer, p_areas jsonb, p_university_id smallint, p_course_id smallint, p_company_id integer, p_user_id bigint, p_perpage integer, p_npage integer, p_order_column character varying, p_order_direction character varying) RETURNS TABLE(course text, topic text, subtopic text, years jsonb, version text, frequency text, frecuency_value bigint, areas jsonb, total bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH valid_modality_options AS (
        SELECT
            mo.id,
            mo.fl_allows_mark_frequent_topic,
            ou.id as option_university_id
        FROM modality_options mo
        INNER JOIN option_university ou ON mo.option_university_id = ou.id AND ou.university_id = p_university_id
        WHERE mo.deleted_at IS NULL
        AND (
            p_option_id IS NULL
            OR ou.id = p_option_id
        )
    ),
    raw_filtered_questions AS (
        SELECT
            oq.year,
            oq.version,
            oq.areas,
            qs.subtopic_id,
            COALESCE(
                NULLIF(ou_legacy.versions, '')::jsonb,
                '[]'::jsonb
            ) AS versions
        FROM origin_question oq
        JOIN question_subtopic qs ON qs.question_id = oq.question_id AND qs.fl_status = true
        JOIN subtopic s ON s.id = qs.subtopic_id
        JOIN topic t ON t.id = s.topic_id
        LEFT JOIN modality_options mo2 ON mo2.id = oq.modality_option_id
        LEFT JOIN option_university ou2 ON ou2.id = mo2.option_university_id
        LEFT JOIN origin_university ou_legacy ON ou_legacy.id = oq.university_id
        WHERE oq.fl_status = true
          AND (
            (
                oq.modality_option_id IS NOT NULL
                AND oq.modality_option_id IN (SELECT id FROM valid_modality_options)
                AND ou2.university_id = p_university_id
            )
            OR
            (
                oq.modality_option_id IS NULL
                AND oq.university_id IS NOT NULL
                AND oq.university_id = p_university_id
                AND (p_option_id IS NULL OR p_option_id = 0)
            )
          )
          AND (p_course_id IS NULL OR t.course_id = p_course_id)
          AND (p_start_year IS NULL OR oq.year::int >= p_start_year)
          AND (p_end_year IS NULL OR oq.year::int <= p_end_year)
          AND (
            p_areas IS NULL OR p_areas = '[]'::jsonb
            OR oq.areas::jsonb ?| array(SELECT jsonb_array_elements_text(p_areas))
          )
    ),

    user_allowed_courses AS (
        SELECT DISTINCT allowed.id
        FROM fn_list_courses_user(p_user_id) allowed
        WHERE allowed.id IS NOT NULL
    ),

    enriched_subtopic_data AS (
        SELECT
            raw.subtopic_id,
            s.name::text AS subtopic_name,
            t.name::text AS topic_name,
            c.name::text AS course_name,
            raw.year::int AS exam_year,
            (raw.year::text || '-' || fn_number_to_roman(raw.version)::text) AS year_version_label,
            fn_number_to_roman(raw.version)::text AS roman_version,
            COALESCE(
                (
                    SELECT (version_item->>'order')::int
                    FROM jsonb_array_elements(raw.versions) AS version_item
                    WHERE (version_item->>'version')::int = raw.version::int
                    ORDER BY (version_item->>'order')::int ASC
                    LIMIT 1
                ),
                raw.version::int
            ) AS version_order,
            raw.areas::jsonb AS areas_json,
            s.code AS subtopic_code,
            t.code AS topic_code,
            c.code AS course_code,
            raw.versions AS versions
        FROM raw_filtered_questions raw
        JOIN subtopic s ON s.id = raw.subtopic_id
        JOIN topic t ON t.id = s.topic_id
        JOIN course c ON c.id = t.course_id
        JOIN user_allowed_courses allowed_courses ON allowed_courses.id = c.id
    ),

    subtopic_frequency_calculation AS (
        SELECT
            *,
            COUNT(*) OVER (PARTITION BY subtopic_id) AS total_occurrence_count
        FROM enriched_subtopic_data
    ),

    final_grouped_results AS (
        SELECT
            calc.course_name,
            calc.topic_name,
            calc.subtopic_name,
            (
                SELECT jsonb_agg(distinct_years.year_version_label
                    ORDER BY
                        CASE
                            WHEN p_order_column = 'year' AND p_order_direction = 'asc'
                            THEN distinct_years.exam_year
                        END ASC,
                        CASE
                            WHEN p_order_column = 'year' AND p_order_direction = 'asc'
                            THEN distinct_years.version_order
                        END ASC,
                        CASE
                            WHEN NOT (p_order_column = 'year' AND p_order_direction = 'asc')
                            THEN distinct_years.exam_year
                        END DESC,
                        CASE
                            WHEN NOT (p_order_column = 'year' AND p_order_direction = 'asc')
                            THEN distinct_years.version_order
                        END DESC
                )
                FROM (
                    SELECT DISTINCT
                        c2.exam_year,
                        c2.version_order,
                        c2.year_version_label
                    FROM subtopic_frequency_calculation c2
                    WHERE c2.subtopic_id = calc.subtopic_id
                ) AS distinct_years
            ) AS list_of_years,
            (
                SELECT distinct_years.exam_year
                FROM (
                    SELECT DISTINCT
                        c2.exam_year,
                        c2.version_order
                    FROM subtopic_frequency_calculation c2
                    WHERE c2.subtopic_id = calc.subtopic_id
                ) AS distinct_years
                ORDER BY distinct_years.exam_year ASC, distinct_years.version_order ASC
                LIMIT 1
            ) AS sort_year_asc,
            (
                SELECT distinct_years.version_order
                FROM (
                    SELECT DISTINCT
                        c2.exam_year,
                        c2.version_order
                    FROM subtopic_frequency_calculation c2
                    WHERE c2.subtopic_id = calc.subtopic_id
                ) AS distinct_years
                ORDER BY distinct_years.exam_year ASC, distinct_years.version_order ASC
                LIMIT 1
            ) AS sort_version_asc,
            (
                SELECT distinct_years.exam_year
                FROM (
                    SELECT DISTINCT
                        c2.exam_year,
                        c2.version_order
                    FROM subtopic_frequency_calculation c2
                    WHERE c2.subtopic_id = calc.subtopic_id
                ) AS distinct_years
                ORDER BY distinct_years.exam_year DESC, distinct_years.version_order DESC
                LIMIT 1
            ) AS sort_year_desc,
            (
                SELECT distinct_years.version_order
                FROM (
                    SELECT DISTINCT
                        c2.exam_year,
                        c2.version_order
                    FROM subtopic_frequency_calculation c2
                    WHERE c2.subtopic_id = calc.subtopic_id
                ) AS distinct_years
                ORDER BY distinct_years.exam_year DESC, distinct_years.version_order DESC
                LIMIT 1
            ) AS sort_version_desc,
            MAX(calc.roman_version) AS latest_version_text,
            CASE
                WHEN calc.total_occurrence_count BETWEEN 1 AND 2 THEN 'low_frequency'
                WHEN calc.total_occurrence_count BETWEEN 3 AND 4 THEN 'medium_frequency'
                ELSE 'high_frequency'
            END AS frequency_label,
            jsonb_agg(DISTINCT area_tags.item) FILTER (WHERE area_tags.item IS NOT NULL) AS list_of_areas,
            calc.total_occurrence_count,
            calc.course_code,
            calc.topic_code,
            calc.subtopic_code
        FROM subtopic_frequency_calculation calc
        LEFT JOIN LATERAL jsonb_array_elements_text(calc.areas_json) AS area_tags(item) ON TRUE
        GROUP BY 
            calc.subtopic_id,
            calc.course_name, calc.topic_name, calc.subtopic_name, 
            calc.total_occurrence_count,
            calc.course_code, calc.topic_code, calc.subtopic_code
    )

    SELECT 
        (COALESCE(final.course_code, '') || '-' || final.course_name) AS course,
        (COALESCE(final.topic_code, '') || '-' || final.topic_name) AS topic,
        (COALESCE(final.subtopic_code, '') || '-' || final.subtopic_name) AS subtopic,
        final.list_of_years AS years,
        final.latest_version_text AS version,
        final.frequency_label AS frequency,
        final.total_occurrence_count AS frecuency_value,
        final.list_of_areas AS areas,
        COUNT(*) OVER() AS total
    FROM final_grouped_results final
    ORDER BY 

    CASE 
        WHEN p_order_column = 'course' AND p_order_direction = 'asc' 
        THEN unaccent(lower(final.course_name)) 
    END ASC,
    CASE 
        WHEN p_order_column = 'course' AND p_order_direction = 'desc' 
        THEN unaccent(lower(final.course_name)) 
    END DESC,

    CASE 
        WHEN p_order_column = 'topic' AND p_order_direction = 'asc' 
        THEN unaccent(lower(final.topic_name)) 
    END ASC,
    CASE 
        WHEN p_order_column = 'topic' AND p_order_direction = 'desc' 
        THEN unaccent(lower(final.topic_name)) 
    END DESC,

    CASE 
        WHEN p_order_column = 'subtopic' AND p_order_direction = 'asc' 
        THEN unaccent(lower(final.subtopic_name)) 
    END ASC,
    CASE 
        WHEN p_order_column = 'subtopic' AND p_order_direction = 'desc' 
        THEN unaccent(lower(final.subtopic_name)) 
    END DESC,

    CASE 
        WHEN p_order_column = 'year' AND p_order_direction = 'asc' 
        THEN final.sort_year_asc
    END ASC,
    CASE 
        WHEN p_order_column = 'year' AND p_order_direction = 'asc' 
        THEN final.sort_version_asc
    END ASC,
    CASE 
        WHEN p_order_column = 'year' AND p_order_direction = 'desc' 
        THEN final.sort_year_desc
    END DESC,
    CASE 
        WHEN p_order_column = 'year' AND p_order_direction = 'desc' 
        THEN final.sort_version_desc
    END DESC,

    unaccent(lower(final.course_name)) ASC,
    unaccent(lower(final.topic_name)) ASC,
    unaccent(lower(final.subtopic_name)) ASC
    LIMIT p_perpage
    OFFSET (COALESCE(p_npage, 1) - 1) * p_perpage;

END;
$$;


ALTER FUNCTION odiseo.fn_frequent_subtopics_list(p_option_id bigint, p_start_year integer, p_end_year integer, p_areas jsonb, p_university_id smallint, p_course_id smallint, p_company_id integer, p_user_id bigint, p_perpage integer, p_npage integer, p_order_column character varying, p_order_direction character varying) OWNER TO postgres;

--
