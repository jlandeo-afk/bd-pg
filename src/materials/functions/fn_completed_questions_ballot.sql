-- Function: materials.fn_completed_questions_ballot(bigint, smallint, boolean, boolean, boolean, jsonb, bigint)

--

CREATE FUNCTION materials.fn_completed_questions_ballot(p_material_per_period_ballot_id bigint, p_week_type_material_id smallint, p_fl_missing_questions boolean, p_fl_missing_courses boolean, p_fl_missing_text boolean, p_distribution_questions jsonb, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_material_id bigint;
    v_week smallint;
    v_cycle_id bigint;
    v_university_id smallint;
    v_headquarters_id bigint;
    v_type_material_id smallint;
    v_parent_type_material_id smallint;
    v_record_found boolean;
BEGIN
    -- 1. Obtener datos de contexto
    SELECT
        m.id,
        dwtm.week,
        m.cycle_id,
        m.university_id,
        m.headquarte_id,
        dwtm.type_material_id,
        dwtm.parent_type_material_id
        INTO 
        v_material_id,
        v_week,
        v_cycle_id,
        v_university_id,
        v_headquarters_id,
        v_type_material_id,
        v_parent_type_material_id
    FROM detail_week_type_mat dwtm
    JOIN material m ON dwtm.material_id = m.id
    WHERE dwtm.id = p_week_type_material_id;

    GET DIAGNOSTICS v_record_found = ROW_COUNT;
    IF NOT v_record_found THEN
        RAISE EXCEPTION 'No hay data en la tabla week_type_material_id: %', p_week_type_material_id;
    END IF;

    -- 2. Actualizar las flags del balotario.
    UPDATE material_per_period_ballot mppb
    SET fl_missing_questions = CASE WHEN p_fl_missing_questions = TRUE AND mppb.fl_missing_questions = FALSE THEN mppb.fl_missing_questions ELSE p_fl_missing_questions END,
        fl_missing_courses = CASE WHEN p_fl_missing_courses = TRUE AND mppb.fl_missing_courses = FALSE THEN mppb.fl_missing_courses ELSE p_fl_missing_courses END,
        fl_missing_text = CASE WHEN p_fl_missing_text = TRUE AND mppb.fl_missing_text = FALSE THEN mppb.fl_missing_text ELSE p_fl_missing_text END
    WHERE mppb.id = p_material_per_period_ballot_id;

    -- 3. MERGE en question_history_cycle (insertar solo si no existe)
    MERGE INTO question_history_cycle AS target
    USING (
        SELECT DISTINCT
            (q ->> 'question_id')::bigint AS question_id,
            (q ->> 'parent_question_id')::bigint AS parent_question_id
        FROM jsonb_array_elements(p_distribution_questions) AS q
        WHERE (q ->> 'question_id') IS NOT NULL OR (q ->> 'parent_question_id') IS NOT NULL
    ) AS source 
    ON COALESCE(target.question_id, target.parent_question_id) = COALESCE(source.question_id, source.parent_question_id)
        AND target.cycle_id = v_cycle_id
        AND target.university_id = v_university_id
        AND target.headquarters_id = v_headquarters_id
        AND target.fl_status = TRUE
    WHEN NOT MATCHED THEN
        INSERT (question_id, cycle_id, university_id, headquarters_id, created_by, created_at, parent_question_id)
        VALUES (source.question_id, v_cycle_id, v_university_id, v_headquarters_id, p_updated_by, NOW(), source.parent_question_id);

    -- 4. CTE-Based Arquitectura Declarativa (Set-Based) para máximo rendimiento
    WITH parsed_json AS (
        SELECT
            (q ->> 'id')::bigint AS mbq_id,
            (q ->> 'question_id')::bigint AS question_id,
            (q ->> 'course_id')::smallint AS course_id,
            (q ->> 'topic_id')::smallint AS topic_id,
            (q ->> 'subtopic_id')::smallint AS subtopic_id,
            (q ->> 'level_id')::bigint AS level_id,
            (q ->> 'type')::varchar AS type,
            (q ->> 'position')::bigint AS position,
            (q ->> 'parent_question_id')::bigint AS parent_question_id,
            (q ->> 'subquestion')::jsonb AS subquestion,
            (q ->> 'usage_level_id')::bigint AS usage_level_id,
            (q ->> 'position_initial')::bigint AS position_initial,
            (q ->> 'status_usage')::boolean AS usage_status,
            (q ->> 'absolute_position')::smallint AS absolute_position,
            (q ->> 'is_complete')::boolean AS is_complete,
            (q ->> 'completed_subquestion')::boolean AS completed_subquestion
        FROM jsonb_array_elements(p_distribution_questions) AS q
    ),
    history_lookups AS (
        SELECT pj.course_id, pj.absolute_position, qhc.id AS q_history_id
        FROM parsed_json pj
        LEFT JOIN question_history_cycle qhc 
          ON COALESCE(qhc.question_id, qhc.parent_question_id) = COALESCE(pj.question_id, pj.parent_question_id)
          AND qhc.cycle_id = v_cycle_id
          AND qhc.university_id = v_university_id
          AND qhc.headquarters_id = v_headquarters_id
          AND qhc.fl_status = TRUE
    ),
    updated_mbq AS (
        UPDATE materials.material_ballot_question mbq
        SET 
            course_id = pj.course_id,
            absolute_position = pj.absolute_position,
            topic_id = pj.topic_id,
            subtopic_id = pj.subtopic_id,
            level_id = pj.level_id,
            usage_level_id = pj.usage_level_id,
            type = pj.type,
            question_id = pj.question_id,
            parent_question_id = pj.parent_question_id,
            question_history_id = hl.q_history_id,
            position = pj.position,
            position_initial = pj.position_initial,
            usage_status = pj.usage_status,
            fl_status = TRUE,
            state = CASE 
                WHEN pj.question_id IS NULL AND pj.parent_question_id IS NULL THEN 'MISSING' 
                WHEN COALESCE(pj.is_complete, FALSE) = TRUE THEN 'AUTO_COMPLETED'
                ELSE 'GENERATED' 
            END,
            added_in_completion = pj.is_complete,
            completed_subquestion = COALESCE(pj.completed_subquestion, FALSE),
            deleted_at = NULL,
            updated_at = CASE WHEN pj.is_complete IS TRUE THEN NOW() ELSE updated_at END,
            updated_by = p_updated_by
        FROM parsed_json pj
        LEFT JOIN history_lookups hl ON hl.course_id = pj.course_id AND hl.absolute_position = pj.absolute_position
        WHERE mbq.id = pj.mbq_id
        RETURNING mbq.id, pj.course_id, pj.absolute_position
    ),
    inserted_mbq AS (
        INSERT INTO materials.material_ballot_question (
            week_type_material_id, material_id, week, type_material_id, course_id, 
            topic_id, subtopic_id, level_id, usage_level_id, type, question_id, 
            parent_question_id, question_history_id, position, position_initial, 
            absolute_position, usage_status, state, fl_status, fl_is_manual, 
            added_in_completion, completed_subquestion, created_by, created_at, updated_at
        )
        SELECT 
            p_week_type_material_id, v_material_id, v_week, v_type_material_id, pj.course_id,
            pj.topic_id, pj.subtopic_id, pj.level_id, pj.usage_level_id, pj.type, pj.question_id,
            pj.parent_question_id, hl.q_history_id, pj.position, pj.position_initial,
            pj.absolute_position, pj.usage_status, 
            CASE 
                WHEN pj.question_id IS NULL AND pj.parent_question_id IS NULL THEN 'MISSING' 
                WHEN COALESCE(pj.is_complete, FALSE) = TRUE THEN 'AUTO_COMPLETED'
                ELSE 'GENERATED' 
            END, 
            TRUE, FALSE, pj.is_complete, COALESCE(pj.completed_subquestion, FALSE), p_updated_by, NOW(),
            CASE WHEN pj.is_complete IS TRUE THEN NOW() ELSE NULL END
        FROM parsed_json pj
        LEFT JOIN history_lookups hl ON hl.course_id = pj.course_id AND hl.absolute_position = pj.absolute_position
        WHERE pj.mbq_id IS NULL
        RETURNING id, course_id, absolute_position
    ),
    all_upserted_mbq AS (
        SELECT id, course_id, absolute_position FROM updated_mbq
        UNION ALL
        SELECT id, course_id, absolute_position FROM inserted_mbq
    ),
    deleted_subquestions AS (
        UPDATE material_ballot_subquestions mbs
        SET fl_status = FALSE, deleted_at = NOW()
        FROM all_upserted_mbq u
        WHERE mbs.material_ballot_question_id = u.id AND mbs.fl_status = TRUE
        RETURNING mbs.id
    )
    INSERT INTO material_ballot_subquestions (material_ballot_question_id, question_id, position, state, topic_id, course_id, subtopic_id, added_in_completion, created_by)
    SELECT 
        u.id,
        (sub.obj->>'question_id')::bigint,
        sub.ord::int,
        CASE WHEN (sub.obj->>'question_id') IS NOT NULL THEN 'AUTO_COMPLETED' ELSE 'MISSING' END,
        (sub.obj->>'topic_id')::smallint,
        (sub.obj->>'course_id')::smallint,
        (sub.obj->>'subtopic_id')::smallint,
        TRUE,
        p_updated_by
    FROM parsed_json pj
    JOIN all_upserted_mbq u ON pj.course_id = u.course_id AND pj.absolute_position = u.absolute_position
    CROSS JOIN jsonb_array_elements(CASE WHEN jsonb_typeof(pj.subquestion) = 'array' THEN pj.subquestion ELSE '[]'::jsonb END) WITH ORDINALITY AS sub(obj, ord);

END;
$$;


ALTER FUNCTION materials.fn_completed_questions_ballot(p_material_per_period_ballot_id bigint, p_week_type_material_id smallint, p_fl_missing_questions boolean, p_fl_missing_courses boolean, p_fl_missing_text boolean, p_distribution_questions jsonb, p_updated_by bigint) OWNER TO postgres;

--
