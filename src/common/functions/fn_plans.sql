-- Function: common.fn_plans()

--

CREATE FUNCTION common.fn_plans() RETURNS TABLE(id bigint, name character varying, description character varying, cost numeric, benefits character varying, number_users smallint, number_questions smallint, fl_status boolean)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    p.id,
                    p.name,
                    p.description,
                    p.cost,
                    p.benefits,
                    p.number_users,
                    p.number_questions,
                    p.fl_status
                FROM odiseo."plans" p
                WHERE p.fl_status = true
				ORDER BY p.id ASC;
            END;
            $$;


ALTER FUNCTION common.fn_plans() OWNER TO postgres;

--
