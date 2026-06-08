-- Function: odiseo.fn_get_periods_weeks_on_type_material(bigint, smallint)

--

CREATE FUNCTION odiseo.fn_get_periods_weeks_on_type_material(p_type_material_id bigint, p_week smallint) RETURNS TABLE(starting_week smallint, ending_week smallint, period_number smallint)
    LANGUAGE plpgsql
    AS $$
    DECLARE C_DEFAULT_STARTING_WEEK SMALLINT DEFAULT 1;
    BEGIN
        RETURN QUERY
        WITH get_periods_of_weeks AS (
            SELECT
                *
            FROM type_material_detail_template
            WHERE 1 = 1
              AND type_material_id = p_type_material_id
              AND fl_status IS TRUE
            ORDER BY week ASC
        ), periods AS (
            SELECT
                COALESCE(LAG(per.week) OVER (ORDER BY per.week), 0) + 1 AS starting_week,
                per.week AS ending_week
            FROM get_periods_of_weeks per
            WHERE 1 = 1
              AND per.week <= p_week
        ), get_current_period AS (
            SELECT
                ps.starting_week AS starting_week,
                ps.ending_week AS ending_week
            FROM periods ps
            ORDER BY
                ps.starting_week DESC
            LIMIT 1
        ), set_review_period AS (
            SELECT
                C_DEFAULT_STARTING_WEEK AS starting_week,
                CASE
                    WHEN ( SELECT COUNT(*) FROM periods ) > 1 THEN ( SELECT gp.starting_week - 1 FROM get_current_period gp )
                    ELSE p_week
                END AS ending_week
        ), join_periods AS (
            SELECT * FROM get_current_period 
            UNION
            SELECT * FROM set_review_period
        ), assign_period_number AS (
            SELECT
                ar.starting_week::SMALLINT,
                ar.ending_week::SMALLINT,
                (ROW_NUMBER() OVER (ORDER BY ar.ending_week DESC))::SMALLINT AS period_number
            FROM join_periods AS ar 
        ) SELECT * FROM assign_period_number;
    END;
$$;


ALTER FUNCTION odiseo.fn_get_periods_weeks_on_type_material(p_type_material_id bigint, p_week smallint) OWNER TO postgres;

--
