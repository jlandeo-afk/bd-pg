-- Function: academic.fn_origin_university_with_cycle(character varying, integer)

--

CREATE FUNCTION academic.fn_origin_university_with_cycle(p_name_text character varying, p_company_id integer) RETURNS TABLE(id smallint, code character varying, name character varying)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        SELECT u.id, u.code, u.name
        FROM origin_university u
        INNER JOIN material m ON u.id = m.university_id AND m.fl_status = TRUE
        INNER JOIN cycle c ON m.cycle_id = c.id AND c.fl_status = TRUE
        INNER JOIN detail_week_type_mat dwtm ON m.id = dwtm.material_id AND dwtm.fl_status = TRUE
        INNER JOIN material_exam_area_week meaw ON dwtm.id = meaw.week_type_material_id AND meaw.fl_status = TRUE
        WHERE u.deleted_by IS NULL
        AND u.fl_active = true
        AND m.company_id = p_company_id
        AND (
            p_name_text IS NULL
            OR LOWER(u.name) LIKE '%' || LOWER(p_name_text) || '%'
            OR LOWER(u.slug) LIKE '%' || LOWER(p_name_text) || '%'
        )
        GROUP BY u.id, u.code, u.name
        ORDER BY u.id ASC;
    END;
    $$;


ALTER FUNCTION academic.fn_origin_university_with_cycle(p_name_text character varying, p_company_id integer) OWNER TO postgres;

--
