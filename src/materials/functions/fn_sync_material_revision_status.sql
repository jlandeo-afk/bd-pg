-- Function: materials.fn_sync_material_revision_status(bigint, bigint)

--

CREATE FUNCTION materials.fn_sync_material_revision_status(p_revision_id bigint, p_user_id bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_total_slots  integer;
    v_filled_slots integer;
    v_current_status varchar;
    v_new_status     varchar;
BEGIN
    -- 1. Obtener estado actual
    SELECT status INTO v_current_status
    FROM material_revisions
    WHERE id = p_revision_id;

    IF NOT FOUND THEN RETURN; END IF;

    -- 2. Contar slots de preguntas para este material/semanas
    -- Buscamos en base a los items (detail_week_type_mat) registrados en la revisión
    SELECT 
        COUNT(*),
        COUNT(*) FILTER (WHERE question_id IS NOT NULL OR parent_question_id IS NOT NULL)
    INTO v_total_slots, v_filled_slots
    FROM material_ballot_question
    WHERE week_type_material_id IN (
        SELECT detail_week_type_mat_id 
        FROM material_revision_items 
        WHERE material_revision_id = p_revision_id 
          AND deleted_at IS NULL
    )
    AND fl_status = true;

    -- 3. Determinar nuevo estado
    -- Si no hay slots (caso raro), lo consideramos completo
    IF v_total_slots = 0 OR v_total_slots = v_filled_slots THEN
        v_new_status := 'pdf_delivered';
    ELSE
        v_new_status := 'generating';
    END IF;

    -- 4. Actualizar si hay cambio
    -- Regla: Si ya está en 'material_delivered', no retrocedemos automáticamente? 
    -- El usuario dice: "quiten una pregunta y este deberia de cambiar de estado"
    -- Así que si cambia de completo a incompleto, retrocedemos siempre.
    -- Si cambia de incompleto a completo, avanzamos solo si no estaba ya verificado/entregado.
    
    IF v_new_status = 'generating' AND v_current_status IN ('pdf_delivered', 'verified', 'material_delivered') THEN
        -- Retroceso por falta de preguntas
        UPDATE material_revisions
        SET status = v_new_status,
            updated_at = NOW(),
            updated_by = p_user_id
        WHERE id = p_revision_id;

        INSERT INTO material_revision_histories (
            material_revision_id, old_status, new_status, changed_by, changed_at
        ) VALUES (
            p_revision_id, v_current_status, v_new_status, p_user_id, NOW()
        );
    ELSIF v_new_status = 'pdf_delivered' AND v_current_status IN ('queued', 'generating') THEN
        -- Avance automático por completitud
        UPDATE material_revisions
        SET status = v_new_status,
            updated_at = NOW(),
            updated_by = p_user_id
        WHERE id = p_revision_id;

        INSERT INTO material_revision_histories (
            material_revision_id, old_status, new_status, changed_by, changed_at
        ) VALUES (
            p_revision_id, v_current_status, v_new_status, p_user_id, NOW()
        );
    END IF;
END;
$$;


ALTER FUNCTION materials.fn_sync_material_revision_status(p_revision_id bigint, p_user_id bigint) OWNER TO postgres;

--
