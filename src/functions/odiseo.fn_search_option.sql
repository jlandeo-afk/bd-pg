-- Function: odiseo.fn_search_option(character varying, integer)

--

CREATE FUNCTION odiseo.fn_search_option(p_name character varying, p_university integer) RETURNS TABLE(id smallint, name character varying, fl_status boolean, created_by bigint, created_at timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    o.id,
                    o.name,
                    o.fl_status,
                    o.created_by,
                    o.created_at
                FROM
                    odiseo."option" o
                WHERE
                    unaccent(lower(o.name)) = unaccent(lower(p_name))
                    AND (p_university IS NULL OR p_university = ANY(o.university_ids));
            END;
            $$;


ALTER FUNCTION odiseo.fn_search_option(p_name character varying, p_university integer) OWNER TO postgres;

--
