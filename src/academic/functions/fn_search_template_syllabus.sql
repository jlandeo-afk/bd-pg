-- Function: academic.fn_search_template_syllabus(integer, integer, character varying, integer, bigint)

--

CREATE FUNCTION academic.fn_search_template_syllabus(p_perpage integer, p_npage integer, p_search character varying, p_company_id integer, p_employee_id bigint) RETURNS TABLE(university_id smallint, university character varying, slug character varying, total bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    offset_val INTEGER;
BEGIN
    /*
        ------------------------------------------------------------------------------------
        -- HISTORIAL DE CAMBIOS
        ------------------------------------------------------------------------------------

        Versión: 1.1
        Fecha: 2025-11-17
        Autor: Junior Alcarraz
        Descripción:
            Se filtra por el id de la compañia del usuario logueado
    */

    -- Calcular el offset para la paginación
    offset_val := p_perpage * (p_npage - 1);

    RETURN QUERY
    WITH tbl_template_syllabus AS (
        SELECT DISTINCT
            st.university_id AS university_id,
            ou.name AS university,
            ou.slug
        FROM syllabus_template st
        LEFT JOIN origin_university ou ON st.university_id = ou.id
        LEFT JOIN employee_university eu ON st.university_id = eu.university_id
            AND eu.fl_status IS true
        WHERE st.fl_status = TRUE
            AND (p_search IS NULL OR ou.name ILIKE '%' || p_search || '%')
            AND st.company_id = p_company_id
            AND (p_employee_id IS null OR eu.employee_id = p_employee_id)
    )
    SELECT *,  COUNT(*) OVER () AS total
    FROM  tbl_template_syllabus
    ORDER BY university ASC
    LIMIT p_perpage
    OFFSET  offset_val;
END;
$$;


ALTER FUNCTION academic.fn_search_template_syllabus(p_perpage integer, p_npage integer, p_search character varying, p_company_id integer, p_employee_id bigint) OWNER TO postgres;

--
