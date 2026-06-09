-- Function: questions.fn_get_question_usage_stats(smallint, bigint, smallint, smallint, bigint, boolean)

--

CREATE FUNCTION questions.fn_get_question_usage_stats(p_type_material_id smallint, p_material_id bigint, p_start_week smallint, p_end_week smallint, p_user_id bigint, p_force_regenerate boolean DEFAULT false) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_result JSONB;
                v_ballot_id BIGINT;
                v_global_stats_id BIGINT;
                v_area_stats_id BIGINT;
                v_area_json JSONB;
            BEGIN
                -- =================================================================================
                -- PASO 0: Obtener dinámicamente el material_per_period_ballot_id
                -- =================================================================================
                SELECT b.id INTO v_ballot_id
                FROM material_per_period mp
                JOIN material_per_period_ballot b ON b.material_per_period_id = mp.id
                WHERE mp.material_id = p_material_id
                  AND mp.type_material_id = p_type_material_id
                  AND b.start_week = p_start_week
                  AND b.end_week = p_end_week
                  AND mp.deleted_at IS NULL
                  AND b.deleted_at IS NULL
                LIMIT 1;

                IF v_ballot_id IS NULL THEN
                    RETURN '[]'::jsonb;
                END IF;

                -- =================================================================================
                -- PASO 1: Verificar si ya existe data guardada
                -- =================================================================================
                SELECT id INTO v_global_stats_id
                FROM material_ballot_stats_global
                WHERE material_per_period_ballot_id = v_ballot_id
                LIMIT 1;

                -- =================================================================================
                -- PASO 2: Lógica de Regeneración (Borrar padre borra hijos por CASCADE)
                -- =================================================================================
                IF v_global_stats_id IS NOT NULL AND p_force_regenerate IS TRUE THEN
                    DELETE FROM material_ballot_stats_global WHERE id = v_global_stats_id;
                    v_global_stats_id := NULL;
                END IF;

                -- =================================================================================
                -- PASO 3: Si existe Data, retornar estructura JSON desde las tablas
                -- =================================================================================
                IF v_global_stats_id IS NOT NULL THEN
                    SELECT jsonb_build_object(
                        'number_pages', g.number_pages,
                        'total_questions', g.total_questions,
                        'new_questions', g.new_questions,
                        'repeated_year', g.repeated_year,
                        'repeated_history', g.repeated_history,
                        'details', COALESCE((
                            SELECT jsonb_agg(
                                jsonb_build_object(
                                    'name', a.area_name,
                                    'total_questions', a.total_questions,
                                    'new_questions', a.new_questions,
                                    'repeated_year', a.repeated_year,
                                    'repeated_history', a.repeated_history,
                                    'details', COALESCE((
                                        SELECT jsonb_agg(
                                            jsonb_build_object(
                                                'name', c.course_name,
                                                'total_questions', c.total_questions,
                                                'new_questions', c.new_questions,
                                                'repeated_year', c.repeated_year,
                                                'repeated_history', c.repeated_history
                                            ) ORDER BY c.course_name ASC
                                        )
                                        FROM material_ballot_stats_area_courses c
                                        WHERE c.area_stats_id = a.id
                                    ), '[]'::jsonb)
                                ) ORDER BY a.area_name ASC
                            )
                            FROM material_ballot_stats_areas a
                            WHERE a.global_stats_id = g.id
                        ), '[]'::jsonb)
                    ) INTO v_result
                    FROM material_ballot_stats_global g
                    WHERE g.id = v_global_stats_id;

                    RETURN v_result;
                END IF;

                -- =================================================================================
                -- PASO 4: CALCULAR (Si no existe data guardada - Lógica Original)
                -- =================================================================================

                WITH prepare_type_material_ids AS (
                    SELECT
                    CASE WHEN EXISTS (
                        SELECT 1 FROM type_material tm
                        WHERE tm.parent_id = p_type_material_id) THEN
                        ARRAY (
                            SELECT tm.id FROM type_material tm WHERE tm.parent_id = p_type_material_id
                        )
                    ELSE
                        ARRAY[p_type_material_id]
                    END AS ids
                ), type_material_ids AS (
                    SELECT UNNEST(ids) AS id FROM prepare_type_material_ids
                ), material_details AS (
                    SELECT cycle_id, university_id, company_id
                    FROM material
                    WHERE id = p_material_id AND fl_status IS TRUE
                ),
                total_pages_calc AS (
                    SELECT COALESCE(SUM(mppbu.number_pages), 0) as pages_count
                    FROM material_per_period mpp
                    JOIN material_per_period_ballot mppb ON mppb.material_per_period_id = mpp.id
                    JOIN material_per_period_ballot_url mppbu ON mppbu.material_per_period_ballot_id = mppb.id
                    WHERE mpp.material_id = p_material_id
                    AND mpp.type_material_id = p_type_material_id
                    AND mppb.start_week >= p_start_week
                    AND mppb.end_week <= p_end_week
                    AND mppbu.type_url = 'without_solution'
                    AND mppb.deleted_at IS NULL
                    AND mpp.deleted_at IS NULL
                    AND mppbu.deleted_at IS NULL
                ),
                year_cycle_material AS (
                    SELECT year
                    FROM cycle
                    WHERE id = (SELECT cycle_id FROM material_details) AND fl_status IS TRUE
                ),
                detail_week_type_materia_ids AS (
                    SELECT dwtm.id
                    FROM detail_week_type_mat dwtm
                    WHERE dwtm.material_id = p_material_id
                    AND dwtm.type_material_id IN (SELECT tmi.id FROM type_material_ids tmi)
                    AND dwtm.week BETWEEN p_start_week AND p_end_week
                    AND dwtm.fl_status IS TRUE
                ),
                material_balot_question_data AS (
                    SELECT
                        mbq.id,
                        mbq.week_type_material_id,
                        mbq.course_id,
                        c.name AS course_name,
                        UPPER(a.description) AS area_desc,
                        COALESCE(mbq.question_id, mbs.question_id) AS question_id,
                        mbq.parent_question_id
                    FROM material_ballot_question AS mbq
                    INNER JOIN course c ON c.id = mbq.course_id
                    INNER JOIN area a ON c.area_id = a.id
                    LEFT JOIN material_ballot_subquestions mbs 
                        ON mbs.material_ballot_question_id = mbq.id AND mbs.fl_status IS TRUE
                    WHERE mbq.week_type_material_id IN (SELECT id FROM detail_week_type_materia_ids)
                    AND mbq.fl_status IS TRUE
                    AND c.fl_status IS TRUE
                    AND a.fl_status IS TRUE
                    AND (mbq.question_id IS NOT NULL OR mbs.question_id IS NOT NULL)
                ),
                questions_history_questions AS (
                    SELECT
                        mbq.question_id,
                        COUNT(qhc.id) AS total_history_count,
                        MAX(EXTRACT(YEAR FROM qhc.start_date)) AS last_seen_year
                    FROM material_balot_question_data mbq
                    LEFT JOIN (
                        SELECT
                            qhc.id,
                            c.id AS cycle_id,
                            c.description,
                            c.start_date,
                            qhc.question_id
                        FROM question_history_cycle qhc
                        JOIN cycle c ON qhc.cycle_id = c.id
                        WHERE c.company_id =(select company_id from material_details)
                            AND qhc.fl_status IS TRUE
                            AND qhc.cycle_id <> (SELECT cycle_id FROM material_details)
                            AND c.fl_status IS TRUE
                            AND EXTRACT(YEAR FROM c.start_date) <= (SELECT ycm.year FROM year_cycle_material ycm)
                    ) qhc ON mbq.question_id = qhc.question_id
                    WHERE mbq.parent_question_id IS NULL
                    GROUP BY mbq.question_id
                ),
                question_history_parent AS (
                    SELECT
                        mbq.question_id,
                        COUNT(qhc.id) AS total_history_count,
                        MAX(EXTRACT(YEAR FROM qhc.start_date)) AS last_seen_year
                    FROM material_balot_question_data mbq
                    LEFT JOIN (
                        SELECT
                            qhc.id,
                            c.id AS cycle_id,
                            c.description,
                            c.start_date,
                            qhc.question_id
                        FROM question_history_cycle qhc
                        JOIN cycle c ON qhc.cycle_id = c.id
                        WHERE c.company_id =(select company_id from material_details)
                            AND qhc.fl_status IS TRUE
                            AND qhc.cycle_id <> (SELECT cycle_id FROM material_details)
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
                        mbq.area_desc,
                        mbq.course_name,
                        CASE
                            WHEN stats.total_history_count = 0
                                OR (ycm.year - stats.last_seen_year) > (select number_years_to_consider_question_repeated from advanced_settings LIMIT 1) THEN 'NUEVA'
                            WHEN (ycm.year - stats.last_seen_year) = 0 THEN 'REPETIDA_LECTIVO'
                            ELSE 'REPETIDA_ANTERIOR'
                        END AS status_code
                    FROM material_balot_question_data mbq
                    JOIN questions_history_stats stats ON mbq.question_id = stats.question_id
                    CROSS JOIN year_cycle_material ycm
                ),
                stats_by_course AS (
                    SELECT
                        area_desc,
                        course_name,
                        SUM(CASE WHEN status_code = 'NUEVA' THEN 1 ELSE 0 END) AS nuevas,
                        SUM(CASE WHEN status_code = 'REPETIDA_LECTIVO' THEN 1 ELSE 0 END) AS rep_lectivo,
                        SUM(CASE WHEN status_code = 'REPETIDA_ANTERIOR' THEN 1 ELSE 0 END) AS rep_anterior,
                        COUNT(*) AS total_curso
                    FROM classified_questions
                    GROUP BY area_desc, course_name
                ),
                stats_by_area AS (
                    SELECT
                        area_desc,
                        SUM(nuevas) AS area_nuevas,
                        SUM(rep_lectivo) AS area_lectivo,
                        SUM(rep_anterior) AS area_anterior,
                        SUM(total_curso) AS area_total,
                        jsonb_agg(
                            jsonb_build_object(
                                'name', course_name,
                                'total_questions', total_curso,
                                'new_questions', nuevas,
                                'repeated_year', rep_lectivo,
                                'repeated_history', rep_anterior
                            ) ORDER BY course_name ASC
                        ) AS cursos_json
                    FROM stats_by_course
                    GROUP BY area_desc
                )
                SELECT jsonb_build_object(
                    'number_pages', (SELECT pages_count FROM total_pages_calc),
                    'total_questions', COALESCE(SUM(area_total), 0),
                    'new_questions', COALESCE(SUM(area_nuevas), 0),
                    'repeated_year', COALESCE(SUM(area_lectivo), 0),
                    'repeated_history', COALESCE(SUM(area_anterior), 0),
                    'details', COALESCE(
                        jsonb_agg(
                            jsonb_build_object(
                                'name', area_desc,
                                'total_questions', area_total,
                                'new_questions', area_nuevas,
                                'repeated_year', area_lectivo,
                                'repeated_history', area_anterior,
                                'details', cursos_json
                            ) ORDER BY area_desc ASC
                        ), '[]'::jsonb
                    )
                ) INTO v_result
                FROM stats_by_area;

                -- =================================================================================
                -- PASO 5: INSERTAR EL RESULTADO CALCULADO (Persistencia)
                -- =================================================================================

                INSERT INTO material_ballot_stats_global (
                    material_per_period_ballot_id,
                    number_pages,
                    total_questions,
                    new_questions,
                    repeated_year,
                    repeated_history,
                    created_by,
                    updated_by
                ) VALUES (
                    v_ballot_id,
                    COALESCE((v_result->>'number_pages')::SMALLINT, 0),
                    COALESCE((v_result->>'total_questions')::SMALLINT, 0),
                    COALESCE((v_result->>'new_questions')::SMALLINT, 0),
                    COALESCE((v_result->>'repeated_year')::SMALLINT, 0),
                    COALESCE((v_result->>'repeated_history')::SMALLINT, 0),
                    p_user_id,
                    p_user_id
                ) RETURNING id INTO v_global_stats_id;

                FOR v_area_json IN SELECT * FROM jsonb_array_elements(v_result->'details')
                LOOP
                    INSERT INTO material_ballot_stats_areas (
                        global_stats_id,
                        area_name,
                        total_questions,
                        new_questions,
                        repeated_year,
                        repeated_history
                    ) VALUES (
                        v_global_stats_id,
                        v_area_json->>'name',
                        (v_area_json->>'total_questions')::SMALLINT,
                        (v_area_json->>'new_questions')::SMALLINT,
                        (v_area_json->>'repeated_year')::SMALLINT,
                        (v_area_json->>'repeated_history')::SMALLINT
                    ) RETURNING id INTO v_area_stats_id;

                    INSERT INTO material_ballot_stats_area_courses ( 
                        area_stats_id,
                        course_name,
                        total_questions,
                        new_questions,
                        repeated_year,
                        repeated_history
                    )
                    SELECT
                        v_area_stats_id,
                        value->>'name',
                        (value->>'total_questions')::SMALLINT,
                        (value->>'new_questions')::SMALLINT,
                        (value->>'repeated_year')::SMALLINT,
                        (value->>'repeated_history')::SMALLINT
                    FROM jsonb_array_elements(v_area_json->'details');
                END LOOP;

                RETURN v_result;
            END;
            $$;


ALTER FUNCTION questions.fn_get_question_usage_stats(p_type_material_id smallint, p_material_id bigint, p_start_week smallint, p_end_week smallint, p_user_id bigint, p_force_regenerate boolean) OWNER TO postgres;

--
