-- Function: questions.fn_edit_origin_question(bigint, character varying, bigint, smallint, smallint, smallint, jsonb, smallint, bigint, character varying)

--

CREATE FUNCTION questions.fn_edit_origin_question(p_id bigint, p_year character varying, p_region_id bigint, p_university_id smallint, p_option_id smallint, p_modality_id smallint, p_areas jsonb, p_version smallint, p_user_id bigint, p_method_system character varying) RETURNS SETOF questions.origin_question
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_question_id bigint;
    v_allows_frequent boolean;
    v_subtopic_id bigint;
BEGIN
    -- 1. Obtenemos el question_id original antes de cualquier cambio
    SELECT question_id INTO v_question_id 
    FROM origin_question 
    WHERE id = p_id;

    -- 2. Actualizamos el registro (sin tocar el question_id por seguridad)
    UPDATE origin_question 
    SET 
        year = p_year,
        region_id = p_region_id,
        modality_option_id = p_modality_id, 
        areas = p_areas,
        version = p_version,
        updated_by = p_user_id,
        updated_at = NOW()
    WHERE id = p_id;

    -- 3. Verificamos si la nueva configuración de modalidad permite temas frecuentes
    SELECT mo.fl_allows_mark_frequent_topic INTO v_allows_frequent 
    FROM modality_options mo
    WHERE mo.id = p_modality_id;

    -- 4. Si lo permite, ejecutamos la lógica de temas frecuentes
    IF v_allows_frequent THEN
        FOR v_subtopic_id IN 
            SELECT DISTINCT subtopic_id 
            FROM question_subtopic
            WHERE question_id = v_question_id -- Usamos la variable capturada arriba
              AND subtopic_id IS NOT NULL 
              AND fl_status = true
        LOOP
            PERFORM fn_change_subtopic_frequent_status(
                p_university_id::int, 
                v_subtopic_id::int, 
                p_user_id::int, 
                true, 
                p_method_system
            );
        END LOOP;
    END IF;

    -- 5. Retornamos el registro editado
    RETURN QUERY SELECT * FROM origin_question WHERE id = p_id;
END;
$$;


ALTER FUNCTION questions.fn_edit_origin_question(p_id bigint, p_year character varying, p_region_id bigint, p_university_id smallint, p_option_id smallint, p_modality_id smallint, p_areas jsonb, p_version smallint, p_user_id bigint, p_method_system character varying) OWNER TO postgres;

--
