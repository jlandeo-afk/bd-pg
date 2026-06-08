-- Function: odiseo.fn_get_detail_exam_questions_by_areas(integer, integer, character varying, character varying, smallint, smallint, bigint, smallint)

--

CREATE FUNCTION odiseo.fn_get_detail_exam_questions_by_areas(p_perpage integer, p_npage integer, p_search character varying, p_source character varying, p_area_id smallint, p_type_material_id smallint, p_material_id bigint, p_week smallint) RETURNS TABLE(area character varying, area_id bigint, id bigint, description text, status character varying, course character varying, code character varying, source text, is_duplicated boolean, type_question text, exam_area character varying, exam_areas jsonb, total bigint)
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
                                -- 1. NEW QUESTIONS
                                SELECT
                                    m.id,
                                    m.area_name,
                                    m.area_id,
                                    q.id AS question_id,
                                    q.short_description,
                                    q.code,
                                    q.status,
                                    c.name course,
                                    c.id course_id,
                                    'new_questions' AS source,
                                    FALSE AS is_duplicated,
                                    CASE
                                        WHEN q.parent_id IS NULL THEN 'P'
                                        ELSE 'S'
                                    END AS type_question,
                                    ea.description::varchar AS exam_area, 
                                    NULL::jsonb AS exam_areas            
                                FROM material_exam_stats_areas m
                                JOIN LATERAL jsonb_array_elements(m.question_details->'questions_new_questions') qj ON TRUE
                                JOIN question q ON q.id = (qj->>'id')::BIGINT
                                JOIN exam_area ea ON ea.id = (qj->>'exam_area_id')::BIGINT
                                JOIN course c ON c.id = q.course_id
                                JOIN material_exam_stats_global mesg ON mesg.id = m.material_exam_stats_global_id 
                                JOIN detail_week_type_mat dwtm ON dwtm.id = mesg.detail_week_type_mat_id
                                WHERE dwtm.id = v_detail_id

                                UNION ALL

                                -- 2. REPETIDAS POR ÁREA
                                SELECT
                                    m.id,
                                    m.area_name,
                                    m.area_id,
                                    q.id AS question_id,
                                    q.short_description,
                                    q.code,
                                    q.status,
                                    c.name course,
                                    c.id course_id,
                                    'repeated_area',
                                    TRUE,
                                    CASE
                                        WHEN q.parent_id IS NULL THEN 'P'
                                        ELSE 'S'
                                    END AS type_question,
                                    NULL::varchar,          
                                    (qj->>'exam_areas')::jsonb  
                                FROM material_exam_stats_areas m
                                JOIN LATERAL jsonb_array_elements(m.question_details->'questions_repeated_area') qj ON TRUE
                                JOIN question q ON q.id = (qj->>'id')::BIGINT
                                JOIN course c ON c.id = q.course_id
                                JOIN material_exam_stats_global mesg ON mesg.id = m.material_exam_stats_global_id 
                                JOIN detail_week_type_mat dwtm ON dwtm.id = mesg.detail_week_type_mat_id
                                WHERE dwtm.id = v_detail_id

                                UNION ALL

                                -- 3. REPETIDAS POR AÑO
                                SELECT
                                    m.id,
                                    m.area_name,
                                    m.area_id,
                                    q.id AS question_id,
                                    q.short_description,
                                    q.code,
                                    q.status,
                                    c.name course,
                                    c.id course_id,
                                    'repeated_year',
                                    TRUE,
                                    CASE
                                        WHEN q.parent_id IS NULL THEN 'P'
                                        ELSE 'S'
                                    END AS type_question,
                                    ea.description::varchar,    
                                    NULL::jsonb                
                                FROM material_exam_stats_areas m
                                JOIN LATERAL jsonb_array_elements(m.question_details->'questions_repeated_year') qj ON TRUE
                                JOIN question q ON q.id = (qj->>'id')::BIGINT
                                JOIN exam_area ea ON ea.id = (qj->>'exam_area_id')::BIGINT
                                JOIN course c ON c.id = q.course_id
                                JOIN material_exam_stats_global mesg ON mesg.id = m.material_exam_stats_global_id 
                                JOIN detail_week_type_mat dwtm ON dwtm.id = mesg.detail_week_type_mat_id
                                WHERE dwtm.id = v_detail_id

                                UNION ALL

                                -- 4. REPETIDAS HISTÓRICAS
                                SELECT
                                    m.id,
                                    m.area_name,
                                    m.area_id,
                                    q.id AS question_id,
                                    q.short_description,
                                    q.code,
                                    q.status,
                                    c.name course,
                                    c.id course_id,
                                    'repeated_history',
                                    TRUE,
                                    CASE
                                        WHEN q.parent_id IS NULL THEN 'P'
                                        ELSE 'S'
                                    END AS type_question,
                                    ea.description::varchar,   
                                    NULL::jsonb     
                                FROM material_exam_stats_areas m
                                JOIN LATERAL jsonb_array_elements(m.question_details->'questions_repeated_history') qj ON TRUE
                                JOIN question q ON q.id = (qj->>'id')::BIGINT
                                JOIN exam_area ea ON ea.id = (qj->>'exam_area_id')::BIGINT
                                JOIN course c ON c.id = q.course_id
                                JOIN material_exam_stats_global mesg ON mesg.id = m.material_exam_stats_global_id 
                                JOIN detail_week_type_mat dwtm ON dwtm.id = mesg.detail_week_type_mat_id
                                WHERE dwtm.id = v_detail_id
                            ),
                            filtered AS (
                                SELECT 
                                    *
                                FROM exploded_questions eq
                                WHERE
                                    (p_search IS NULL OR LOWER(eq.code) LIKE '%' || LOWER(p_search) || '%')
                                    AND CASE
                                        WHEN p_source IS NULL THEN eq.source != 'repeated_area'
                                        ELSE eq.source = p_source
                                    END
                                    AND (p_area_id IS NULL OR eq.area_id = p_area_id)
                                ORDER BY eq.exam_area, eq.course_id, eq.id
                            )
                            SELECT
                                f.area_name area,
                                f.area_id,
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


ALTER FUNCTION odiseo.fn_get_detail_exam_questions_by_areas(p_perpage integer, p_npage integer, p_search character varying, p_source character varying, p_area_id smallint, p_type_material_id smallint, p_material_id bigint, p_week smallint) OWNER TO postgres;

--
