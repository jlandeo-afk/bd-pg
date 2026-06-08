-- Function: odiseo.fn_modalities_university(integer, integer)

--

CREATE FUNCTION odiseo.fn_modalities_university(p_options integer, p_university integer) RETURNS TABLE(id integer, name character varying, option_ids jsonb)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        mo.id::INT,
        mo.name::VARCHAR,
        (
            -- Subconsulta: Trae todas las opciones de la universidad (igual que tu lógica anterior)
            SELECT COALESCE(jsonb_agg(jsonb_build_object('id', ou_sub.id, 'name', ou_sub.name)), '[]'::jsonb)
            FROM option_university ou_sub
            WHERE ou_sub.deleted_at IS NULL
              AND (p_university IS NULL OR ou_sub.university_id = p_university)
        ) AS option_ids
    FROM modality_options mo
    INNER JOIN option_university ou ON mo.option_university_id = ou.id
    WHERE mo.deleted_at IS NULL
      AND ou.deleted_at IS NULL
      -- Filtrar por opción si se envía el parámetro
      AND (p_options IS NULL OR ou.id = p_options)
      -- Filtrar por universidad si se envía el parámetro
      AND (p_university IS NULL OR ou.university_id = p_university)
    ORDER BY mo.id ASC;
END;
$$;


ALTER FUNCTION odiseo.fn_modalities_university(p_options integer, p_university integer) OWNER TO postgres;

--
