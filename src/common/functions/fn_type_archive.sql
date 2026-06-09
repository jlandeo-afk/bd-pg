-- Function: common.fn_type_archive()

--

CREATE FUNCTION common.fn_type_archive() RETURNS TABLE(id smallint, name character varying, extension character varying, fl_status boolean)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    t.id,
                    t.name,
                    t.extension,
                    t.fl_status
                FROM common.type_archive t
                WHERE t.fl_status = true
                ORDER BY t.id ASC;
            END;
            $$;


ALTER FUNCTION common.fn_type_archive() OWNER TO postgres;

--
