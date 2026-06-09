-- Function: academic.sp_change_syllabus_template_subtopics(bigint, bigint, bigint)

--

CREATE PROCEDURE academic.sp_change_syllabus_template_subtopics(IN p_topic_id bigint, IN p_subtopic_id bigint, IN p_user bigint)
    LANGUAGE plpgsql
    AS $$
                DECLARE
                    v_syllabus_template_topic_ids BIGINT[];
                BEGIN
                    -- Iniciar bloque de excepción para capturar errores
                    BEGIN
                        -- Actualizar todos los subtopics en syllabus_template_topic_subtopic para marcarlos como eliminados
                        UPDATE academic.syllabus_template_topic_subtopic
                        SET fl_status = FALSE,
                            deleted_at = NOW(),
                            deleted_by = p_user
                        WHERE subtopic_id = p_subtopic_id;

                        -- Verificar si existen topics en syllabus_template_topic relacionados con el topic dado
                        SELECT ARRAY(
                            SELECT stt.id
                            FROM academic.syllabus_template_topic stt
                            JOIN academic.syllabus_template st
                            ON stt.syllabus_template_id = st.id
                            WHERE stt.fl_status = TRUE AND stt.deleted_at IS NULL
                            AND stt.topic_id = p_topic_id
                            AND st.fl_status = TRUE AND st.deleted_at IS NULL
                        )
                        INTO v_syllabus_template_topic_ids;

                        -- Si se encontraron topics, insertar los subtopics correspondientes
                        IF v_syllabus_template_topic_ids IS NOT NULL THEN
                            INSERT INTO academic.syllabus_template_topic_subtopic (syllabus_template_topic_id, subtopic_id, created_by, created_at)
                            SELECT
                                unnest(v_syllabus_template_topic_ids),
                                p_subtopic_id,
                                p_user,
                                NOW();
                        END IF;

                    EXCEPTION WHEN OTHERS THEN
                        RAISE NOTICE 'Error: %', SQLERRM;
                        RAISE; -- Propagar el error
                    END;
                END;
            $$;


ALTER PROCEDURE academic.sp_change_syllabus_template_subtopics(IN p_topic_id bigint, IN p_subtopic_id bigint, IN p_user bigint) OWNER TO postgres;

--
