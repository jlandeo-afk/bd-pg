-- Function: academic.fn_save_subtopics_template_syllabus(jsonb, smallint, smallint, jsonb, integer, bigint)

--

CREATE FUNCTION academic.fn_save_subtopics_template_syllabus(p_university_ids jsonb, p_course_id smallint, p_topic_id smallint, p_subtopic_ids jsonb, p_company_id integer, p_user bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_p_subtopic_ids SMALLINT[];
    v_university_id BIGINT;
    v_topic_syllabus_template_id BIGINT;
    v_existing_subtopics_ids BIGINT[];
    v_new_subtopic_ids BIGINT[];
BEGIN
    /*
        ------------------------------------------------------------------------------------
        -- HISTORIAL DE CAMBIOS
        ------------------------------------------------------------------------------------

        Versión: 1.1
        Fecha: 2025-11-17
        Autor: Junior Alcarraz
        Descripción:
            Se agrega el campo de id de compañia al registrar subtemas al syllabus template
    */

    -- Se guarda en una variable los IDs de los temas mandados
    SELECT array_agg(value::BIGINT) INTO v_p_subtopic_ids
    FROM jsonb_array_elements(p_subtopic_ids);

    -- Iterar sobre cada universidad en el JSONB
    FOR v_university_id IN SELECT (value)::BIGINT FROM jsonb_array_elements_text(p_university_ids)
    LOOP
        -- Obtener el ID del syllabus_template_topic
        SELECT stt.id INTO v_topic_syllabus_template_id
        FROM syllabus_template_topic stt
        JOIN syllabus_template st ON stt.syllabus_template_id = st.id
            AND st.company_id = p_company_id
        WHERE st.university_id = v_university_id
            AND st.course_id = p_course_id
            AND stt.topic_id = p_topic_id
            AND st.fl_status = TRUE
            AND stt.fl_status = TRUE
            AND stt.company_id = p_company_id
        LIMIT 1;

        IF v_topic_syllabus_template_id IS NOT NULL THEN
            -- Eliminar los subtemas que no se mandaron
            UPDATE syllabus_template_topic_subtopic stts_1
            SET fl_status = FALSE, updated_at = NOW(), updated_by = p_user
            WHERE stts_1.subtopic_id NOT IN (SELECT * FROM UNNEST(v_p_subtopic_ids))
                AND stts_1.syllabus_template_topic_id = v_topic_syllabus_template_id
                AND stts_1.fl_status = TRUE
                AND stts_1.company_id = p_company_id;

            -- Obtener los subtemas existentes en el tema de la universidad
            SELECT ARRAY(
                SELECT stts.subtopic_id
                FROM syllabus_template_topic_subtopic stts
                WHERE stts.syllabus_template_topic_id = v_topic_syllabus_template_id
                    AND stts.fl_status = TRUE
                    AND stts.company_id = p_company_id
            ) INTO v_existing_subtopics_ids;

            -- Identificar los cursos nuevos que no están en la base de datos
            SELECT ARRAY(
                SELECT (value)::BIGINT FROM unnest(v_p_subtopic_ids) AS value
                EXCEPT
                SELECT unnest(v_existing_subtopics_ids)
            ) INTO v_new_subtopic_ids;

            -- Insertar los subtemas nuevos
            IF v_new_subtopic_ids IS NOT NULL THEN
                INSERT INTO syllabus_template_topic_subtopic(
                    syllabus_template_topic_id,
                    subtopic_id,
                    company_id,
                    created_by,
                    created_at
                )
                SELECT
                    v_topic_syllabus_template_id,
                    unnest(v_new_subtopic_ids),
                    p_company_id,
                    p_user,
                    NOW();
            END IF;
        END IF;
    END LOOP;
END;
$$;


ALTER FUNCTION academic.fn_save_subtopics_template_syllabus(p_university_ids jsonb, p_course_id smallint, p_topic_id smallint, p_subtopic_ids jsonb, p_company_id integer, p_user bigint) OWNER TO postgres;

--
