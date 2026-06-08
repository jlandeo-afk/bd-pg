-- Function: odiseo.fn_find_employee_university(bigint)

--

CREATE FUNCTION odiseo.fn_find_employee_university(p_employee_id bigint) RETURNS TABLE(id bigint, code character varying, employee_id bigint, first_name character varying, first_surname character varying, second_surname character varying, document character varying, charge_id bigint, charge character varying, university_id smallint, university character varying, slug character varying)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
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
            AND eu.employee_id = p_employee_id
            ORDER BY UNACCENT(u.name) ASC;
        END;
        $$;


ALTER FUNCTION odiseo.fn_find_employee_university(p_employee_id bigint) OWNER TO postgres;

--
