-- Function: materials.fn_register_questions_ballot(bigint, smallint, boolean, boolean, boolean, jsonb, jsonb, jsonb, jsonb, bigint)

--

CREATE FUNCTION materials.fn_register_questions_ballot(p_material_per_period_ballot_id bigint, p_week_type_material_id smallint, p_fl_missing_questions boolean, p_fl_missing_courses boolean, p_fl_missing_text boolean, p_save_questions jsonb, p_distribution_questions jsonb, p_register_and_completed_question_ids jsonb, p_register_and_completed_parent_ids jsonb, p_created_by bigint) RETURNS void
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
    v_request_date timestamp;
    v_material_distribution_ballot_questions_ids bigint[];
BEGIN
    -- 1. Obtener datos de contexto.
    SELECT
        m.id,
        dwtm.week,
        m.cycle_id,
        m.university_id,
        m.headquarte_id,
        dwtm.type_material_id,
        dwtm.parent_type_material_id,
        COALESCE(dwtm.updated_at, NOW())
        INTO 
        v_material_id,
        v_week,
        v_cycle_id,
        v_university_id,
        v_headquarters_id,
        v_type_material_id,
        v_parent_type_material_id,
        v_request_date
    FROM
        detail_week_type_mat dwtm
        JOIN material m ON dwtm.material_id = m.id
    WHERE
        dwtm.id = p_week_type_material_id;
    GET DIAGNOSTICS v_record_found = ROW_COUNT;

    IF NOT v_record_found THEN
        RAISE EXCEPTION 'No hay data en la tabla week_type_material_id: %', p_week_type_material_id;
    END IF;
    
    -- 2. Actualizar las flags del balotario.
    UPDATE
        material_per_period_ballot mppb
    SET
        fl_missing_questions = mppb.fl_missing_questions
        OR p_fl_missing_questions,
        fl_missing_courses = mppb.fl_missing_courses
        OR p_fl_missing_courses,
        fl_missing_text = mppb.fl_missing_text
        OR p_fl_missing_text
    WHERE
        mppb.id = p_material_per_period_ballot_id;
        
    -- 3. Limpiar y crear la tabla temporal.
    DROP TABLE IF EXISTS temp_input_questions;
    CREATE TEMP TABLE temp_input_questions (
        question_id bigint,
        course_id smallint,
        topic_id smallint,
        subtopic_id smallint,
        level_id bigint,
        type VARCHAR,
        position bigint,
        parent_question_id bigint,
        category_id bigint,
        sub_category_id bigint,
        subquestion jsonb
    ) ON COMMIT DROP;
    
    INSERT INTO temp_input_questions
    SELECT
        (q ->> 'question_id')::bigint,
        (q ->> 'course_id')::smallint,
        (q ->> 'topic_id')::smallint,
        (q ->> 'subtopic_id')::smallint,
        (q ->> 'level_id')::bigint,
        (q ->> 'type')::varchar,
        (q ->> 'position')::bigint,
        (q ->> 'parent_question_id')::bigint,
        (q ->> 'category_id')::bigint,
        (q ->> 'sub_category_id')::bigint,
        (q ->> 'subquestion')::jsonb
    FROM
        jsonb_array_elements(p_save_questions) AS q;
        
    -- 4. MERGE en question_history_cycle (insertar solo si no existe).
    MERGE INTO question_history_cycle AS target
    USING temp_input_questions AS source ON COALESCE(target.question_id, target.parent_question_id) = COALESCE(source.question_id, source.parent_question_id)
            AND target.cycle_id = v_cycle_id
            AND target.university_id = v_university_id
            AND target.headquarters_id = v_headquarters_id
            AND target.fl_status = TRUE
    WHEN NOT MATCHED THEN
        INSERT (question_id, cycle_id, university_id, headquarters_id, created_by, created_at, parent_question_id)
            VALUES (source.question_id, v_cycle_id, v_university_id, v_headquarters_id, p_created_by, NOW(), source.parent_question_id);
            
    -- 5. Crear tabla temporal para la distribución y preparar datos
    DROP TABLE IF EXISTS temp_distribution_questions;
    CREATE TEMP TABLE temp_distribution_questions AS
    SELECT
        (dist ->> 'course_id')::smallint AS course_id,
        (dist ->> 'topic_id')::smallint AS topic_id,
        (dist ->> 'subtopic_id')::smallint AS subtopic_id,
        (dist ->> 'level_id')::bigint AS level_id,
        (dist ->> 'usage_level_id')::bigint AS usage_level_id,
        (dist ->> 'type')::varchar AS type,
        (dist ->> 'question_id')::bigint AS question_id,
        (dist ->> 'parent_question_id')::bigint AS parent_question_id,
        (dist ->> 'position')::bigint AS position,
        (dist ->> 'position_initial')::bigint AS position_initial,
        (dist ->> 'status_usage')::boolean AS status_usage,
        (dist ->> 'absolute_position')::smallint AS absolute_position,
        (dist ->> 'category_id')::smallint AS type_text_id,
        (dist ->> 'sub_category_id')::smallint AS type_text_subcategory_id,
        (dist ->> 'subquestion')::jsonb AS subquestion
    FROM
        jsonb_array_elements(p_distribution_questions) dist;

    -- 6. Insertar en material_ballot_question todo el esqueleto y preguntas
    DROP TABLE IF EXISTS temp_inserted_mbq;
    CREATE TEMP TABLE temp_inserted_mbq AS
    WITH inserted_mbq AS (
        INSERT INTO material_ballot_question (
            week_type_material_id, material_id, week, type_material_id,
            course_id, topic_id, subtopic_id, level_id, usage_level_id, type,
            question_id, parent_question_id, question_history_id, position,
            position_initial, absolute_position, usage_status,
            type_text_id, type_text_subcategory_id, state,
            created_by, created_at
        )
        SELECT
            p_week_type_material_id, v_material_id, v_week, v_type_material_id,
            dist.course_id, dist.topic_id, dist.subtopic_id, dist.level_id,
            dist.usage_level_id, dist.type, dist.question_id, dist.parent_question_id,
            qhc.id, dist.position, dist.position_initial, dist.absolute_position, dist.status_usage,
            dist.type_text_id, dist.type_text_subcategory_id,
            CASE 
                WHEN dist.question_id IS NULL AND dist.parent_question_id IS NULL THEN 'MISSING'::varchar
                ELSE 'GENERATED'::varchar
            END AS state,
            p_created_by, NOW()
        FROM temp_distribution_questions dist
        LEFT JOIN question_history_cycle qhc 
            ON COALESCE(qhc.question_id, qhc.parent_question_id) = COALESCE(dist.question_id, dist.parent_question_id)
            AND qhc.cycle_id = v_cycle_id
            AND qhc.university_id = v_university_id
            AND qhc.headquarters_id = v_headquarters_id
            AND qhc.fl_status = TRUE
        ON CONFLICT (week_type_material_id, (COALESCE(question_id, 0)), (COALESCE(parent_question_id, 0))) 
        WHERE fl_status = TRUE AND deleted_at IS NULL AND (question_id IS NOT NULL OR parent_question_id IS NOT NULL)
        DO UPDATE SET
            material_id = EXCLUDED.material_id,
            week = EXCLUDED.week,
            type_material_id = EXCLUDED.type_material_id,
            course_id = EXCLUDED.course_id,
            topic_id = EXCLUDED.topic_id,
            subtopic_id = EXCLUDED.subtopic_id,
            level_id = EXCLUDED.level_id,
            usage_level_id = EXCLUDED.usage_level_id,
            type = EXCLUDED.type,
            question_history_id = EXCLUDED.question_history_id,
            position = EXCLUDED.position,
            position_initial = EXCLUDED.position_initial,
            absolute_position = EXCLUDED.absolute_position,
            usage_status = EXCLUDED.usage_status,
            type_text_id = EXCLUDED.type_text_id,
            type_text_subcategory_id = EXCLUDED.type_text_subcategory_id,
            state = EXCLUDED.state,
            updated_by = EXCLUDED.created_by,
            updated_at = NOW()
        RETURNING id, COALESCE(question_id, 0) AS q_key, COALESCE(parent_question_id, 0) AS pq_key
    )
    SELECT imbq.id, dist.subquestion
    FROM inserted_mbq imbq
    LEFT JOIN temp_distribution_questions dist
      ON COALESCE(dist.question_id, 0) = imbq.q_key
      AND COALESCE(dist.parent_question_id, 0) = imbq.pq_key;

    -- Guardamos los IDs insertados/actualizados para las completadas
    SELECT array_agg(id)
    INTO v_material_distribution_ballot_questions_ids
    FROM temp_inserted_mbq;

    -- 7. Actualizar eliminados lógicos de subpreguntas e insertar las nuevas
    UPDATE material_ballot_subquestions
    SET fl_status = FALSE, deleted_at = NOW()
    WHERE material_ballot_question_id IN (SELECT id FROM temp_inserted_mbq)
      AND fl_status = TRUE;

    INSERT INTO material_ballot_subquestions (material_ballot_question_id, question_id, position, state, topic_id, course_id, subtopic_id, created_by)
    SELECT
        mbq.id,
        (elem->>'question_id')::BIGINT,
        row_number() OVER(PARTITION BY mbq.id ORDER BY (elem->>'position')::INT2 NULLS LAST)::INT2,
        CASE WHEN (elem->>'question_id') IS NOT NULL THEN 'GENERATED'::varchar ELSE 'MISSING'::varchar END,
        (elem->>'topic_id')::SMALLINT,
        (elem->>'course_id')::SMALLINT,
        (elem->>'subtopic_id')::SMALLINT,
        p_created_by
    FROM temp_inserted_mbq mbq
    CROSS JOIN LATERAL jsonb_array_elements(mbq.subquestion) AS elem
    WHERE mbq.subquestion IS NOT NULL 
      AND jsonb_typeof(mbq.subquestion) = 'array'
    ON CONFLICT DO NOTHING;

    -- ==========================================================================
    -- 8. Actualizar el valor de las completadas (ahora sobre material_ballot_question)
    -- ==========================================================================
    UPDATE material_ballot_question mbq
    SET added_in_completion = true,
        state = 'AUTO_COMPLETED',
        updated_at = NOW(),
        updated_by = p_created_by
    WHERE mbq.id = ANY(v_material_distribution_ballot_questions_ids)
        AND mbq.question_id IN (
            SELECT value::BIGINT
            FROM jsonb_array_elements_text(p_register_and_completed_question_ids)
        );

    UPDATE material_ballot_question mbq
    SET added_in_completion = true,
        completed_subquestion = true,
        state = 'AUTO_COMPLETED',
        updated_at = NOW(),
        updated_by = p_created_by
    WHERE mbq.id = ANY(v_material_distribution_ballot_questions_ids)
        AND mbq.parent_question_id IN (
            SELECT value::BIGINT
            FROM jsonb_array_elements_text(p_register_and_completed_parent_ids)
        );
END;
$$;


ALTER FUNCTION materials.fn_register_questions_ballot(p_material_per_period_ballot_id bigint, p_week_type_material_id smallint, p_fl_missing_questions boolean, p_fl_missing_courses boolean, p_fl_missing_text boolean, p_save_questions jsonb, p_distribution_questions jsonb, p_register_and_completed_question_ids jsonb, p_register_and_completed_parent_ids jsonb, p_created_by bigint) OWNER TO postgres;

--
