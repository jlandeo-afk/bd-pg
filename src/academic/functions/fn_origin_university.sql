-- Function: academic.fn_origin_university(integer, integer, smallint, character varying, boolean)

--

CREATE FUNCTION academic.fn_origin_university(p_perpage integer, p_npage integer, p_type smallint, p_name_text character varying, p_fl_active boolean) RETURNS TABLE(id smallint, code character varying, name character varying, slug character varying, type smallint, region_id smallint, fl_active boolean, region character varying, options jsonb, areas text, versions jsonb, total integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_total_count   integer;
    v_offset        integer;
BEGIN
    v_offset := p_perpage * (p_npage - 1);

    -- 1. Conteo total
    SELECT COUNT(*) INTO v_total_count
    FROM origin_university u
    WHERE u.deleted_by IS NULL
      AND (p_fl_active IS NULL OR u.fl_active = p_fl_active)
      AND (p_type      IS NULL OR u.type      = p_type) -- Usando p_type
      AND (
            p_name_text IS NULL
            OR LOWER(u.name) LIKE '%' || LOWER(p_name_text) || '%'
            OR LOWER(u.slug) LIKE '%' || LOWER(p_name_text) || '%'
          );

    RETURN QUERY
    WITH
    -- 2. Universidades filtradas y paginadas
    filtered_universities AS (
        SELECT u.*
        FROM origin_university u
        WHERE u.deleted_by IS NULL
          AND (p_fl_active IS NULL OR u.fl_active = p_fl_active)
          AND (p_type      IS NULL OR u.type      = p_type) -- Usando p_type
          AND (
                p_name_text IS NULL
                OR LOWER(u.name) LIKE '%' || LOWER(p_name_text) || '%'
                OR LOWER(u.slug) LIKE '%' || LOWER(p_name_text) || '%'
              )
        ORDER BY u.id
        LIMIT  p_perpage
        OFFSET v_offset
    ),

    -- 3. Agrupamos modalidades por cada 'option_university'
    modalities_grouped AS (
        SELECT 
            mo.option_university_id,
            JSONB_AGG(
                JSONB_BUILD_OBJECT(
                    'id',   mo.id, 
                    'name', mo.name,
                    'fl_allows_mark_frequent_topic', mo.fl_allows_mark_frequent_topic
                ) ORDER BY mo.id
            ) AS modalities_list
        FROM modality_options mo
        WHERE mo.deleted_at IS NULL
        GROUP BY mo.option_university_id
    ),

    -- 4. Agrupamos las opciones por universidad e inyectamos sus modalidades
    university_options AS (
        SELECT
            ou.university_id,
            JSONB_AGG(
                JSONB_BUILD_OBJECT(
                    'id',         ou.id,
                    'name',        ou.name,
                    'modalities', COALESCE(mg.modalities_list, '[]'::jsonb)
                ) ORDER BY ou.id
            ) AS options_list
        FROM option_university ou
        LEFT JOIN modalities_grouped mg ON mg.option_university_id = ou.id
        WHERE ou.university_id IN (SELECT f.id FROM filtered_universities f)
        AND ou.deleted_at IS NULL
        GROUP BY ou.university_id
    ),

    -- 5. Procesamos versiones
    university_versions AS (
        SELECT
            u.id AS university_id,
            JSONB_AGG(
                JSONB_BUILD_OBJECT(
                    'order',   e ->> 'order',
                    'version', fn_number_to_roman((e ->> 'version')::smallint)
                )
            ) AS versions_list
        FROM filtered_universities u,
             JSONB_ARRAY_ELEMENTS(u.versions::jsonb) e
        GROUP BY u.id
    )

    -- 6. Resultado final uniendo todo
    SELECT
        u.id,
        u.code,
        u.name,
        u.slug,
        u.type,
        u.region_id,
        u.fl_active,
        r.name AS region,
        COALESCE(uo.options_list, '[]'::jsonb),
        u.areas,
        COALESCE(uv.versions_list, '[]'::jsonb),
        v_total_count
    FROM filtered_universities u
    LEFT JOIN region r ON r.id = u.region_id
    LEFT JOIN university_options uo ON uo.university_id = u.id
    LEFT JOIN university_versions uv ON uv.university_id = u.id
    ORDER BY u.id;

END;
$$;


ALTER FUNCTION academic.fn_origin_university(p_perpage integer, p_npage integer, p_type smallint, p_name_text character varying, p_fl_active boolean) OWNER TO postgres;

--
