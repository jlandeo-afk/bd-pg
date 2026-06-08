-- Function: odiseo.fn_save_origin_university(character varying, character varying, smallint, smallint, jsonb, text, text, bigint)

--

CREATE FUNCTION odiseo.fn_save_origin_university(p_name character varying, p_slug character varying, p_type smallint, p_region_id smallint, p_options jsonb, p_areas text, p_versions text, p_created_by bigint) RETURNS TABLE(v_validated boolean, v_type integer, v_id bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_exists_id SMALLINT;
    v_option_item JSONB;
    v_modality_item JSONB;
    v_new_id BIGINT;
    v_ou_id INT;
    v_code_uni VARCHAR;
BEGIN
    SELECT id INTO v_exists_id FROM origin_university
    WHERE LOWER(name) = LOWER(p_name) AND deleted_at IS NULL LIMIT 1;

    IF v_exists_id IS NOT NULL THEN
        RETURN QUERY SELECT FALSE, 1, 0::BIGINT;
        RETURN;
    END IF;

    SELECT LPAD(COALESCE(COUNT(id) + 1, 1)::TEXT, 3, '0') INTO v_code_uni FROM origin_university;

    INSERT INTO origin_university (
        code, name, slug, type, region_id, areas, versions, created_by, created_at
    )
    VALUES (
        v_code_uni, p_name, p_slug, p_type, p_region_id, p_areas, p_versions::jsonb, p_created_by, now()
    )
    RETURNING id INTO v_new_id;

    FOR v_option_item IN SELECT * FROM jsonb_array_elements(p_options) LOOP
        
        INSERT INTO option_university (
            university_id, 
            name, 
            created_at, 
            created_by
        )
        VALUES (
            v_new_id, 
            v_option_item->>'name', 
            now(), 
            p_created_by
        )
        RETURNING id INTO v_ou_id;

        FOR v_modality_item IN SELECT * FROM jsonb_array_elements(v_option_item->'modalities') LOOP
            
            INSERT INTO modality_options (
                option_university_id, 
                name, 
                fl_allows_mark_frequent_topic, 
                created_at, 
                created_by
            )
            VALUES (
                v_ou_id,
                v_modality_item->>'name',
                COALESCE((v_modality_item->>'fl_allows_mark_frequent_topic')::BOOLEAN, false),
                now(),
                p_created_by
            );

        END LOOP;
    END LOOP;

    -- Retornar éxito
    RETURN QUERY SELECT TRUE, 0, v_new_id;
END;
$$;


ALTER FUNCTION odiseo.fn_save_origin_university(p_name character varying, p_slug character varying, p_type smallint, p_region_id smallint, p_options jsonb, p_areas text, p_versions text, p_created_by bigint) OWNER TO postgres;

--
