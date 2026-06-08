-- Function: odiseo.fn_get_detail_exam_questions_by_area_courses(integer, integer, character varying, character varying, smallint, smallint, bigint, smallint, character varying)

--

CREATE FUNCTION odiseo.fn_get_detail_exam_questions_by_area_courses(p_perpage integer, p_npage integer, p_search character varying, p_source character varying, p_course_id smallint, p_type_material_id smallint, p_material_id bigint, p_week smallint, p_area character varying) RETURNS TABLE(area_name character varying, id bigint, description text, status character varying, course character varying, code character varying, source text, is_duplicated boolean, type_question text, exam_area character varying, exam_areas jsonb, total bigint)
    LANGUAGE plpgsql
    AS $$
                        DECLARE
                            offset_val INTEGER;
                            v_detail_id BIGINT;
                        BEGIN
                            offset_val := p_perpage * (p_npage - 1);

                            SELECT dwtm.id INTO v_detail_id
                            FROM detail_week_type_mat dwtm
                            WHERE dwtm.material_id = p_material_id
                            AND dwtm.type_material_id = p_type_material_id
                            AND dwtm.week = p_week
                            AND dwtm.fl_status IS TRUE
                            LIMIT 1;

                            RETURN QUERY
                            WITH exploded_questions AS (
                                SELECT
                                    mac.id AS material_exam_stat_course_id,
                                    mac.area_stats_id,
                                    ma.area_name,
                                    q.id AS question_id,
                                    q.short_description,
                                    q.code,
                                    q.status,
                                    c.name AS course,
                                    mac.course_id,
                                    'new_questions' AS source,
                                    FALSE AS is_duplicated,
                                    CASE
                                        WHEN q.parent_id IS NULL THEN 'P'
                                        ELSE 'S'
                                    END AS type_question,
                                    ea.description exam_area,
                                    NULL::jsonb AS exam_areas
                                FROM material_exam_stats_area_courses mac
                                JOIN material_exam_stats_areas ma ON ma.id = mac.area_stats_id
                                JOIN LATERAL jsonb_array_elements(mac.question_details->'questions_new_questions') qj ON TRUE
                                JOIN question q ON q.id = (qj->>'id')::BIGINT
                                JOIN exam_area ea ON ea.id = (qj->>'exam_area_id')::BIGINT
                                JOIN course c ON c.id = q.course_id
                                JOIN material_exam_stats_global mesg ON mesg.id = ma.material_exam_stats_global_id 
                                JOIN detail_week_type_mat dwtm ON dwtm.id = mesg.detail_week_type_mat_id
                                WHERE dwtm.id = v_detail_id

                                UNION ALL

                                -- REPETIDAS POR ÁREA
                                SELECT
                                    mac.id,
                                    mac.area_stats_id,
                                    ma.area_name,
                                    q.id AS question_id,
                                    q.short_description,
                                    q.code,
                                    q.status,
                                    c.name AS course,
                                    mac.course_id,
                                    'repeated_area',
                                    TRUE,
                                    CASE
                                        WHEN q.parent_id IS NULL THEN 'P'
                                        ELSE 'S'
                                    END AS type_question,
                                    NULL::varchar,
                                    (qj->>'exam_areas')::jsonb
                                FROM material_exam_stats_area_courses mac
                                JOIN material_exam_stats_areas ma ON ma.id = mac.area_stats_id
                                JOIN LATERAL jsonb_array_elements(mac.question_details->'questions_repeated_area') qj ON TRUE
                                JOIN question q ON q.id = (qj->>'id')::BIGINT
                                JOIN course c ON c.id = q.course_id
                                JOIN material_exam_stats_global mesg ON mesg.id = ma.material_exam_stats_global_id 
                                JOIN detail_week_type_mat dwtm ON dwtm.id = mesg.detail_week_type_mat_id
                                WHERE dwtm.id = v_detail_id

                                UNION ALL

                                -- REPETIDAS POR AÑO
                                SELECT
                                    mac.id,
                                    mac.area_stats_id,
                                    ma.area_name,
                                    q.id AS question_id,
                                    q.short_description,
                                    q.code,
                                    q.status,
                                    c.name AS course,
                                    mac.course_id,
                                    'repeated_year',
                                    TRUE,
                                    CASE
                                        WHEN q.parent_id IS NULL THEN 'P'
                                        ELSE 'S'
                                    END AS type_question,
                                    ea.description exam_area,
                                    NULL::jsonb AS exam_areas
                                FROM material_exam_stats_area_courses mac
                                JOIN material_exam_stats_areas ma ON ma.id = mac.area_stats_id
                                JOIN LATERAL jsonb_array_elements(mac.question_details->'questions_repeated_year') qj ON TRUE
                                JOIN question q ON q.id = (qj->>'id')::BIGINT
                                JOIN exam_area ea ON ea.id = (qj->>'exam_area_id')::BIGINT
                                JOIN course c ON c.id = q.course_id
                                JOIN material_exam_stats_global mesg ON mesg.id = ma.material_exam_stats_global_id 
                                JOIN detail_week_type_mat dwtm ON dwtm.id = mesg.detail_week_type_mat_id
                                WHERE dwtm.id = v_detail_id

                                UNION ALL

                                -- REPETIDAS HISTÓRICAS
                                SELECT
                                    mac.id,
                                    mac.area_stats_id,
                                    ma.area_name,
                                    q.id AS question_id,
                                    q.short_description,
                                    q.code,
                                    q.status,
                                    c.name AS course,
                                    mac.course_id,
                                    'repeated_history',
                                    TRUE,
                                    CASE
                                        WHEN q.parent_id IS NULL THEN 'P'
                                        ELSE 'S'
                                    END AS type_question,
                                    ea.description exam_area,
                                    NULL::jsonb AS exam_areas
                                FROM material_exam_stats_area_courses mac
                                JOIN material_exam_stats_areas ma ON ma.id = mac.area_stats_id
                                JOIN LATERAL jsonb_array_elements(mac.question_details->'questions_repeated_history') qj ON TRUE
                                JOIN question q ON q.id = (qj->>'id')::BIGINT
                                JOIN exam_area ea ON ea.id = (qj->>'exam_area_id')::BIGINT
                                JOIN course c ON c.id = q.course_id
                                JOIN material_exam_stats_global mesg ON mesg.id = ma.material_exam_stats_global_id 
                                JOIN detail_week_type_mat dwtm ON dwtm.id = mesg.detail_week_type_mat_id
                                WHERE dwtm.id = v_detail_id
                            ),
                            filtered AS (
                                SELECT *
                                FROM exploded_questions eq
                                WHERE
                                    (p_search IS NULL OR LOWER(eq.code) LIKE '%' || LOWER(p_search) || '%')
                                    AND CASE
                                        WHEN p_source IS NULL THEN eq.source != 'repeated_area'
                                        ELSE eq.source = p_source
                                    END
                                    AND (p_course_id IS NULL OR eq.course_id = p_course_id)
                                    AND eq.area_name = p_area
                                ORDER BY eq.exam_area, eq.course_id, eq.question_id
                            )
                            SELECT
                                f.area_name,
                                f.question_id id,
                                f.short_description description,
                                f.status,
                                f.course,
                                f.code,
                                f.source,
                                f.is_duplicated,
                                f.type_question,
                                f.exam_area,
                                f.exam_areas,
                                COUNT(*) OVER () AS total
                            FROM filtered f
                            LIMIT p_perpage OFFSET offset_val;

                        END;
                        $$;


ALTER FUNCTION odiseo.fn_get_detail_exam_questions_by_area_courses(p_perpage integer, p_npage integer, p_search character varying, p_source character varying, p_course_id smallint, p_type_material_id smallint, p_material_id bigint, p_week smallint, p_area character varying) OWNER TO postgres;

--
