-- Function: odiseo.fn_list_questions_verified_and_not_excluded(bigint)

--

CREATE FUNCTION odiseo.fn_list_questions_verified_and_not_excluded(p_material_id bigint) RETURNS TABLE(id bigint, code character varying, course_id smallint, topic_id smallint, level_id smallint, level smallint, type character varying, status character varying, subtopic_id integer, frequent_subtopic boolean, cycle_id integer, week smallint, type_material_id smallint, history jsonb)
    LANGUAGE sql STABLE
    AS $$
    WITH material_data AS (
        SELECT
            m.university_id,
            m.company_id
        FROM material m
        WHERE m.id = p_material_id
    ), 
    ballot_questions AS (
        SELECT DISTINCT mbq.question_id 
        FROM material m
        INNER JOIN detail_week_type_mat wt ON m.id = wt.material_id AND wt.fl_status = true
        INNER JOIN material_ballot_question mbq ON wt.id = mbq.week_type_material_id AND mbq.fl_status = true
        WHERE m.id = p_material_id
    ), 
    exam_questions AS (
        SELECT DISTINCT meq.question_id 
        FROM material_exam_question meq
        INNER JOIN material_exam_area_week meaw ON meq.material_exam_area_week_id = meaw.id AND meaw.fl_status = true
        INNER JOIN detail_week_type_mat wt ON meaw.week_type_material_id = wt.id
        WHERE wt.material_id = p_material_id
        AND wt.fl_status = true
        AND meaw.fl_status = true
        AND meq.fl_status = true
        AND meq.question_id IS NOT NULL -- Optimización: Filtro de nulos
    ), 
    max_start_per_question AS (
        SELECT
            qh.question_id,
            MAX(c.start_date) AS max_start_date
        FROM question_history_cycle qh
        INNER JOIN cycle c ON qh.cycle_id = c.id
        WHERE qh.fl_status = true
            AND qh.university_id IN (SELECT md.university_id FROM material_data md)
            AND c.company_id IN (SELECT md.company_id FROM material_data md)
        GROUP BY qh.question_id
    ), 
    questions_history AS (
        SELECT DISTINCT
            qh.question_id,
            qh.cycle_id,
            c.description,
            c.start_date,
            c.end_date
        FROM question_history_cycle qh
        INNER JOIN cycle c ON qh.cycle_id = c.id
        INNER JOIN max_start_per_question mx ON qh.question_id = mx.question_id
        WHERE qh.fl_status = true
            AND qh.university_id IN (SELECT md.university_id FROM material_data md)
            AND c.start_date BETWEEN mx.max_start_date - INTERVAL '21 days' AND mx.max_start_date
            AND c.company_id IN (SELECT md.company_id FROM material_data md)
    ),
    -- Optimización: Pre-agregamos el JSON en su propio CTE
    history_aggregated AS (
        SELECT 
            question_id,
            JSONB_AGG(
                JSONB_BUILD_OBJECT(
                    'cycle_id', cycle_id,
                    'description', description,
                    'start_date', start_date,
                    'end_date', end_date
                ) ORDER BY start_date DESC
            ) AS history_json
        FROM questions_history
        GROUP BY question_id
    ),
    final_questions AS (
        SELECT
            q.id,
            q.code,
            q.course_id,
            q.topic_id,
            q.level_id,
            l.name::SMALLINT AS level,
            q.type,
            q.status,
            qs.subtopic_id,
            COALESCE(fus.is_frequent, false) AS frequent_subtopic,
            qt.cycle_id,
            qt.week_id AS week,
            qt.type_material_id,
            -- Usamos el JSON pre-armado
            COALESCE(ha.history_json, '[]'::JSONB) AS history
        FROM question q
        LEFT JOIN question_subtopic qs ON qs.question_id = q.id AND qs.fl_status = true
        LEFT JOIN question_temporary qt ON qt.question_id = q.id AND qt.fl_status = true
        LEFT JOIN level l ON l.id = q.level_id
        -- Hacemos JOIN directamente al JSON pre-armado
        LEFT JOIN history_aggregated ha ON q.id = ha.question_id
        LEFT JOIN frequent_university_subtopic fus ON fus.university_id IN (SELECT md.university_id FROM material_data md) AND fus.subtopic_id = qs.subtopic_id AND fus.fl_status = true
        WHERE q.status IN ('VERI', 'APRB')
        AND q.fl_status = true
        AND l.fl_status = true
        AND q.parent_id IS NULL
        AND NOT EXISTS (
            SELECT 1 FROM (
                SELECT question_id FROM ballot_questions
                UNION ALL
                SELECT question_id FROM exam_questions
            ) gpm
            WHERE gpm.question_id = q.id
        )
        AND NOT EXISTS (
            SELECT 1
                FROM question_excluded_material qem
                WHERE qem.question_id = q.id
                AND qem.material_id = p_material_id
                AND qem.deleted_at IS NULL
        )
        AND ( 
            q.number_question IS NULL
            OR q.number_question NOT LIKE 'D%'
        )

        UNION ALL 

        SELECT
            q.id,
            qs2.code,
            qs2.course_id,
            qs2.topic_id,
            q.level_id,
            l.name::SMALLINT AS level,
            q.type,
            q.status,
            qs2.subtopic_id,
            COALESCE(fus.is_frequent, false) AS frequent_subtopic,
            qt.cycle_id,
            qt.week_id AS week,
            qt.type_material_id,
            -- Usamos el JSON pre-armado
            COALESCE(ha.history_json, '[]'::JSONB) AS history
        FROM question q
        INNER JOIN question_shares qs2 ON qs2.question_id = q.id AND qs2.deleted_at IS NULL
        LEFT JOIN question_subtopic qs ON qs.question_id = q.id AND qs.fl_status = true
        LEFT JOIN question_temporary qt ON qt.question_id = q.id AND qt.fl_status = true
        LEFT JOIN level l ON l.id = q.level_id
        -- Hacemos JOIN directamente al JSON pre-armado
        LEFT JOIN history_aggregated ha ON q.id = ha.question_id
        LEFT JOIN frequent_university_subtopic fus ON fus.university_id IN (SELECT md.university_id FROM material_data md) AND fus.subtopic_id = qs.subtopic_id AND fus.fl_status = true
        WHERE q.status IN ('VERI', 'APRB')
        AND q.fl_status = true
        AND l.fl_status = true
        AND q.parent_id IS NULL
        AND NOT EXISTS (
            SELECT 1 FROM (
                SELECT question_id FROM ballot_questions
                UNION ALL
                SELECT question_id FROM exam_questions
            ) gpm
            WHERE gpm.question_id = q.id
        )
        AND NOT EXISTS (
            SELECT 1
                FROM question_excluded_material qem
                WHERE qem.question_id = q.id
                AND qem.material_id = p_material_id
                AND qem.deleted_at IS NULL
        )
        AND ( 
            q.number_question IS NULL
            OR q.number_question NOT LIKE 'D%'
        )

    )
    SELECT fq.* FROM final_questions fq
    ORDER BY fq.id DESC, fq.topic_id ASC, fq.subtopic_id ASC;
$$;


ALTER FUNCTION odiseo.fn_list_questions_verified_and_not_excluded(p_material_id bigint) OWNER TO postgres;

--
