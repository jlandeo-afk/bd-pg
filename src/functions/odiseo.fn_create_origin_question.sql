-- Function: odiseo.fn_create_origin_question(bigint, character varying, bigint, smallint, smallint, smallint, jsonb, smallint, bigint, character varying)

--

CREATE FUNCTION odiseo.fn_create_origin_question(p_question_id bigint, p_year character varying, p_region_id bigint, p_university_id smallint, p_option_id smallint, p_modality_id smallint, p_areas jsonb, p_version smallint, p_user_id bigint, p_method_system character varying) RETURNS SETOF odiseo.origin_question
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_new_id bigint;
    v_allows_frequent boolean;
    v_subtopic_id bigint;
BEGIN
        INSERT INTO origin_question (
            question_id, 
            year, 
            region_id,
            modality_option_id, 
            areas, 
            version, 
            created_by, 
            created_at
        ) VALUES (
            p_question_id, 
            p_year, 
            p_region_id, 
            p_modality_id, 
            p_areas, 
            p_version, 
            p_user_id, 
            NOW()
        ) RETURNING id INTO v_new_id;


    SELECT fl_allows_mark_frequent_topic INTO v_allows_frequent 
    FROM modality_options 
    WHERE id = p_modality_id;

    IF v_allows_frequent THEN
        FOR v_subtopic_id IN 
            SELECT DISTINCT subtopic_id 
            FROM question_subtopic
            WHERE question_id = p_question_id 
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

    RETURN QUERY SELECT * FROM origin_question WHERE id = v_new_id;
    
END;
$$;


ALTER FUNCTION odiseo.fn_create_origin_question(p_question_id bigint, p_year character varying, p_region_id bigint, p_university_id smallint, p_option_id smallint, p_modality_id smallint, p_areas jsonb, p_version smallint, p_user_id bigint, p_method_system character varying) OWNER TO postgres;

--
