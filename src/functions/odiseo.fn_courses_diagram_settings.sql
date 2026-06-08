-- Function: odiseo.fn_courses_diagram_settings()

--

CREATE FUNCTION odiseo.fn_courses_diagram_settings() RETURNS TABLE(id smallint, code character varying, name character varying, apply_text boolean)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                    RETURN QUERY
                    WITH all_course_text_category AS (
                        SELECT c.id, tt.id category_text_id, c.apply_text FROM course c 
                        CROSS JOIN type_text tt 
                        WHERE c.apply_text = true AND c.fl_status = true
                    ),
                    courses_text_diagramm AS (
                        SELECT
                            c.id,
                            c.apply_text
                        FROM all_course_text_category c
                        LEFT JOIN setting_diagrammed_courses sdc ON c.id = sdc.course_id
                            AND sdc.fl_status = true AND c.category_text_id = sdc.category_text_id 
                        WHERE
                            c.apply_text IS TRUE
                            AND sdc.category_text_id IS NULL
                        GROUP BY c.id, c.apply_text 
                    ), courses_diagramm AS (
                        SELECT
                            c.id,
                            false
                        FROM course c
                        LEFT JOIN setting_diagrammed_courses sdc ON c.id = sdc.course_id AND sdc.category_text_id IS NULL
                            AND sdc.fl_status = true
                        WHERE c.fl_status = true
                            AND sdc.course_id IS NULL
                        GROUP BY c.id
                    ), union_courses_diagramm AS (
                        SELECT * FROM courses_text_diagramm
                        UNION ALL
                        SELECT * FROM courses_diagramm
                    )
                    SELECT ucd.id, c.code, c."name", ucd.apply_text
                    FROM union_courses_diagramm ucd
                    JOIN course c ON c.id = ucd.id
                    ORDER BY c.id;

            END;
            $$;


ALTER FUNCTION odiseo.fn_courses_diagram_settings() OWNER TO postgres;

--
