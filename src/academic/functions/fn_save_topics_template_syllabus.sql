-- Function: academic.fn_save_topics_template_syllabus(jsonb, smallint, jsonb, integer, bigint)

--

CREATE FUNCTION academic.fn_save_topics_template_syllabus(p_university_ids jsonb, p_course_id smallint, p_topic_ids jsonb, p_company_id integer, p_user bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_p_topic_ids SMALLINT[];
    v_university_id BIGINT;
    v_syllabus_template_id BIGINT;
    v_existing_topics_ids BIGINT[];
    v_not_exist_topics_ids BIGINT[];
    v_new_topic_ids BIGINT[];
BEGIN
    /*
        ------------------------------------------------------------------------------------
        -- HISTORIAL DE CAMBIOS
        ------------------------------------------------------------------------------------

        Versión: 1.1
        Fecha: 2025-11-17
        Autor: Junior Alcarraz
        Descripción:
            Se agrega el campo de id de compañia al registrar temas al syllabus template
    */

    -- Se guarda en una variable los IDs de los temas mandados
    SELECT array_agg(value::BIGINT) INTO v_p_topic_ids
    FROM jsonb_array_elements(p_topic_ids);

    -- Iterar sobre cada universidad en el JSONB
    FOR v_university_id IN SELECT (value)::BIGINT FROM jsonb_array_elements_text(p_university_ids)
    LOOP
        -- Obtener el ID del syllabus asociado a la universidad y curso
        SELECT st.id INTO v_syllabus_template_id
        FROM syllabus_template st
        WHERE st.university_id = v_university_id
            AND st.course_id = p_course_id
            AND st.fl_status IS TRUE
            AND st.company_id = p_company_id
        LIMIT 1;

        -- Verificar si el syllabus existe
        IF v_syllabus_template_id IS NOT NULL THEN
            -- Eliminar los temas que no se mandaron
            UPDATE syllabus_template_topic stt_1
            SET fl_status = FALSE, updated_at = NOW(), updated_by = p_user
            WHERE stt_1.topic_id NOT IN (SELECT * FROM UNNEST(v_p_topic_ids))
                AND stt_1.syllabus_template_id = v_syllabus_template_id
                AND stt_1.fl_status IS TRUE
                AND stt_1.company_id = p_company_id;

            -- Obtener los temas existentes en la universidad
            SELECT ARRAY(
                SELECT stt.topic_id
                FROM syllabus_template_topic stt
                WHERE stt.syllabus_template_id = v_syllabus_template_id
                    AND stt.fl_status IS TRUE
                    AND stt.company_id = p_company_id
            ) INTO v_existing_topics_ids;

            -- Identificar los cursos nuevos que no están en la base de datos
            SELECT ARRAY(
                SELECT (value)::BIGINT FROM unnest(v_p_topic_ids) AS value
                EXCEPT
                SELECT unnest(v_existing_topics_ids)
            ) INTO v_new_topic_ids;

            -- Insertar los temas nuevos
            IF v_new_topic_ids IS NOT NULL THEN
                INSERT INTO syllabus_template_topic(
                    syllabus_template_id,
                    topic_id,
                    company_id,
                    created_by,
                    created_at
                )
                SELECT
                    v_syllabus_template_id,
                    unnest(v_new_topic_ids),
                    p_company_id,
                    p_user,
                    NOW();
            END IF;
        END IF;
    END LOOP;
END;
$$;


ALTER FUNCTION academic.fn_save_topics_template_syllabus(p_university_ids jsonb, p_course_id smallint, p_topic_ids jsonb, p_company_id integer, p_user bigint) OWNER TO postgres;

--
