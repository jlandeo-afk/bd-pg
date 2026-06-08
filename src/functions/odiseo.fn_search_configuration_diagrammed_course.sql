-- Function: odiseo.fn_search_configuration_diagrammed_course(character varying)

--

CREATE FUNCTION odiseo.fn_search_configuration_diagrammed_course(p_text character varying) RETURNS TABLE(course_id bigint, name_course character varying, category_text_id bigint, category_text character varying)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                    RETURN QUERY

                    WITH course_configurations AS (
                    SELECT
                        sdc.course_id,
                        c."name" name_course,
                        null category_text_id,
                        null category_text
                    FROM setting_diagrammed_courses sdc
                    JOIN course c ON c.id = sdc.course_id
                    WHERE sdc.category_text_id IS NULL
                    AND sdc.fl_status = TRUE
                    GROUP BY sdc.course_id, c.name
                    UNION ALL
                    SELECT 
                        sdc.course_id,
                        c."name" name_course,
                        tt.id category_text_id,
                        tt."name" category_text
                    FROM setting_diagrammed_courses sdc
                    JOIN course c ON c.id = sdc.course_id
                    JOIN type_text tt ON tt.id = sdc.category_text_id
                    WHERE sdc.fl_status = TRUE
                    GROUP BY sdc.course_id, c.name, tt."name", tt.id
                    ORDER BY course_id
                    )
                    SELECT * FROM course_configurations cc WHERE (
                        p_text IS NULL OR
                        UNACCENT(cc.name_course) ILIKE '%' || UNACCENT(p_text) || '%'
                    );

                    END;
                    $$;


ALTER FUNCTION odiseo.fn_search_configuration_diagrammed_course(p_text character varying) OWNER TO postgres;

--
