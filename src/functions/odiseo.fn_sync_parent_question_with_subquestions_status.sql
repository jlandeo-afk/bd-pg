-- Function: odiseo.fn_sync_parent_question_with_subquestions_status(bigint, character varying, bigint)

--

CREATE FUNCTION odiseo.fn_sync_parent_question_with_subquestions_status(p_question_id bigint, p_status character varying, p_updated_by bigint) RETURNS TABLE(parent_question_id bigint, code character varying, status character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_parent_id BIGINT;
BEGIN
    /*
        Función para sincronizar el estado del texto padre
        cuando todas las subpreguntas tienen el mismo estado.
    */

    -- Obtener parent_id del hijo
    SELECT q.parent_id
      INTO v_parent_id
    FROM question q
    WHERE q.id = p_question_id;

    -- Si no tiene padre, salir
    IF v_parent_id IS NULL THEN
        RETURN;
    END IF;

    RETURN QUERY
    UPDATE parent_question pq
       SET status = p_status,
           updated_by = p_updated_by,
           updated_at = NOW()
     WHERE pq.id = v_parent_id
       -- Solo actualizar si el estado actual es diferente
       AND pq.status <> p_status
       -- Validar que TODOS los hijos tengan el estado esperado
       AND NOT EXISTS (
            SELECT 1
            FROM question q
            WHERE q.parent_id = v_parent_id
              AND q.status <> p_status
       )
    RETURNING pq.id, pq.code, pq.status;
END;
$$;


ALTER FUNCTION odiseo.fn_sync_parent_question_with_subquestions_status(p_question_id bigint, p_status character varying, p_updated_by bigint) OWNER TO postgres;

--
