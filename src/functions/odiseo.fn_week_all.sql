-- Function: odiseo.fn_week_all()

--

CREATE FUNCTION odiseo.fn_week_all() RETURNS TABLE(id smallint, description character varying)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    week.id,
					week.description
                FROM odiseo.week
                WHERE week.fl_status IS TRUE
                ORDER BY week.id ASC;
            END;
            $$;


ALTER FUNCTION odiseo.fn_week_all() OWNER TO postgres;

--
