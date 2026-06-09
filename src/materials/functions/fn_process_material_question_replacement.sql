-- Function: materials.fn_process_material_question_replacement(bigint, bigint, bigint, text, bigint)

--

CREATE FUNCTION materials.fn_process_material_question_replacement(p_material_revision_course_id bigint, p_material_ballot_question_id bigint, p_new_question_id bigint, p_reason text, p_created_by bigint) RETURNS TABLE(last_code character varying, new_code character varying, pending_change integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_old_question_id BIGINT;
    v_cycle_id BIGINT;
    v_university_id SMALLINT;
    v_headquarters_id BIGINT;
    v_question_history_id BIGINT;
    v_week_type_material_id BIGINT;
    v_new_material_ballot_question_id BIGINT;
    
    v_last_code CHARACTER VARYING;
    v_new_code CHARACTER VARYING;
    v_limit_questions INTEGER;
    v_current_changes INTEGER;
BEGIN
    -- 1. Obtener la configuración del límite de cambios permitidos
    SELECT limit_questions_to_change INTO v_limit_questions 
    FROM advanced_settings 
    LIMIT 1;

    -- 2. Incrementar y obtener el conteo de cambios actuales en la revisión
    UPDATE material_revision_courses
    SET amount_questions_changed = COALESCE(amount_questions_changed, 0) + 1,
        updated_at = NOW()
    WHERE id = p_material_revision_course_id
    RETURNING amount_questions_changed INTO v_current_changes;


    -- 3. Obtener la pregunta actual, sus metadatos de material y su código
    SELECT 
        mbq.question_id,
        q_old.code, 
        m.cycle_id, 
        m.university_id, 
        m.headquarte_id,
        dwtm.id
    INTO 
        v_old_question_id,
        v_last_code, 
        v_cycle_id, 
        v_university_id, 
        v_headquarters_id,
        v_week_type_material_id
    FROM material_ballot_question mbq
    INNER JOIN detail_week_type_mat dwtm ON dwtm.id = mbq.week_type_material_id
    INNER JOIN material m ON m.id = dwtm.material_id
    INNER JOIN question q_old ON q_old.id = mbq.question_id
    WHERE mbq.id = p_material_ballot_question_id;

    -- 4. Obtener el código de la NUEVA pregunta
    SELECT code INTO v_new_code 
    FROM question 
    WHERE id = p_new_question_id;

    -- 5. Traer o registrar historial para la NUEVA pregunta
    SELECT qhc.id INTO v_question_history_id
    FROM question_history_cycle qhc
    WHERE qhc.question_id = p_new_question_id
      AND qhc.cycle_id = v_cycle_id
      AND qhc.university_id = v_university_id
      AND qhc.headquarters_id = v_headquarters_id
      AND qhc.fl_status = TRUE
    LIMIT 1;

    IF v_question_history_id IS NULL THEN
        -- Replicar de la antigua pregunta, ya que siempre tendrá historial
        INSERT INTO question_history_cycle (
            question_id, cycle_id, university_id, headquarters_id, fl_status, 
            created_by, created_at, updated_at, automatic, parent_question_id, subquestion
        )
        SELECT
            p_new_question_id, cycle_id, university_id, headquarters_id, TRUE, 
            p_created_by, NOW(), NOW(), automatic, parent_question_id, subquestion
        FROM question_history_cycle
        WHERE question_id = v_old_question_id
          AND cycle_id = v_cycle_id
          AND university_id = v_university_id
          AND headquarters_id = v_headquarters_id
          AND fl_status = TRUE
        LIMIT 1
        RETURNING id INTO v_question_history_id;
    END IF;

    -- 5.1. Marcar como eliminado el historial de la pregunta antigua
    UPDATE question_history_cycle
    SET fl_status = FALSE,
        deleted_at = NOW(),
        deleted_by = p_created_by
    WHERE question_id = v_old_question_id
      AND cycle_id = v_cycle_id
      AND university_id = v_university_id
      AND headquarters_id = v_headquarters_id;

    -- 6. Insertar nueva pregunta en el balotario replicando los campos (UNIFICADO)
    INSERT INTO material_ballot_question (
        week_type_material_id, course_id, topic_id, subtopic_id, level_id, type, 
        question_id, fl_status, created_by, created_at, updated_at, 
        question_history_id, position, random, fl_is_manual, parent_question_id, 
        type_text_id, type_text_subcategory_id,
        material_id, week, type_material_id, position_initial, usage_level_id,
        usage_status, absolute_position, added_in_completion, removed_in_completion, state
    )
    SELECT 
        week_type_material_id, course_id, topic_id, subtopic_id, level_id, type, 
        p_new_question_id, TRUE, p_created_by, NOW(), NOW(), 
        v_question_history_id, position, random, fl_is_manual, parent_question_id, 
        type_text_id, type_text_subcategory_id,
        material_id, week, type_material_id, position_initial, usage_level_id,
        usage_status, absolute_position, added_in_completion, removed_in_completion, state
    FROM material_ballot_question
    WHERE id = p_material_ballot_question_id
    RETURNING id INTO v_new_material_ballot_question_id;

    -- 6.1. Eliminar lógicamente la pregunta antigua en el balotario
    UPDATE material_ballot_question
    SET fl_status = FALSE,
        deleted_at = NOW(),
        deleted_by = p_created_by
    WHERE id = p_material_ballot_question_id;

    -- 6.2. Eliminar lógicamente sus subpreguntas asociadas
    UPDATE material_ballot_subquestions
    SET fl_status = FALSE,
        deleted_at = NOW()
    WHERE material_ballot_question_id = p_material_ballot_question_id;

    -- 8. Registrar el motivo del cambio en la nueva tabla
    INSERT INTO material_question_change_reason (
        material_revision_course_id,
        material_ballot_question_id,
        old_question_id,
        new_question_id,
        reason,
        created_by,
        created_at,
        updated_at
    ) VALUES (
        p_material_revision_course_id,
        v_new_material_ballot_question_id,
        v_old_question_id,
        p_new_question_id,
        p_reason,
        p_created_by,
        NOW(),
        NOW()
    );

    -- 9. Limpiar la url del material a nivel del curso
    PERFORM fn_deactive_ballot_per_course_url(
        p_material_revision_course_id,
        p_created_by
    );

    -- 10. Retornar los datos solicitados
    RETURN QUERY 
    SELECT 
        v_last_code, 
        v_new_code, 
        (v_limit_questions - v_current_changes)::INTEGER AS pending_change;

END;
$$;


ALTER FUNCTION materials.fn_process_material_question_replacement(p_material_revision_course_id bigint, p_material_ballot_question_id bigint, p_new_question_id bigint, p_reason text, p_created_by bigint) OWNER TO postgres;

--
