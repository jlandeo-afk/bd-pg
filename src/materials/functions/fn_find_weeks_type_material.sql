-- Function: materials.fn_find_weeks_type_material(smallint, smallint)

--

CREATE FUNCTION materials.fn_find_weeks_type_material(p_type_material_id smallint, p_week smallint) RETURNS TABLE(id bigint, type_material_id smallint, week smallint, weeks_detail text)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            WITH previous_week AS (
                SELECT COALESCE(MAX(tmdt.week), 0) AS last_week
                FROM materials.type_material_detail_template tmdt
                WHERE tmdt.type_material_id = p_type_material_id
                AND tmdt.fl_status = true
                AND tmdt.week < p_week
            ), first_week AS (
                SELECT MIN(tmdt2.week) AS first_week
                FROM materials.type_material_detail_template tmdt2
                WHERE tmdt2.type_material_id = p_type_material_id
                AND tmdt2.fl_status = true
            )
            SELECT
                tmdt.id,
                tmdt.type_material_id,
                tmdt.week,
                STRING_AGG(gs.week::TEXT, ', ') AS weeks_detail
            FROM  materials.type_material_detail_template tmdt
            JOIN previous_week pw ON true
            JOIN first_week fw ON true
            JOIN LATERAL (
                SELECT generate_series(
                    CASE WHEN pw.last_week = 0 THEN 1 ELSE pw.last_week + 1 END,
                    tmdt.week
                ) AS week
            ) gs ON true
            WHERE tmdt.type_material_id = p_type_material_id
            AND tmdt.fl_status = true
            AND tmdt.week = p_week
            GROUP BY tmdt.id, tmdt.type_material_id, tmdt.week, pw.last_week, fw.first_week;
        END;
        $$;


ALTER FUNCTION materials.fn_find_weeks_type_material(p_type_material_id smallint, p_week smallint) OWNER TO postgres;

--
