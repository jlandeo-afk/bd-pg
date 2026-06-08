-- Function: odiseo.fn_prospect(integer, integer, boolean, character varying)

--

CREATE FUNCTION odiseo.fn_prospect(p_perpage integer, p_npage integer, f_fl_validate boolean, p_text character varying) RETURNS TABLE(id bigint, name character varying, charge character varying, type_company character varying, name_institute character varying, document_number character varying, code_id bigint, code character varying, fl_validate boolean, fl_status boolean, total integer)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            total_count INTEGER;
            offset_val INTEGER;
        begin

            offset_val := p_perpage * (p_npage - 1);

            SELECT COUNT(*)
            INTO total_count
            FROM odiseo.prospect p
            LEFT JOIN odiseo.code_prospect c ON p.code_id = c.id
            WHERE
                p.deleted_at IS null
                AND (f_fl_validate IS NULL OR p.fl_validate = f_fl_validate)
                AND (p_text IS NULL
                OR unaccent(p.name) ILIKE '%' || unaccent(p_text) || '%'
                OR unaccent(p.name_institute) ILIKE '%' || unaccent(p_text) || '%'
                OR unaccent(p.document_number) ILIKE '%' || unaccent(p_text) || '%');

            RETURN QUERY
            SELECT
                p.id,
                p.name,
                p.charge,
                p.type_company,
                p.name_institute,
                p.document_number,
                p.code_id,
                c.code,
                p.fl_validate,
                p.fl_status,
                total_count AS total
            FROM odiseo.prospect p
            LEFT JOIN odiseo.code_prospect c ON p.code_id = c.id
            WHERE
                p.deleted_at IS null
                AND (f_fl_validate IS NULL OR p.fl_validate = f_fl_validate)
                AND (p_text IS NULL
                OR unaccent(p.name) ILIKE '%' || unaccent(p_text) || '%'
                OR unaccent(p.name_institute) ILIKE '%' || unaccent(p_text) || '%'
                OR unaccent(p.document_number) ILIKE '%' || unaccent(p_text) || '%')
            ORDER by p.name ASC, p.name_institute ASC
            LIMIT p_perpage
            OFFSET offset_val;
        END;
        $$;


ALTER FUNCTION odiseo.fn_prospect(p_perpage integer, p_npage integer, f_fl_validate boolean, p_text character varying) OWNER TO postgres;

--
