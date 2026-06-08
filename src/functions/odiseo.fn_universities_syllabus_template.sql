-- Function: odiseo.fn_universities_syllabus_template(integer, bigint)

--

CREATE FUNCTION odiseo.fn_universities_syllabus_template(p_company_id integer, p_employee_id bigint) RETURNS TABLE(id smallint, name character varying, slug character varying)
    LANGUAGE plpgsql
    AS $$
    DECLARE
        offset_val INTEGER;
    BEGIN
        RETURN QUERY
        SELECT DISTINCT * FROM (
            SELECT
                ou.id,
                ou.name,
                ou.slug
            FROM origin_university ou
            LEFT JOIN syllabus_template st ON ou.id = st.university_id
                AND st.fl_status = TRUE
                AND st.deleted_at IS NULL
                AND st.company_id = p_company_id
            LEFT JOIN employee_university eu ON eu.university_id = ou.id
                AND eu.fl_status IS true
            WHERE st.id IS NULL
                AND ou.fl_active = true
                AND (p_employee_id IS null OR eu.employee_id = p_employee_id)
            ORDER BY public.unaccent(ou.name) ASC
        ) AS tbl_universities;
    END;
    $$;


ALTER FUNCTION odiseo.fn_universities_syllabus_template(p_company_id integer, p_employee_id bigint) OWNER TO postgres;

--
