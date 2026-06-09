-- Function: academic.fn_edit_origin_university(smallint, character varying, character varying, smallint, smallint, jsonb, text, text, bigint)

--

CREATE FUNCTION academic.fn_edit_origin_university(p_id smallint, p_name character varying, p_slug character varying, p_type smallint, p_region_id smallint, p_options jsonb, p_areas text, p_versions text, p_updated_by bigint) RETURNS TABLE(v_validated boolean, v_type integer, v_id bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_university_exists_id SMALLINT;
    v_option_json_item    JSONB;
    v_modality_json_item  JSONB;
    v_option_university_id INT;
    v_modality_option_id   INT;
BEGIN
    v_validated := TRUE;
    v_type      := 0;
    v_id        := p_id::BIGINT;

    -- 2. Validar nombre duplicado
    SELECT id INTO v_university_exists_id 
    FROM origin_university
    WHERE LOWER(name) = LOWER(p_name) 
      AND id <> p_id 
      AND deleted_at IS NULL 
    LIMIT 1;

    IF v_university_exists_id IS NOT NULL THEN
        v_validated := FALSE;
        v_type      := 1;
        v_id        := 0;
        RETURN NEXT; 
        RETURN;
    END IF;

    -- 3. Actualizar Universidad principal
    UPDATE origin_university
    SET name       = p_name,
        slug       = p_slug,
        type       = p_type,
        region_id  = p_region_id,
        areas      = p_areas,
        versions   = p_versions::jsonb,
        updated_by = p_updated_by,
        updated_at = now()
    WHERE id = p_id
    RETURNING id INTO v_id;

    -- 4. Soft delete preventivo de opciones
    UPDATE option_university
    SET deleted_at = now(), 
        deleted_by = p_updated_by
    WHERE university_id = v_id 
      AND deleted_at IS NULL;

    -- 5. Procesar Opciones
    FOR v_option_json_item IN SELECT * FROM jsonb_array_elements(p_options) LOOP
        v_option_university_id := NULL; 

        -- A. Buscar por ID
        IF (v_option_json_item->>'id') IS NOT NULL AND (v_option_json_item->'id') <> 'null'::jsonb THEN
            UPDATE option_university
            SET name       = v_option_json_item->>'name',
                updated_at = now(),
                updated_by = p_updated_by,
                deleted_at = NULL,
                deleted_by = NULL
            WHERE id = (v_option_json_item->>'id')::INT
              AND university_id = v_id
            RETURNING id INTO v_option_university_id;
        END IF;

        -- C. Insertar si no existe
        IF v_option_university_id IS NULL THEN
            INSERT INTO option_university (university_id, name, created_at, created_by)
            VALUES (v_id, v_option_json_item->>'name', now(), p_updated_by)
            RETURNING id INTO v_option_university_id;
        END IF;

        -- 6. Soft delete preventivo de modalidades
        UPDATE modality_options
        SET deleted_at = now(), 
            deleted_by = p_updated_by
        WHERE option_university_id = v_option_university_id 
          AND deleted_at IS NULL;

        -- 7. Procesar Modalidades
        FOR v_modality_json_item IN SELECT * FROM jsonb_array_elements(v_option_json_item->'modalities') LOOP
            v_modality_option_id := NULL; 

            -- A. Buscar modalidad por ID
            IF (v_modality_json_item->>'id') IS NOT NULL AND (v_modality_json_item->'id') <> 'null'::jsonb THEN
                UPDATE modality_options
                SET name                          = v_modality_json_item->>'name',
                    fl_allows_mark_frequent_topic = COALESCE((v_modality_json_item->>'fl_allows_mark_frequent_topic')::BOOLEAN, false),
                    updated_at                    = now(),
                    updated_by                    = p_updated_by,
                    deleted_at                    = NULL,
                    deleted_by                    = NULL
                WHERE id = (v_modality_json_item->>'id')::INT
                  AND option_university_id = v_option_university_id
                RETURNING id INTO v_modality_option_id;
            END IF;

            -- B. Buscar modalidad por nombre
            IF v_modality_option_id IS NULL THEN
                SELECT id INTO v_modality_option_id 
                FROM modality_options
                WHERE LOWER(name) = LOWER(v_modality_json_item->>'name') 
                  AND option_university_id = v_option_university_id 
                LIMIT 1;

                IF v_modality_option_id IS NOT NULL THEN
                    UPDATE modality_options
                    SET fl_allows_mark_frequent_topic = COALESCE((v_modality_json_item->>'fl_allows_mark_frequent_topic')::BOOLEAN, false),
                        updated_at                    = now(),
                        updated_by                    = p_updated_by,
                        deleted_at                    = NULL,
                        deleted_by                    = NULL
                    WHERE id = v_modality_option_id;
                END IF;
            END IF;

            -- C. Insertar modalidad nueva
            IF v_modality_option_id IS NULL THEN
                INSERT INTO modality_options (
                    option_university_id, name, fl_allows_mark_frequent_topic, created_at, created_by
                )
                VALUES (
                    v_option_university_id,
                    v_modality_json_item->>'name',
                    COALESCE((v_modality_json_item->>'fl_allows_mark_frequent_topic')::BOOLEAN, false),
                    now(),
                    p_updated_by
                );
            END IF;
        END LOOP;
    END LOOP;

    RETURN NEXT;
END;
$$;


ALTER FUNCTION academic.fn_edit_origin_university(p_id smallint, p_name character varying, p_slug character varying, p_type smallint, p_region_id smallint, p_options jsonb, p_areas text, p_versions text, p_updated_by bigint) OWNER TO postgres;

--
