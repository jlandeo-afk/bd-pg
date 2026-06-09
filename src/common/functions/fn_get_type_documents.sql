-- Function: common.fn_get_type_documents()

--

CREATE FUNCTION common.fn_get_type_documents() RETURNS TABLE(id bigint, document character varying, description character varying, created_by bigint, updated_by bigint, created_at timestamp without time zone, updated_at timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            SELECT *
            FROM type_documents td;
        END;
        $$;


ALTER FUNCTION common.fn_get_type_documents() OWNER TO postgres;

--
