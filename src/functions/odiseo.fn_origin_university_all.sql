-- Function: odiseo.fn_origin_university_all(smallint, character varying)

--

CREATE FUNCTION odiseo.fn_origin_university_all(f_type smallint, p_name_text character varying) RETURNS TABLE(id smallint, code character varying, name character varying, slug character varying, type smallint, region_id smallint, region character varying, options jsonb, areas text, versions jsonb)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.id, u.code, u.name, u.slug, u.type, u.region_id,
        r.name AS region,
        (
            -- Subconsulta de Opciones usando la tabla pivote
            SELECT COALESCE(jsonb_agg(option_data), '[]'::jsonb)
            FROM (
                SELECT ou.id AS id, ou.name,
                    (
                        -- Subconsulta de Modalidades usando la tabla pivote
                        SELECT COALESCE(jsonb_agg(modality_data), '[]'::jsonb)
                        FROM (
                            SELECT mo.id AS id, mo.name
                            FROM modality_options mo
                            WHERE mo.option_university_id = ou.id
                                AND mo.deleted_at IS NULL
                            ORDER BY mo.id ASC
                        ) modality_data
                    ) AS modalities
                FROM option_university ou
                WHERE ou.university_id = u.id
                    AND ou.deleted_at IS NULL
                ORDER BY ou.id ASC
            ) option_data
        ) AS options,
        u.areas,
        (
            SELECT JSONB_AGG(JSONB_BUILD_OBJECT('order', e->>'order', 'version', fn_number_to_roman((e->>'version')::SMALLINT)))
            FROM JSONB_ARRAY_ELEMENTS(u.versions::JSONB) e
        ) AS versions
    FROM origin_university u
    LEFT JOIN region r ON u.region_id = r.id
    WHERE u.deleted_by IS NULL
        AND u.fl_active = true
        AND (f_type IS NULL OR u.type = f_type)
        AND (
            p_name_text IS NULL
            OR LOWER(u.name) LIKE '%' || LOWER(p_name_text) || '%'
            OR LOWER(u.slug) LIKE '%' || LOWER(p_name_text) || '%'
        )
    ORDER BY u.id ASC;
END;
$$;


ALTER FUNCTION odiseo.fn_origin_university_all(f_type smallint, p_name_text character varying) OWNER TO postgres;

--
