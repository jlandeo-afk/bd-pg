-- Function: odiseo.fn_region(character varying)

--

CREATE FUNCTION odiseo.fn_region(p_name_text character varying) RETURNS TABLE(id bigint, name character varying)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    r.id,
                    r.name
                FROM odiseo.region r
                WHERE r.fl_status = true
				AND (
                    p_name_text IS NULL
                    OR LOWER(r.name) LIKE '%' || LOWER(p_name_text) || '%'
                )
				ORDER BY r.id ASC;
            END;
            $$;


ALTER FUNCTION odiseo.fn_region(p_name_text character varying) OWNER TO postgres;

--
