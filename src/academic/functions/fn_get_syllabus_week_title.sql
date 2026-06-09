-- Function: academic.fn_get_syllabus_week_title(integer, integer, integer, integer)

--

CREATE FUNCTION academic.fn_get_syllabus_week_title(p_material_id integer, p_week_id integer, p_course_id integer, p_type_material_id integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$

            DECLARE
                v_type_material_template_id INT;
                v_university_id INT;
                v_cycle_id INT;
                v_syllabus_week_title CHARACTER VARYING;
            BEGIN

                SELECT tm.type_material_template_id
                INTO v_type_material_template_id
                FROM odiseo.type_material tm
                WHERE tm.id = p_type_material_id AND tm.fl_status = TRUE;

                IF v_type_material_template_id = 4 THEN  -- 4  es el id del Material Template Boletin
                    SELECT m.university_id, m.cycle_id
                    INTO v_university_id, v_cycle_id
                    FROM odiseo.material m
                    WHERE m.id = p_material_id;
                    SELECT swt.title
                    INTO v_syllabus_week_title
                    FROM academic.syllabus s
                    JOIN academic.syllabus_week_titles swt
                    ON s.id = swt.syllabus_id
                    WHERE s.university_id = v_university_id
                    AND s.cycle_id = v_cycle_id
                    AND s.course_id = p_course_id
                    AND s.fl_status = TRUE
                    AND swt.fl_status = TRUE
                    AND swt.week = p_week_id;
                ELSE
                    v_syllabus_week_title := NULL;

                END IF ;

                RETURN v_syllabus_week_title;
            END;
        $$;


ALTER FUNCTION academic.fn_get_syllabus_week_title(p_material_id integer, p_week_id integer, p_course_id integer, p_type_material_id integer) OWNER TO postgres;

--
