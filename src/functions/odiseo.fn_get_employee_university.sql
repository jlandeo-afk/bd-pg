-- Function: odiseo.fn_get_employee_university(integer, integer, bigint, smallint, character varying)

--

CREATE FUNCTION odiseo.fn_get_employee_university(p_per_page integer, p_n_page integer, p_employee_id bigint, p_university_id smallint, p_search character varying) RETURNS TABLE(id bigint, code character varying, employee_id bigint, first_name character varying, first_surname character varying, second_surname character varying, document character varying, charge_id bigint, charge character varying, university_id smallint, university character varying, slug character varying, total bigint)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            total_count INTEGER;
            offset_val INTEGER;
        BEGIN
            offset_val := p_per_page * (p_n_page - 1);

            RETURN QUERY
            WITH tbl_employee_university AS (
                SELECT
                    eu.id,
                    e.code,
                    eu.employee_id,
                    e.first_name,
                    e.first_surname,
                    e.second_surname,
                    e.document,
                    e.charge_id,
                    c.name AS charge,
                    eu.university_id,
                    u.name AS university,
                    u.slug
                FROM odiseo.employee_university eu
                INNER JOIN odiseo.employees e ON eu.employee_id = e.id
                INNER JOIN odiseo.charge c ON c.id = e.charge_id
                INNER JOIN odiseo.origin_university u ON eu.university_id = u.id
                WHERE 1 = 1
                AND e.fl_status IS TRUE
                AND (p_employee_id IS NULL OR eu.employee_id = p_employee_id)
                AND (p_university_id IS NULL OR eu.university_id = p_university_id)
                AND (p_search IS NULL OR
                    LOWER(e.first_name) ILIKE '%' || LOWER(p_search) || '%' OR
                    LOWER(e.first_surname) ILIKE '%' || LOWER(p_search) || '%' OR
                    LOWER(e.second_surname) ILIKE '%' || LOWER(p_search) || '%')
            )
            SELECT tbl.*,  COUNT(*) OVER () AS total
            FROM  tbl_employee_university tbl
            ORDER BY
                UNACCENT(tbl.first_name) ASC,
                UNACCENT(tbl.first_surname) ASC,
                UNACCENT(tbl.second_surname) ASC,
                UNACCENT(tbl.university) ASC
            LIMIT p_per_page
            OFFSET  offset_val;
        END;
        $$;


ALTER FUNCTION odiseo.fn_get_employee_university(p_per_page integer, p_n_page integer, p_employee_id bigint, p_university_id smallint, p_search character varying) OWNER TO postgres;

--
