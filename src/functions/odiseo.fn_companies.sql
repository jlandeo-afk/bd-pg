-- Function: odiseo.fn_companies(integer, integer, character varying)

--

CREATE FUNCTION odiseo.fn_companies(p_perpage integer, p_npage integer, p_text character varying) RETURNS TABLE(id bigint, uuid uuid, social_reason character varying, commercial_name character varying, type_company character varying, document_number character varying, domain_email character varying, schema character varying, address character varying, city character varying, state character varying, main_number character varying, other_number character varying, prospect_id bigint, plan_id bigint, plan character varying, plan_description character varying, plan_cost numeric, fl_status boolean, total integer)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            total_count INTEGER;
            offset_val INTEGER;
        begin

            offset_val := p_perpage * (p_npage - 1);

            SELECT COUNT(*)
            INTO total_count
            FROM odiseo.companies c
            LEFT JOIN odiseo.plans p ON c.plan_id = p.id
            WHERE
                (p_text IS NULL
                OR unaccent(c.social_reason) ILIKE '%' || unaccent(p_text) || '%'
                OR unaccent(c.commercial_name) ILIKE '%' || unaccent(p_text) || '%'
                OR unaccent(c.document_number) ILIKE '%' || unaccent(p_text) || '%');

            RETURN QUERY
            SELECT
                c.id,
                c.uuid,
                c.social_reason,
                c.commercial_name,
                c.type_company,
                c.document_number,
                c.domain_email,
                c."schema",
                c.address,
                c.city,
                c.state,
                c.main_number,
                c.other_number,
                c.prospect_id,
                c.plan_id,
                p.name AS plan,
                p.description AS plan_description,
                p.cost AS plan_cost,
                c.fl_status,
                total_count AS total
            FROM odiseo.companies c
            LEFT JOIN odiseo.plans p ON c.plan_id = p.id
            WHERE
                (p_text IS NULL
                OR unaccent(c.social_reason) ILIKE '%' || unaccent(p_text) || '%'
                OR unaccent(c.commercial_name) ILIKE '%' || unaccent(p_text) || '%'
                OR unaccent(c.document_number) ILIKE '%' || unaccent(p_text) || '%')
            ORDER by c.social_reason ASC, c.document_number ASC
            LIMIT p_perpage
            OFFSET offset_val;
        END;
        $$;


ALTER FUNCTION odiseo.fn_companies(p_perpage integer, p_npage integer, p_text character varying) OWNER TO postgres;

--
