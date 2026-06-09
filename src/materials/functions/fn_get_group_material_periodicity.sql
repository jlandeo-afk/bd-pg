-- Function: materials.fn_get_group_material_periodicity(bigint)

--

CREATE FUNCTION materials.fn_get_group_material_periodicity(p_material_id bigint) RETURNS TABLE(id smallint, description character varying, material_id bigint, fl_class_material boolean, fl_exam boolean, periodicity_id smallint, period character varying, quantity smallint, start_week smallint, group_previous_week boolean, group_remaining_week boolean, weeks jsonb, material_per_period jsonb, weeks_dates jsonb)
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                        RETURN QUERY
                        WITH tbl_material AS (
                            SELECT
                                m.id,
                                m.cycle_id,
                                m.university_id
                            FROM material m
                            JOIN cycle c ON m.cycle_id = c.id
                            WHERE m.id = p_material_id
                        ), tbl_material_per_period AS (
                            SELECT
                                mpp.material_id,
                                mpp.type_material_id,
                                COALESCE(mppb.start_week, mppe.start_week) AS start_week,
                                COALESCE(mppb.end_week, mppe.end_week) AS end_week
                            FROM material_per_period mpp
                            LEFT JOIN material_per_period_ballot mppb ON mpp.id = mppb.material_per_period_id
                            LEFT JOIN material_per_period_exam mppe ON mpp.id = mppe.material_per_period_id
                            WHERE mpp.material_id = p_material_id
                                AND mpp.deleted_by IS NULL
                                AND mppb.deleted_by IS NULL
                                AND mppe.deleted_by IS NULL
                        ), tbl_type_material AS (
                            SELECT
                                tm.id,
                                tm.description,
                                m.id AS material_id,
                                tm.fl_class_material,
                                tm.fl_exam,
                                COALESCE(tmp.periodicity_id, 1::SMALLINT) AS periodicity_id,
                                COALESCE(p.name, 'Semanal') AS period,
                                COALESCE(p.quantity, tmp.quantity_week, 1::SMALLINT) AS quantity,
                                COALESCE(tmp.start_week, 1::SMALLINT) AS start_week,
                                COALESCE(tmp.group_previous_week, false) AS group_previous_week,
                                COALESCE(tmp.group_remaining_week, false) AS group_remaining_week,
                                COALESCE((
                                    SELECT jsonb_agg(tmdt.week ORDER BY tmdt.week ASC)
                                    FROM type_material_detail_template tmdt
                                    WHERE tmdt.type_material_id = tm.id
                                        AND tmdt.fl_status = true
                                ), '[]'::JSONB) AS weeks,
                                COALESCE((
                                    SELECT jsonb_agg(jsonb_build_object(
                                        'type_material_id', tmpp.type_material_id,
                                        'start_week', tmpp.start_week,
                                        'end_week', tmpp.end_week
                                    )) AS per_period
                                    FROM tbl_material_per_period tmpp
                                    WHERE tmpp.type_material_id = tm.id
                                        AND tmpp.start_week IS NOT NULL
                                        AND tmpp.end_week IS NOT NULL
                                ), '[]'::JSONB) AS material_per_period,
                                COALESCE((
                                    SELECT jsonb_agg(
                                        jsonb_build_object(
                                            'week', tmdt.week,
                                            'start_date', cw.start_date,
                                            'end_date', cw.end_date
                                        ) ORDER BY tmdt.week ASC
                                    )
                                    FROM type_material_detail_template tmdt
                                    JOIN cycle_weeks cw ON tmdt.week = cw.week AND cw.cycle_id = m.cycle_id
                                    WHERE tmdt.type_material_id = tm.id
                                        AND tmdt.fl_status = true
                                ), '[]'::JSONB) AS weeks_dates

                            FROM type_material tm
                            JOIN tbl_material m ON tm.cycle_id = m.cycle_id
                            LEFT JOIN type_material_periodicity tmp ON tm.id = tmp.type_material_id
                                AND tmp.fl_status = true
                            LEFT JOIN periodicity p ON tmp.periodicity_id = p.id
                            WHERE tm.fl_status = true
                                AND tm.parent_id IS NULL
                        )
                        SELECT * FROM tbl_type_material ttm
                        ORDER BY
                            ttm.fl_exam ASC,
                            ttm.description ASC;
                    END;
                    $$;


ALTER FUNCTION materials.fn_get_group_material_periodicity(p_material_id bigint) OWNER TO postgres;

--
