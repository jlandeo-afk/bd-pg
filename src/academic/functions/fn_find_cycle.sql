-- Function: academic.fn_find_cycle(bigint, bigint)

--

CREATE FUNCTION academic.fn_find_cycle(f_cycle_id bigint, f_company_id bigint) RETURNS TABLE(id bigint, code character varying, description character varying, created_by text, created_at timestamp without time zone, year smallint, month smallint, weeks smallint, start_date date, end_date date, active boolean, days smallint, type_template_id bigint, cycle_type_id bigint, weeks_data jsonb)
    LANGUAGE plpgsql
    AS $$
                        BEGIN
                            RETURN QUERY
                            WITH tbl_cycle AS (
                                SELECT
                                    c.id,
                                    c.code,
                                    c.description,
                                    CASE
                                        WHEN e.first_name IS NOT NULL AND e.first_surname IS NOT NULL THEN
                                            CONCAT(initcap(split_part(e.first_name, ' ', 1)), ' ', upper(left(e.first_surname, 1)), '. ', initcap(e.second_surname))
                                        ELSE
                                            NULL
                                    END AS created_by,
                                    c.created_at,
                                    c.year,
                                    c.month,
                                    c.weeks,
                                    c.start_date,
                                    c.end_date,
                                    c.active,
                                    c.days,
                                    c.type_template_id,
                                    c.cycle_type_id,
                                    COALESCE((
                                        SELECT json_agg(json_build_object(
                                            'id', wk.id,
                                            'week', wk.week,
                                            'type_week_id', wk.type_week_id,
                                            'type_week_name', tw.description,
                                            'start_date', wk.start_date,
                                            'end_date', wk.end_date,
                                            'cycle_id', wk.cycle_id,
                                            'color', tw.color
                                        ) ORDER BY wk.start_date)
                                        FROM cycle_weeks wk
                                        LEFT JOIN type_week tw ON wk.type_week_id = tw.id
                                        WHERE wk.cycle_id = c.id
                                        AND wk.fl_status = true
                                    ), '[]')::JSONB AS weeks_data
                                FROM cycle c
                                LEFT JOIN users u ON c.created_by = u.id
                                LEFT JOIN employees e ON u.id = e.user_id
                                WHERE c.fl_status = true
                                    AND c.id = f_cycle_id
                                    AND c.company_id = f_company_id
                                GROUP BY
                                    c.id,
                                    c.code,
                                    c.description,
                                    e.first_name,
                                    e.first_surname,
                                    e.second_surname,
                                    c.created_at,
                                    c.year,
                                    c.month,
                                    c.weeks,
                                    c.start_date,
                                    c.end_date,
                                    c.active,
                                    c.days,
                                    c.type_template_id
                            )
                            SELECT * FROM tbl_cycle;
                        END;
                        $$;


ALTER FUNCTION academic.fn_find_cycle(f_cycle_id bigint, f_company_id bigint) OWNER TO postgres;

--
