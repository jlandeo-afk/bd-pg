-- Function: common.fn_category_rejected(character varying)

--

CREATE FUNCTION common.fn_category_rejected(p_search character varying) RETURNS TABLE(id smallint, name character varying, fl_status boolean)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    c.id,
                    c.name,
                    c.fl_status
                FROM common.category_rejected c
                WHERE (p_search IS NULL OR LOWER(c.name) = LOWER(p_search))
                ORDER BY id ASC;
            END;
            $$;


ALTER FUNCTION common.fn_category_rejected(p_search character varying) OWNER TO postgres;

--
