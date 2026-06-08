-- Function: odiseo.fn_create_headquarter(character varying, character varying, character varying, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_create_headquarter(p_name character varying, p_slug character varying, p_address character varying, p_company_id bigint, p_created_by bigint) RETURNS TABLE(id smallint, name character varying, slug character varying, address character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH inserted_headquarter AS (
        INSERT INTO headquarters AS h (name, slug, address, created_by, created_at)
        VALUES (
            p_name,
            p_slug,
            p_address,
            p_created_by,
            NOW()
        )
        RETURNING
            h.id,
            h.name,
            h.slug,
            h.address
    ), inserted_headquarter_company AS (
        INSERT INTO company_headquarters as ch (headquarter_id, company_id, created_by, created_at)
        SELECT ih.id, p_company_id, p_created_by, NOW()
        FROM inserted_headquarter ih
        RETURNING ch.id
    )
    SELECT
        ih.id,
        ih.name,
        ih.slug,
        ih.address
    FROM inserted_headquarter ih;
END;
$$;


ALTER FUNCTION odiseo.fn_create_headquarter(p_name character varying, p_slug character varying, p_address character varying, p_company_id bigint, p_created_by bigint) OWNER TO postgres;

--
