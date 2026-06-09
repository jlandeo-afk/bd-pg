-- Function: academic.fn_get_detail_course_diagram(smallint, smallint)

--

CREATE FUNCTION academic.fn_get_detail_course_diagram(p_course_id smallint, p_category_id smallint) RETURNS TABLE(id bigint, setting_diagrammed_courses_id bigint, name_field_diagram character varying, "position" smallint, fl_active boolean, fl_optional boolean, fl_show_in_material_without_solution boolean, fl_show_in_material_with_solution boolean)
    LANGUAGE plpgsql
    AS $$
                BEGIN
                RETURN QUERY
                SELECT
                    fd.id,
                    sdc.id setting_diagrammed_courses_id,
                    fd."name" name_field_diagram,
                    sdc."position",
                    sdc.fl_active,
                    sdc.fl_optional,
                    ctcs.fl_show_in_material_without_solution,
                    ctcs.fl_show_in_material_with_solution
                FROM setting_diagrammed_courses sdc
                LEFT JOIN field_diagrammed fd ON fd.id = sdc.field_diagram_id
                LEFT JOIN course_text_category_settings ctcs ON ctcs.type_text_id = sdc.category_text_id 
                AND sdc.course_id = ctcs.course_id
                WHERE sdc.course_id = p_course_id
                AND CASE
                    WHEN p_category_id IS NULL THEN sdc.category_text_id IS NULL
                    ELSE sdc.category_text_id = p_category_id
                END
                AND sdc.fl_status = TRUE
                ORDER BY sdc."position";
                END;
            $$;


ALTER FUNCTION academic.fn_get_detail_course_diagram(p_course_id smallint, p_category_id smallint) OWNER TO postgres;

--
