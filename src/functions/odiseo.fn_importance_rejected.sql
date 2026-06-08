-- Function: odiseo.fn_importance_rejected(character varying)

--

CREATE FUNCTION odiseo.fn_importance_rejected(p_search character varying) RETURNS TABLE(id smallint, level smallint, name character varying, fl_status boolean)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    i.id,
                    i.level,
                    i.name,
                    i.fl_status
                FROM odiseo.importance_rejected i
                WHERE (p_search IS NULL OR LOWER(i.name) = LOWER(p_search))
                ORDER BY i.level ASC;
            END;
            $$;


ALTER FUNCTION odiseo.fn_importance_rejected(p_search character varying) OWNER TO postgres;

--
