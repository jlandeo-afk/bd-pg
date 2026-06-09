-- Function: exams.fn_get_exam_usage_stats(smallint, bigint, smallint, bigint, boolean)

--

CREATE FUNCTION exams.fn_get_exam_usage_stats(p_type_material_id smallint, p_material_id bigint, p_week smallint, p_user_id bigint, p_force_regenerate boolean DEFAULT false) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
                            DECLARE
                                v_result JSONB;
                                v_detail_id BIGINT;
                                v_global_stats_id BIGINT;
                                v_area_stats_id BIGINT;
                                v_area_json JSONB;
                            BEGIN

                                SELECT id INTO v_detail_id
                                FROM academic.detail_week_type_mat
                                WHERE material_id = p_material_id
                                AND type_material_id = p_type_material_id
                                AND week = p_week
                                AND fl_status IS TRUE
                                LIMIT 1;

                                IF v_detail_id IS NULL THEN
                                    RETURN '[]'::jsonb;
                                END IF;

                                SELECT id INTO v_global_stats_id
                                FROM material_exam_stats_global
                                WHERE detail_week_type_mat_id = v_detail_id
                                AND deleted_at IS NULL
                                LIMIT 1;

                                IF v_global_stats_id IS NOT NULL AND p_force_regenerate IS TRUE THEN
                                    DELETE FROM material_exam_stats_global WHERE id = v_global_stats_id;
                                    v_global_stats_id := NULL;
                                END IF;

                                -- Bloque de lectura de caché (Ya incluía los IDs en tu código original, se mantienen)
                                IF v_global_stats_id IS NOT NULL THEN
                                    SELECT jsonb_build_object(
                                        'number_pages', g.number_pages,
                                        'pages_exam_area', COALESCE(g.pages_details, '[]'::jsonb),
                                        'total_questions', g.total_questions,
                                        'new_questions', g.new_questions,
                                        'repeated_year', g.repeated_year,
                                        'repeated_history', g.repeated_history,
                                        'repeated_area', COALESCE(g.repeated_area, 0), 
                                        'details', COALESCE((
                                            SELECT jsonb_agg(
                                                jsonb_build_object(
                                                    'name', a.area_name,
                                                    'area_id', a.area_id,
                                                    'total_questions', a.total_questions,
                                                    'new_questions', a.new_questions,
                                                    'repeated_year', a.repeated_year,
                                                    'repeated_history', a.repeated_history,
                                                    'repeated_area', COALESCE(a.repeated_area, 0),
                                                    'questions_new_questions', COALESCE(a.question_details->'questions_new_questions', '[]'::jsonb),
                                                    'questions_repeated_year', COALESCE(a.question_details->'questions_repeated_year', '[]'::jsonb),
                                                    'questions_repeated_history', COALESCE(a.question_details->'questions_repeated_history', '[]'::jsonb),
                                                    'questions_repeated_area', COALESCE(a.question_details->'questions_repeated_area', '[]'::jsonb),

                                                    'details', COALESCE((
                                                        SELECT jsonb_agg(
                                                            jsonb_build_object(
                                                                'name', c.course_name,
                                                                'course_id', c.course_id,
                                                                'total_questions', c.total_questions,
                                                                'new_questions', c.new_questions,
                                                                'repeated_year', c.repeated_year,
                                                                'repeated_history', c.repeated_history,
                                                                'repeated_area', COALESCE(c.repeated_area, 0),
                                                                'questions_new_questions', COALESCE(c.question_details->'questions_new_questions', '[]'::jsonb),
                                                                'questions_repeated_year', COALESCE(c.question_details->'questions_repeated_year', '[]'::jsonb),
                                                                'questions_repeated_history', COALESCE(c.question_details->'questions_repeated_history', '[]'::jsonb),
                                                                'questions_repeated_area', COALESCE(c.question_details->'questions_repeated_area', '[]'::jsonb)
                                                            ) ORDER BY c.course_name ASC
                                                        )
                                                        FROM material_exam_stats_area_courses c
                                                        WHERE c.area_stats_id = a.id
                                                        AND c.deleted_at IS NULL
                                                    ), '[]'::jsonb)
                                                ) ORDER BY a.area_name ASC
                                            )
                                            FROM material_exam_stats_areas a
                                            WHERE a.material_exam_stats_global_id = g.id
                                            AND a.deleted_at IS NULL
                                        ), '[]'::jsonb)
                                    ) INTO v_result
                                    FROM material_exam_stats_global g
                                    WHERE g.id = v_global_stats_id;

                                    RETURN v_result;
                                END IF;

                                -- Inicio del cálculo
                                WITH material_details AS (
                                    SELECT cycle_id, university_id, company_id
                                    FROM material
                                    WHERE id = p_material_id AND fl_status IS TRUE
                                    LIMIT 1
                                ),
                                detail_target AS (
                                    SELECT v_detail_id AS id
                                ), pages_breakdown_calc AS (
                                    SELECT 
                                        COALESCE(MAX(meaw.number_pages), 0) as max_pages,
                                        COALESCE(
                                            jsonb_agg(
                                                jsonb_build_object(
                                                    'name', COALESCE(ga.description, 'General'),
                                                    'number_pages', COALESCE(meaw.number_pages, 0)
                                                ) ORDER BY ga.description ASC
                                            ), 
                                        '[]'::jsonb) as pages_json
                                    FROM material_exam_area_week meaw
                                    LEFT JOIN exam_area ga ON ga.id = meaw.area_id 
                                    WHERE meaw.week_type_material_id = (SELECT id FROM detail_target)
                                    AND meaw.fl_status = TRUE
                                ), year_cycle_material AS (
                                    SELECT year
                                    FROM cycle
                                    WHERE id = (SELECT cycle_id FROM material_details) AND fl_status IS TRUE
                                ), material_exam_question_data AS (
                                    SELECT
                                        meq.id,
                                        meq.material_exam_area_week_id,
                                        meq.course_id,
                                        c.name AS course_name,
                                        a.id AS area_id,
                                        UPPER(a.description) AS area_desc,
                                        meq.question_id,
                                        NULL::bigint as parent_question_id,
                                        ea.id exam_area_id,
                                        ea.description exam_area_description
                                    FROM material_exam_question meq 
                                    JOIN material_exam_area_week meaw ON meaw.id = meq.material_exam_area_week_id 
                                    JOIN exam_area ea ON ea.id = meaw.area_id 
                                    JOIN course c ON c.id = meq.course_id
                                    JOIN area a ON c.area_id = a.id
                                    WHERE meaw.week_type_material_id = (SELECT id FROM detail_target)
                                    AND meq.fl_status = true
                                    UNION ALL
                                    SELECT
                                        mepq.id,
                                        mepq.material_exam_area_week_id,
                                        mepq.course_id,
                                        c.name AS course_name,
                                        a.id AS area_id,
                                        UPPER(a.description) AS area_desc,
                                        expanded.question_id, 
                                        mepq.parent_question_id,
                                        ea.id exam_area_id,
                                        ea.description exam_area_description
                                    FROM material_exam_parent_question mepq 
                                    JOIN material_exam_area_week meaw ON meaw.id = mepq.material_exam_area_week_id
                                    JOIN exam_area ea ON ea.id = meaw.area_id 
                                    JOIN course c ON c.id = mepq.course_id
                                    JOIN area a ON c.area_id = a.id
                                    CROSS JOIN LATERAL jsonb_to_recordset(
                                        COALESCE(mepq.subquestion, '[]'::jsonb)
                                    ) AS expanded(question_id BIGINT)
                                    WHERE mepq.parent_question_id IS NOT NULL 
                                    AND mepq.deleted_at IS NULL
                                    AND meaw.week_type_material_id = (SELECT id FROM detail_target)
                                ), questions_history_questions AS (
                                    SELECT
                                        mbq.question_id,
                                        COUNT(qhc.id) AS total_history_count,
                                        MAX(EXTRACT(YEAR FROM qhc.start_date)) AS last_seen_year
                                    FROM material_exam_question_data mbq
                                    LEFT JOIN (
                                        SELECT
                                            qhc.id,
                                            c.id AS cycle_id,
                                            c.start_date,
                                            qhc.question_id
                                        FROM question_history_cycle qhc
                                        JOIN cycle c ON qhc.cycle_id = c.id
                                        WHERE c.company_id = (select company_id from material_details)
                                            AND qhc.fl_status IS TRUE
                                            AND qhc.cycle_id <> (SELECT cycle_id FROM material_details)
                                            AND c.fl_status IS TRUE
                                            AND EXTRACT(YEAR FROM c.start_date) <= (SELECT ycm.year FROM year_cycle_material ycm)
                                    ) qhc ON mbq.question_id = qhc.question_id
                                    WHERE mbq.parent_question_id IS NULL
                                    GROUP BY mbq.question_id
                                ), question_history_parent AS (
                                    SELECT
                                        mbq.question_id,
                                        COUNT(qhc.id) AS total_history_count,
                                        MAX(EXTRACT(YEAR FROM qhc.start_date)) AS last_seen_year
                                    FROM material_exam_question_data mbq
                                    LEFT JOIN (
                                        SELECT
                                            qhuepq.id,
                                            c.id AS cycle_id,
                                            c.start_date,
                                            qhuepq.question_id
                                        FROM question_history_usage_exam_parent_question qhuepq 
                                        JOIN material_exam_area_week meaw ON meaw.id = qhuepq.material_exam_area_week_id 
                                        JOIN detail_week_type_mat dwtm ON dwtm.id = meaw.week_type_material_id 
                                        JOIN material m ON m.id = dwtm.material_id 
                                        JOIN cycle c ON c.id = m.cycle_id 
                                        WHERE c.company_id = (select company_id from material_details)
                                        AND c.id <> (SELECT cycle_id FROM material_details)
                                        AND c.fl_status IS TRUE
                                        AND EXTRACT(YEAR FROM c.start_date) <= (SELECT ycm.year FROM year_cycle_material ycm)
                                    ) qhc ON mbq.question_id = qhc.question_id
                                    WHERE mbq.parent_question_id IS NOT NULL
                                    GROUP BY mbq.question_id
                                ),
                                questions_history_stats AS (
                                    SELECT * FROM questions_history_questions
                                    UNION ALL
                                    SELECT * FROM question_history_parent
                                ),
                                classified_questions AS (
                                    SELECT
                                        mbq.area_id,
                                        mbq.area_desc,
                                        mbq.course_id,
                                        mbq.course_name,
                                        mbq.question_id,
                                        q.code AS question_code,
                                        mbq.exam_area_id,
                                        mbq.exam_area_description,
                                        CASE
                                            WHEN stats.total_history_count = 0
                                                OR (ycm.year - stats.last_seen_year) > (select number_years_to_consider_question_repeated from advanced_settings LIMIT 1) THEN 'NUEVA'
                                            WHEN (ycm.year - stats.last_seen_year) = 0 THEN 'REPETIDA_LECTIVO'
                                            ELSE 'REPETIDA_ANTERIOR'
                                        END AS status_code,
                                        ROW_NUMBER() OVER(PARTITION BY mbq.area_desc, mbq.course_name, mbq.question_id ORDER BY mbq.id) as appearance_num
                                    FROM material_exam_question_data mbq
                                    JOIN questions_history_stats stats ON mbq.question_id = stats.question_id
                                    JOIN question q ON q.id = mbq.question_id
                                    CROSS JOIN year_cycle_material ycm
                                    WHERE q.status IN ('VERI', 'APRB')
                                ), repeated_questions_details AS (
                                    SELECT 
                                        course_id,
                                        jsonb_agg(
                                            jsonb_build_object(
                                                'id', question_id, 
                                                'code', question_code, 
                                                'exam_areas', area_names
                                            )
                                        ) AS list_rep_area_json
                                    FROM (
                                        SELECT 
                                            course_id,
                                            question_id,
                                            question_code,
                                            array_agg(exam_area_description) AS area_names
                                        FROM classified_questions
                                        GROUP BY course_id, question_id, question_code
                                        HAVING COUNT(*) > 1
                                    ) sub_grouped
                                    GROUP BY course_id
                                ), stats_by_course AS (
                                    SELECT
                                        cq.area_id,
                                        cq.area_desc,
                                        cq.course_id,
                                        cq.course_name,
                                        SUM(CASE WHEN status_code = 'NUEVA' THEN 1 ELSE 0 END) AS nuevas,
                                        SUM(CASE WHEN status_code = 'REPETIDA_LECTIVO' THEN 1 ELSE 0 END) AS rep_lectivo,
                                        SUM(CASE WHEN status_code = 'REPETIDA_ANTERIOR' THEN 1 ELSE 0 END) AS rep_anterior,
                                        COUNT(DISTINCT CASE WHEN appearance_num > 1 THEN question_id END) AS rep_area,
                                        COUNT(*) AS total_curso,
                                        COALESCE(jsonb_agg(jsonb_build_object('id', question_id, 'code', question_code, 'exam_area_id', exam_area_id, 'exam_area_description', exam_area_description)) FILTER (WHERE status_code = 'NUEVA'), '[]'::jsonb) AS list_nuevas,
                                        COALESCE(jsonb_agg(jsonb_build_object('id', question_id, 'code', question_code, 'exam_area_id', exam_area_id, 'exam_area_description', exam_area_description)) FILTER (WHERE status_code = 'REPETIDA_LECTIVO'), '[]'::jsonb) AS list_rep_lectivo,
                                        COALESCE(jsonb_agg(jsonb_build_object('id', question_id, 'code', question_code, 'exam_area_id', exam_area_id, 'exam_area_description', exam_area_description)) FILTER (WHERE status_code = 'REPETIDA_ANTERIOR'), '[]'::jsonb) AS list_rep_anterior,
                                        COALESCE(rqd.list_rep_area_json, '[]'::jsonb) AS list_rep_area
                                    FROM classified_questions cq
                                    LEFT JOIN repeated_questions_details rqd ON rqd.course_id = cq.course_id
                                    GROUP BY 
                                        cq.area_id, 
                                        cq.area_desc, 
                                        cq.course_id, 
                                        cq.course_name,
                                        rqd.list_rep_area_json
                                ), stats_by_area AS (
                                    SELECT
                                        s.area_id,
                                        s.area_desc,
                                        SUM(s.nuevas) AS area_nuevas,
                                        SUM(s.rep_lectivo) AS area_lectivo,
                                        SUM(s.rep_anterior) AS area_anterior,
                                        SUM(s.rep_area) AS area_rep_area,
                                        SUM(s.total_curso) AS area_total,
                                        jsonb_agg(
                                            jsonb_build_object(
                                                'name', s.course_name,
                                                'course_id', s.course_id,
                                                'total_questions', s.total_curso,
                                                'new_questions', s.nuevas,
                                                'repeated_year', s.rep_lectivo,
                                                'repeated_history', s.rep_anterior,
                                                'repeated_area', s.rep_area,
                                                'questions_new_questions', s.list_nuevas,
                                                'questions_repeated_year', s.list_rep_lectivo,
                                                'questions_repeated_history', s.list_rep_anterior,
                                                'questions_repeated_area', s.list_rep_area
                                            ) ORDER BY s.course_name ASC
                                        ) AS cursos_json
                                    FROM stats_by_course s
                                    GROUP BY s.area_id, s.area_desc
                                )
                                SELECT jsonb_build_object(
                                    'number_pages', (SELECT max_pages FROM pages_breakdown_calc),
                                    'pages_details', (SELECT pages_json FROM pages_breakdown_calc),
                                    'total_questions', COALESCE(SUM(area_total), 0),
                                    'new_questions', COALESCE(SUM(area_nuevas), 0),
                                    'repeated_year', COALESCE(SUM(area_lectivo), 0),
                                    'repeated_history', COALESCE(SUM(area_anterior), 0),
                                    'repeated_area', COALESCE(SUM(area_rep_area), 0),
                                    'details', COALESCE(
                                        jsonb_agg(
                                            jsonb_build_object(
                                                'name', area_desc,
                                                'area_id', area_id,
                                                'total_questions', area_total,
                                                'new_questions', area_nuevas,
                                                'repeated_year', area_lectivo,
                                                'repeated_history', area_anterior,
                                                'repeated_area', area_rep_area,
                                                'questions_new_questions', (SELECT jsonb_agg(elems) FROM (SELECT jsonb_array_elements(value->'questions_new_questions') as elems FROM jsonb_array_elements(cursos_json) as value) t),
                                                'questions_repeated_year', (SELECT jsonb_agg(elems) FROM (SELECT jsonb_array_elements(value->'questions_repeated_year') as elems FROM jsonb_array_elements(cursos_json) as value) t),
                                                'questions_repeated_history', (SELECT jsonb_agg(elems) FROM (SELECT jsonb_array_elements(value->'questions_repeated_history') as elems FROM jsonb_array_elements(cursos_json) as value) t),
                                                'questions_repeated_area', (SELECT jsonb_agg(elems) FROM (SELECT jsonb_array_elements(value->'questions_repeated_area') as elems FROM jsonb_array_elements(cursos_json) as value) t),
                                                'details', cursos_json
                                            ) ORDER BY area_desc ASC
                                        ), '[]'::jsonb
                                    )
                                ) INTO v_result
                                FROM stats_by_area;

                                INSERT INTO material_exam_stats_global (
                                    detail_week_type_mat_id,
                                    number_pages,
                                    pages_details,
                                    total_questions,
                                    new_questions,
                                    repeated_year,
                                    repeated_history,
                                    repeated_area, 
                                    created_by,
                                    updated_by,
                                    created_at,
                                    updated_at
                                ) VALUES (
                                    v_detail_id,
                                    COALESCE((v_result->>'number_pages')::SMALLINT, 0),
                                    COALESCE(v_result->'pages_details', '[]'::jsonb),
                                    COALESCE((v_result->>'total_questions')::SMALLINT, 0),
                                    COALESCE((v_result->>'new_questions')::SMALLINT, 0),
                                    COALESCE((v_result->>'repeated_year')::SMALLINT, 0),
                                    COALESCE((v_result->>'repeated_history')::SMALLINT, 0),
                                    COALESCE((v_result->>'repeated_area')::SMALLINT, 0),
                                    p_user_id,
                                    p_user_id,
                                    NOW(),
                                    NOW()
                                ) RETURNING id INTO v_global_stats_id;

                                FOR v_area_json IN SELECT * FROM jsonb_array_elements(v_result->'details')
                                LOOP
                                    INSERT INTO material_exam_stats_areas (
                                        material_exam_stats_global_id,
                                        area_name,
                                        area_id, 
                                        total_questions,
                                        new_questions,
                                        repeated_year,
                                        repeated_history,
                                        repeated_area, 
                                        question_details,
                                        created_at,
                                        updated_at
                                    ) VALUES (
                                        v_global_stats_id,
                                        v_area_json->>'name',
                                        (v_area_json->>'area_id')::BIGINT,
                                        (v_area_json->>'total_questions')::SMALLINT,
                                        (v_area_json->>'new_questions')::SMALLINT,
                                        (v_area_json->>'repeated_year')::SMALLINT,
                                        (v_area_json->>'repeated_history')::SMALLINT,
                                        (v_area_json->>'repeated_area')::SMALLINT,
                                        jsonb_build_object(
                                            'questions_new_questions', COALESCE(NULLIF(v_area_json->'questions_new_questions', 'null'::jsonb), '[]'::jsonb),
                                            'questions_repeated_year', COALESCE(NULLIF(v_area_json->'questions_repeated_year', 'null'::jsonb), '[]'::jsonb),
                                            'questions_repeated_history', COALESCE(NULLIF(v_area_json->'questions_repeated_history', 'null'::jsonb), '[]'::jsonb),
                                            'questions_repeated_area', COALESCE(NULLIF(v_area_json->'questions_repeated_area', 'null'::jsonb), '[]'::jsonb)
                                        ),
                                        NOW(),
                                        NOW()
                                    ) RETURNING id INTO v_area_stats_id;
                                
                                    INSERT INTO material_exam_stats_area_courses ( 
                                        area_stats_id,
                                        course_name,
                                        course_id, -- Insertando course_id
                                        total_questions,
                                        new_questions,
                                        repeated_year,
                                        repeated_history,
                                        repeated_area,
                                        question_details,
                                        created_at,
                                        updated_at
                                    )
                                    SELECT
                                        v_area_stats_id,
                                        value->>'name',
                                        (value->>'course_id')::BIGINT,
                                        (value->>'total_questions')::SMALLINT,
                                        (value->>'new_questions')::SMALLINT,
                                        (value->>'repeated_year')::SMALLINT,
                                        (value->>'repeated_history')::SMALLINT,
                                        (value->>'repeated_area')::SMALLINT,
                                        jsonb_build_object(
                                            'questions_new_questions', COALESCE(NULLIF(value->'questions_new_questions', 'null'::jsonb), '[]'::jsonb),
                                            'questions_repeated_year', COALESCE(NULLIF(value->'questions_repeated_year', 'null'::jsonb), '[]'::jsonb),
                                            'questions_repeated_history', COALESCE(NULLIF(value->'questions_repeated_history', 'null'::jsonb), '[]'::jsonb),
                                            'questions_repeated_area', COALESCE(NULLIF(value->'questions_repeated_area', 'null'::jsonb), '[]'::jsonb)
                                        ),
                                        NOW(),
                                        NOW()
                                    FROM jsonb_array_elements(v_area_json->'details') as value;
                                END LOOP;

                                RETURN v_result;
                            END;
                            $$;


ALTER FUNCTION exams.fn_get_exam_usage_stats(p_type_material_id smallint, p_material_id bigint, p_week smallint, p_user_id bigint, p_force_regenerate boolean) OWNER TO postgres;

--
