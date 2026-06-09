-- Function: organization.fn_list_universities_by_region(smallint)

--

CREATE FUNCTION organization.fn_list_universities_by_region(p_region_id smallint) RETURNS TABLE(id smallint, code character varying, name character varying, slug character varying, type smallint, region_id smallint, region character varying, options jsonb, areas text, versions jsonb)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                    SELECT
                        u.id, u.code, u.name, u.slug, u.type, u.region_id,
                        r.name AS region,
                        (
                            -- Subconsulta de Opciones (Mapeado a option_university)
                            SELECT COALESCE(jsonb_agg(option_data), '[]'::jsonb)
                            FROM (
                                SELECT ou.id, ou.name,
                                    (
                                        -- Subconsulta de Modalidades (Mapeado a modality_options)
                                        SELECT COALESCE(jsonb_agg(modality_data), '[]'::jsonb)
                                        FROM (
                                            SELECT mo.id, mo.name
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
                    AND (p_region_id IS NULL OR u.region_id = p_region_id)
                    ORDER BY u.name ASC;
            END;
            $$;


ALTER FUNCTION organization.fn_list_universities_by_region(p_region_id smallint) OWNER TO postgres;

--
