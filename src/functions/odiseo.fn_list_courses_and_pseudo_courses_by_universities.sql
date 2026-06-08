-- Function: odiseo.fn_list_courses_and_pseudo_courses_by_universities(jsonb, integer, jsonb)

--

CREATE FUNCTION odiseo.fn_list_courses_and_pseudo_courses_by_universities(f_university_ids jsonb, p_company_id integer, f_courses_employee jsonb) RETURNS TABLE(id smallint, code character varying, name character varying, exist_some boolean, fl_pseudo boolean, children jsonb)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_university_ids INT[];
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

            v_university_ids := ARRAY(SELECT jsonb_array_elements_text(f_university_ids)::INT);

            RETURN QUERY
            WITH tbl_courses AS (
                SELECT
                    c.id,
                    c.code,
                    c.name,
                    CASE
                        WHEN st.id IS NULL
                            THEN FALSE
                        ELSE TRUE
                    END AS exist_some,
                    c.fl_pseudo_course AS fl_pseudo,
                    COALESCE(
                        to_jsonb(
                            ARRAY(
                                SELECT cpc.course_id FROM course_pseudo_courses cpc
                                WHERE cpc.pseudo_course_id = c.id AND cpc.fl_status = TRUE
                            )
                        ), '[]'::jsonb
                    ) AS children
                FROM course c
                LEFT JOIN syllabus_template st ON c.id = st.course_id
                    AND st.university_id = ANY(v_university_ids)
                    AND st.fl_status = TRUE
                    AND st.company_id = p_company_id
                WHERE c.fl_status = TRUE
                    AND (f_courses_employee IS NULL OR c.id = ANY(ARRAY(SELECT jsonb_array_elements_text(f_courses_employee)::INT)))
            )
            SELECT tbl_courses.* FROM tbl_courses
            ORDER BY tbl_courses.code;
        END;
        $$;


ALTER FUNCTION odiseo.fn_list_courses_and_pseudo_courses_by_universities(f_university_ids jsonb, p_company_id integer, f_courses_employee jsonb) OWNER TO postgres;

--
