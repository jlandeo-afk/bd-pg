-- Function: academic.fn_get_total_category_syllabus(integer, integer, integer, integer, integer)

--

CREATE FUNCTION academic.fn_get_total_category_syllabus(p_material_id integer, p_course_id integer, p_week integer, p_type_text_id integer, p_company_id integer) RETURNS TABLE(syllabus_text_id bigint)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        SELECT DISTINCT
            st.type_text_id
        FROM syllabus_texts st
        INNER JOIN syllabus_text_distributions std ON std.id = st.syllabus_text_distribution_id
        INNER JOIN syllabus_text_weeks stw ON stw.id = std.syllabus_text_week_id
        INNER JOIN syllabus s ON s.id = stw.syllabus_id
        INNER JOIN material m ON m.university_id = s.university_id
        WHERE m.id = p_material_id
          AND s.course_id = p_course_id
          AND s.cycle_id = m.cycle_id
          AND s.company_id = p_company_id
          AND (
              (p_type_text_id = 2 AND stw.week = p_week)
              OR
              (p_type_text_id = 3 AND stw.week <= p_week)
              OR
              (p_type_text_id = 4)
          )
          AND s.fl_status = true
          AND stw.fl_status = true
          AND std.fl_status = true
          AND st.fl_status = true
          AND m.fl_status = true
          AND st.type_text_id NOT IN (5,7,8,10) -- Excluir categorias de ecos para examen
        GROUP BY st.type_text_id;
    END;
    $$;


ALTER FUNCTION academic.fn_get_total_category_syllabus(p_material_id integer, p_course_id integer, p_week integer, p_type_text_id integer, p_company_id integer) OWNER TO postgres;

--
