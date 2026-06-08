-- Function: odiseo.fn_get_type_documents()

--

CREATE FUNCTION odiseo.fn_get_type_documents() RETURNS TABLE(id bigint, document character varying, description character varying, created_by integer, updated_by integer)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            SELECT
                td.id,
                td.name AS document,
                td.description,
                td.created_by,
                td.updated_by
            FROM type_documents td;
        END;
        $$;


ALTER FUNCTION odiseo.fn_get_type_documents() OWNER TO postgres;

--
