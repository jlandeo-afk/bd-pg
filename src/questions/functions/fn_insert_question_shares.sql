-- Function: questions.fn_insert_question_shares(bigint, smallint, integer, bigint)

--

CREATE FUNCTION questions.fn_insert_question_shares(p_question_id bigint, p_subtopic_id smallint, p_course_id integer, p_created_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_uuids      UUID[];
    v_record     RECORD;
    v_new_code   TEXT;
    v_new_number TEXT;
BEGIN
    -- Obtener todos los UUIDs compartidos
    SELECT array_agg(uuid)
    INTO v_uuids
    FROM network_course_topic_subtopic
    WHERE subtopic_id = p_subtopic_id
      AND course_id = p_course_id
      AND deleted_at IS NULL;

    -- Si no hay UUIDs
    IF v_uuids IS NULL OR array_length(v_uuids, 1) IS NULL THEN
        RETURN;
    END IF;

    -- Buscar cursos relacionados
    FOR v_record IN
        SELECT course_id, topic_id, subtopic_id
        FROM network_course_topic_subtopic
        WHERE uuid = ANY(v_uuids)
          AND course_id <> p_course_id
          AND deleted_at IS NULL
    LOOP

        SELECT full_code, number_str
        INTO v_new_code, v_new_number
        FROM fn_generate_question_code(
            v_record.course_id::INTEGER,
            'P'::VARCHAR
        );

        INSERT INTO question_shares (
            question_id,
            course_id,
            code,
            topic_id,
            subtopic_id,
            created_by,
            created_at
        )
        VALUES (
            p_question_id,
            v_record.course_id,
            v_new_code,
            v_record.topic_id,
            v_record.subtopic_id,
            p_created_by,
            NOW()
        );

    END LOOP;
END;
$$;


ALTER FUNCTION questions.fn_insert_question_shares(p_question_id bigint, p_subtopic_id smallint, p_course_id integer, p_created_by bigint) OWNER TO postgres;

--
