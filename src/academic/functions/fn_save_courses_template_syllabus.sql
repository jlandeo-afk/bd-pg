-- Function: academic.fn_save_courses_template_syllabus(jsonb, jsonb, integer, bigint)

--

CREATE FUNCTION academic.fn_save_courses_template_syllabus(p_university_ids jsonb, p_courses jsonb, p_company_id integer, p_user bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_university_id BIGINT;
    v_p_course_ids BIGINT[]; -- [1,3]
    v_existing_course_ids BIGINT[];
    v_new_course_ids BIGINT[];
BEGIN
    /*
        ------------------------------------------------------------------------------------
        -- HISTORIAL DE CAMBIOS
        ------------------------------------------------------------------------------------

        Versión: 1.1
        Fecha: 2025-11-17
        Autor: Junior Alcarraz
        Descripción:
            Se agrega el campo de id de compañia al registrar cursos al syllabus template
    */

    -- Se guarda en una variable los IDs de los curso mandados
    SELECT array_agg((elem->>'id')::BIGINT)
    INTO v_p_course_ids
    FROM jsonb_array_elements(p_courses) elem;

    -- Iterar sobre cada universidad en el JSONB
    FOR v_university_id IN SELECT (value)::BIGINT FROM jsonb_array_elements_text(p_university_ids) AS value
    LOOP
        -- Eliminar los cursos que no se mandaron
        UPDATE syllabus_template ste
        SET fl_status = FALSE, updated_at = NOW(), updated_by = p_user
        WHERE ste.course_id NOT IN (SELECT * FROM UNNEST(v_p_course_ids))
            AND ste.university_id = v_university_id
            AND ste.fl_status IS TRUE
            AND ste.company_id = p_company_id;

        -- Obtener los cursos existentes en la universidad
        SELECT ARRAY(
            SELECT st.course_id
            FROM syllabus_template st
            WHERE st.university_id = v_university_id
                AND st.fl_status = TRUE
                AND st.course_id IS NOT NULL
                AND st.company_id = p_company_id
        ) INTO v_existing_course_ids;

        -- Identificar los cursos nuevos que no están en la base de datos
        SELECT ARRAY(
            SELECT (value)::BIGINT FROM unnest(v_p_course_ids) AS value
            EXCEPT
            SELECT unnest(v_existing_course_ids)
        ) INTO v_new_course_ids;

        -- Insertar los cursos nuevos
        IF v_new_course_ids IS NOT NULL THEN
            INSERT INTO syllabus_template (
                university_id,
                course_id,
                fl_status,
                company_id,
                created_at,
                created_by
            )
            SELECT
                v_university_id,
                unnest(v_new_course_ids),
                TRUE,
                p_company_id,
                NOW(),
                p_user;
        END IF;
    END LOOP;
END;
$$;


ALTER FUNCTION academic.fn_save_courses_template_syllabus(p_university_ids jsonb, p_courses jsonb, p_company_id integer, p_user bigint) OWNER TO postgres;

--
