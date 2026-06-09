-- Function: academic.fn_get_list_cycles(bigint)

--

CREATE FUNCTION academic.fn_get_list_cycles(p_company_id bigint) RETURNS TABLE(id bigint, code character varying, description character varying, weeks smallint, start_date date, end_date date, active boolean, week_types_descriptions jsonb, created_at timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    RETURN QUERY

                    WITH cycles AS (
                        SELECT
                            c.id,
                            c.code,
                            c.description,
                            c.weeks,
                            c.start_date,
                            c.end_date,
                            c.active,
                            COALESCE((
                                SELECT JSON_AGG(JSON_BUILD_OBJECT(
                                    'week', wk.week,
                                    'type_week_name',CASE
                                        WHEN wk.type_week_id = 1 THEN w.description
                                        ELSE tw.description
                                    END,
                                    'type_week_id' , tw.id,
                                    'type_week', tw.description
                                ) ORDER BY wk.week ASC)
                                FROM cycle_weeks wk
                                LEFT JOIN type_week tw ON wk.type_week_id = tw.id
                                LEFT JOIN week w ON w.id = wk.week
                                WHERE wk.cycle_id = c.id AND tw.id != 5
                                AND wk.fl_status = true
                            ), '[]')::JSONB AS week_types_descriptions,
                            c.created_at
                        FROM "cycle" c
                        WHERE c.active = true
                        AND c.deleted_at IS NULL
                        AND c.weeks IS NOT NULL
                        AND c.company_id = p_company_id
                        ORDER BY c.created_at DESC
                    ) SELECT * FROM cycles;
                END;
            $$;


ALTER FUNCTION academic.fn_get_list_cycles(p_company_id bigint) OWNER TO postgres;

--
