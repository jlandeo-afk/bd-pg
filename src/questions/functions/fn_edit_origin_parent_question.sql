-- Function: questions.fn_edit_origin_parent_question(bigint, bigint, character varying, bigint, smallint, smallint, smallint, jsonb, smallint, bigint, character varying)

--

CREATE FUNCTION questions.fn_edit_origin_parent_question(p_id bigint, p_parent_question_id bigint, p_year character varying, p_region_id bigint, p_university_id smallint, p_option_id smallint, p_modality_id smallint, p_areas jsonb, p_version smallint, p_user_id bigint, p_method_system character varying) RETURNS SETOF questions.origin_parent_question
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_allows_frequent boolean;
    v_subtopic_id bigint;
BEGIN
    -- 1. Actualizamos el registro existente
    UPDATE origin_parent_question 
    SET 
        parent_id = p_parent_question_id,
        year = p_year,
        region_id = p_region_id,
        modality_option_id = p_modality_id, 
        areas = p_areas,
        version = p_version,
        updated_by = p_user_id,
        updated_at = NOW()
    WHERE id = p_id;

    -- 2. Verificamos si la (nueva) modalidad permite marcar temas frecuentes
    SELECT fl_allows_mark_frequent_topic INTO v_allows_frequent 
    FROM modality_options 
    WHERE id = p_modality_id;

    -- 3. Si lo permite, iteramos sobre los subtemas para actualizarlos
    IF v_allows_frequent THEN
        FOR v_subtopic_id IN 
            SELECT DISTINCT qs.subtopic_id 
            FROM question q
            LEFT JOIN question_subtopic qs ON q.id = qs.question_id
            WHERE q.parent_id = p_parent_question_id 
              AND qs.subtopic_id IS NOT NULL 
              AND qs.fl_status = true
        LOOP
            -- Ejecutamos la función por cada subtema
            PERFORM fn_change_subtopic_frequent_status(
                p_university_id::int, 
                v_subtopic_id::int, 
                p_user_id::int, 
                true, 
                p_method_system
            );
        END LOOP;
    END IF;

    -- 4. Retornamos la fila recién actualizada
    RETURN QUERY SELECT * FROM origin_parent_question WHERE id = p_id;
END;
$$;


ALTER FUNCTION questions.fn_edit_origin_parent_question(p_id bigint, p_parent_question_id bigint, p_year character varying, p_region_id bigint, p_university_id smallint, p_option_id smallint, p_modality_id smallint, p_areas jsonb, p_version smallint, p_user_id bigint, p_method_system character varying) OWNER TO postgres;

--
