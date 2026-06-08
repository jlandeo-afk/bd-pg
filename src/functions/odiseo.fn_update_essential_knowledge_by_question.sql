-- Function: odiseo.fn_update_essential_knowledge_by_question(bigint, jsonb, bigint)

--

CREATE FUNCTION odiseo.fn_update_essential_knowledge_by_question(p_question_id bigint, p_essential_knowledge_ids jsonb, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN

    -- Si viene null, lo tratamos como array vacío
    p_essential_knowledge_ids := COALESCE(p_essential_knowledge_ids, '[]'::jsonb);

    WITH incoming_essential_knowledges AS (
        SELECT DISTINCT value::bigint AS id
        FROM jsonb_array_elements_text(p_essential_knowledge_ids) AS items(value)
    ),

    -- Restaurar (soft delete revertido)
    restored AS (
        UPDATE essential_knowledge_questions ekq
        SET
            deleted_at = NULL,
            deleted_by = NULL,
            updated_at = now(),
            updated_by = p_updated_by
        FROM incoming_essential_knowledges incoming
        WHERE ekq.question_id = p_question_id
          AND ekq.essential_knowledge_id = incoming.id
          AND ekq.deleted_at IS NOT NULL
        RETURNING ekq.id
    ),

    -- Insertar nuevos
    inserted AS (
        INSERT INTO essential_knowledge_questions (
            question_id,
            essential_knowledge_id,
            created_by,
            created_at
        )
        SELECT
            p_question_id,
            incoming.id,
            p_updated_by,
            now()
        FROM incoming_essential_knowledges incoming
        WHERE NOT EXISTS (
            SELECT 1
            FROM essential_knowledge_questions ekq
            WHERE ekq.question_id = p_question_id
              AND ekq.essential_knowledge_id = incoming.id
        )
        RETURNING id
    )

    -- Soft delete de los que ya no vienen
    UPDATE essential_knowledge_questions ekq
    SET
        deleted_at = now(),
        deleted_by = p_updated_by
    WHERE ekq.question_id = p_question_id
      AND ekq.deleted_at IS NULL
      AND NOT EXISTS (
          SELECT 1
          FROM incoming_essential_knowledges incoming
          WHERE incoming.id = ekq.essential_knowledge_id
      );

END;
$$;


ALTER FUNCTION odiseo.fn_update_essential_knowledge_by_question(p_question_id bigint, p_essential_knowledge_ids jsonb, p_updated_by bigint) OWNER TO postgres;

--
