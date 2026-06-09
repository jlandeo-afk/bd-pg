-- Function: materials.fn_deactivate_material_distribution(bigint)

--

CREATE FUNCTION materials.fn_deactivate_material_distribution(p_distribution_id bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_rows_affected int;
BEGIN
    -- CTEs para actualizar en bloque material_ballot_question, question_history_cycle y soft-delete de subpreguntas
    WITH original_data AS (
        SELECT
            mbq1.week_type_material_id,
            mbq1.course_id,
            mbq1.parent_question_id
        FROM materials.material_ballot_question AS mbq1
        WHERE mbq1.id = p_distribution_id AND mbq1.fl_status = TRUE AND mbq1.parent_question_id IS NOT NULL
        LIMIT 1
    ),
    update_ballot AS (
        UPDATE materials.material_ballot_question AS mbq
        SET parent_question_id = NULL,
            state = 'MISSING',
            removed_in_completion = CASE WHEN mbq.id = p_distribution_id THEN TRUE ELSE mbq.removed_in_completion END,
            updated_at = NOW()
        FROM original_data d
        WHERE mbq.week_type_material_id = d.week_type_material_id
            AND mbq.course_id = d.course_id
            AND mbq.parent_question_id = d.parent_question_id
            AND mbq.fl_status = TRUE
        RETURNING mbq.id, mbq.question_history_id
    ),
    update_history AS (
        UPDATE questions.question_history_cycle qhc
        SET fl_status = FALSE,
            updated_at = NOW()
        FROM update_ballot ab
        WHERE qhc.id = ab.question_history_id
            AND qhc.fl_status = TRUE
        RETURNING qhc.id
    ),
    delete_subquestions AS (
        UPDATE materials.material_ballot_subquestions mbs
        SET question_id = NULL,
            state = 'MISSING',
            added_in_completion = FALSE,
            fl_is_manual = FALSE,
            updated_at = NOW()
        FROM update_ballot ab
        WHERE mbs.material_ballot_question_id = ab.id
          AND mbs.fl_status = TRUE
        RETURNING mbs.id
    )
    SELECT COUNT(*) INTO v_rows_affected
    FROM update_ballot;

    -- Verificar si la operación tuvo efecto
    IF COALESCE(v_rows_affected, 0) = 0 THEN
        RAISE EXCEPTION 'Distribution ID % not found or already inactive.', p_distribution_id;
    END IF;

END;
$$;


ALTER FUNCTION materials.fn_deactivate_material_distribution(p_distribution_id bigint) OWNER TO postgres;

--
