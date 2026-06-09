-- Function: exams.fn_get_exam_generated_questions(uuid)

--

CREATE FUNCTION exams.fn_get_exam_generated_questions(p_uuid uuid) RETURNS json
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_result json;
    v_university_id int;
    v_material_id int;
BEGIN
    -- Obtenemos el university_id y material_id
    SELECT m.university_id, m.id 
    INTO v_university_id, v_material_id
    FROM detail_week_type_mat dwtm
    JOIN material m ON m.id = dwtm.material_id
    WHERE dwtm.uuid = p_uuid;

    IF v_material_id IS NULL THEN
        RETURN NULL;
    END IF;

    WITH base_data AS (
        SELECT 
            dwtm.type_material_id, 
            tm.description AS type_material,
            c.description AS cycle,
            ea.description AS area,
            ea.id AS area_id,
            meaw.id AS material_exam_area_week_id
        FROM detail_week_type_mat dwtm 
        JOIN material m ON m.id = dwtm.material_id 
        JOIN "cycle" c ON c.id = m.cycle_id 
        JOIN material_exam_area_week meaw ON meaw.week_type_material_id = dwtm.id
        JOIN exam_area ea ON ea.id = meaw.area_id 
        JOIN type_material tm ON tm.id = dwtm.type_material_id 
        WHERE dwtm.uuid = p_uuid
        AND meaw.fl_status = true
    ),
    normal_questions AS (
        SELECT 
            meq.material_exam_area_week_id, 
            q.id,
            q.code,
            CASE WHEN co.id IS NOT NULL THEN json_build_object('id', co.id, 'name', co.name) ELSE NULL END AS course,
            CASE WHEN t.id IS NOT NULL THEN json_build_object('id', t.id, 'name', t.name) ELSE NULL END AS topic,
            CASE WHEN s.id IS NOT NULL THEN json_build_object('id', s.id, 'name', s.name, 'is_frequent', COALESCE(fus.is_frequent, false)) ELSE NULL END AS subtopic,
            CASE WHEN l.id IS NOT NULL THEN json_build_object('id', l.id, 'name', l.name) ELSE NULL END AS level,
            meq.position,
            q.ter
        FROM material_exam_question meq 
        JOIN base_data bd ON bd.material_exam_area_week_id = meq.material_exam_area_week_id
        JOIN question q ON q.id = meq.question_id 
        LEFT JOIN course co ON co.id = meq.course_id
        LEFT JOIN topic t ON t.id = meq.topic_id 
        LEFT JOIN subtopic s ON s.id = meq.subtopic_id
        LEFT JOIN frequent_university_subtopic fus ON fus.subtopic_id = meq.subtopic_id AND fus.university_id = v_university_id
        LEFT JOIN "level" l ON l.id = meq.level_id 
        WHERE meq.fl_status = true AND meq.deleted_at IS NULL AND meq.question_id IS NOT NULL
    ),
    text_subquestions_raw AS (
        SELECT 
            mepq.material_exam_area_week_id, 
            mepq.position,
            jsonb_array_elements(mepq.subquestion) AS subq_elem,
            mepq.current_level AS level_id, 
            mepq.course_id 
        FROM material_exam_parent_question mepq 
        JOIN base_data bd ON bd.material_exam_area_week_id = mepq.material_exam_area_week_id
        WHERE mepq.deleted_at IS NULL AND mepq.parent_question_id IS NOT NULL
    ),
    text_subquestions AS (
        SELECT
            ts.material_exam_area_week_id,
            q.id,
            q.code,
            CASE WHEN co.id IS NOT NULL THEN json_build_object('id', co.id, 'name', co.name) ELSE NULL END AS course,
            CASE WHEN t.id IS NOT NULL THEN json_build_object('id', t.id, 'name', t.name) ELSE NULL END AS topic,
            CASE WHEN s.id IS NOT NULL THEN json_build_object('id', s.id, 'name', s.name, 'is_frequent', COALESCE(fus.is_frequent, false)) ELSE NULL END AS subtopic,
            CASE WHEN l.id IS NOT NULL THEN json_build_object('id', l.id, 'name', l.name) ELSE NULL END AS level,
            ts.position,
            q.ter
        FROM text_subquestions_raw ts
        JOIN question q ON q.id = (ts.subq_elem->>'question_id')::int
        LEFT JOIN course co ON co.id = ts.course_id
        LEFT JOIN topic t ON t.id = (ts.subq_elem->>'topic_id')::int
        LEFT JOIN subtopic s ON s.id = (ts.subq_elem->>'subtopic_id')::int
        LEFT JOIN frequent_university_subtopic fus ON fus.subtopic_id = s.id AND fus.university_id = v_university_id::bigint
        LEFT JOIN "level" l ON l.id = ts.level_id
    ),
    all_questions AS (
        SELECT * FROM normal_questions
        UNION ALL
        SELECT * FROM text_subquestions
    ),
    questions_with_metadata AS (
        SELECT 
            aq.material_exam_area_week_id,
            aq.id,
            aq.code,
            aq.course,
            aq.topic,
            aq.subtopic,
            aq.level,
            aq.position,
            aq.ter,
            (
                SELECT json_strip_nulls(json_build_object(
                    'university', CASE WHEN vo.university_id IS NOT NULL THEN json_build_object('id', vo.university_id, 'name', u.slug) ELSE NULL END,
                    'option', CASE WHEN vo.option_id IS NOT NULL THEN json_build_object('id', vo.option_id, 'name', ou.name) ELSE NULL END,
                    'modality', CASE WHEN vo.modality_id IS NOT NULL THEN json_build_object('id', vo.modality_id, 'name', mo.name) ELSE NULL END,
                    'version', CASE WHEN vo.version IS NOT NULL THEN common.fn_number_to_roman(vo.version::smallint) ELSE NULL END,
                    'year', vo.year
                ))
                FROM v_all_question_origins_by_university vo
                LEFT JOIN origin_university u ON u.id = vo.university_id
                LEFT JOIN option_university ou ON ou.id = vo.option_id
                LEFT JOIN modality_options mo ON mo.id = vo.modality_id
                WHERE vo.question_id = aq.id AND vo.university_id = v_university_id::bigint
                LIMIT 1
            ) AS origin
        FROM all_questions aq
    ),
    areas_json AS (
        SELECT 
            bd.area_id AS id,
            bd.area,
            COALESCE(
                (
                    SELECT json_agg(
                        json_strip_nulls(json_build_object(
                            'id', qm.id,
                            'code', qm.code,
                            'course', qm.course,
                            'topic', qm.topic,
                            'subtopic', qm.subtopic,
                            'level', qm.level,
                            'ter', qm.ter,
                            'origin', COALESCE(qm.origin, '{}'::json)
                        ))
                    )
                    FROM (
                        SELECT * 
                        FROM questions_with_metadata q_sub 
                        WHERE q_sub.material_exam_area_week_id = bd.material_exam_area_week_id 
                        ORDER BY q_sub.position
                    ) qm
                ), 
                '[]'::json
            ) AS questions
        FROM base_data bd
    )
    SELECT json_build_object(
        'type_material', (SELECT type_material FROM base_data LIMIT 1),
        'type_material_id', (SELECT type_material_id FROM base_data LIMIT 1),
        'cycle', (SELECT cycle FROM base_data LIMIT 1),
        'areas', COALESCE((
            SELECT json_agg(row_to_json(a)) 
            FROM (SELECT * FROM areas_json ORDER BY id ASC) a
        ), '[]'::json)
    ) INTO v_result;

    RETURN v_result;
END;
$$;


ALTER FUNCTION exams.fn_get_exam_generated_questions(p_uuid uuid) OWNER TO postgres;

--
