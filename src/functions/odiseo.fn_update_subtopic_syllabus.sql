-- Function: odiseo.fn_update_subtopic_syllabus(bigint, bigint, bigint, boolean, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_update_subtopic_syllabus(p_syllabus_id bigint, p_subtopic_id bigint, p_new_topic_id bigint, p_is_modified boolean, p_company_id bigint, p_user bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_syllabus_detail_subtopics_ids BIGINT[];
            v_syllabus_topic_week_id BIGINT;
            v_week BIGINT;
            v_new_syllabus_topic_week_id BIGINT;
            v_total_questions_amount BIGINT;
            v_subtopic_id BIGINT;
            v_syllabus_subtopic_id BIGINT;
            v_syllabus_topic_id BIGINT;
        BEGIN
            -- Obtener los IDs de los subtemas del syllabus
            SELECT ARRAY(
                SELECT sds.id
                FROM syllabus s
                LEFT JOIN syllabus_topic st ON st.syllabus_id = s.id
                LEFT JOIN syllabus_topic_week stw ON stw.syllabus_topic_id = st.id
                LEFT JOIN syllabus_detail_subtopic sds ON sds.syllabus_topic_week_id = stw.id
                WHERE st.fl_status = TRUE
                AND stw.fl_status = TRUE
                AND sds.fl_status = TRUE
                AND s.id = p_syllabus_id
                AND sds.subtopic_id = p_subtopic_id
            ) INTO v_syllabus_detail_subtopics_ids;

            -- Actualizar el estado de los subtemas relacionados
            IF p_is_modified THEN
            -- Iterar sobre cada subtopic ID
                FOR v_syllabus_subtopic_id IN SELECT  UNNEST(v_syllabus_detail_subtopics_ids) LOOP

                -- Obtener la semana y la cantidad de preguntas
                    SELECT  stw.week, stw.total_questions_amount
                    INTO  v_week , v_total_questions_amount
                    FROM syllabus_detail_subtopic sds
                    JOIN syllabus_topic_week stw
                    ON sds.syllabus_topic_week_id = stw.id
                    WHERE sds.id = v_syllabus_subtopic_id;

                    -- Obtener el ID del sylllabus_topic
                    SELECT st.id
                    INTO v_syllabus_topic_id
                    FROM syllabus_topic st
                    WHERE st.fl_status = TRUE
                    AND st.syllabus_id = p_syllabus_id
                    AND st.topic_id = p_new_topic_id;

                IF v_syllabus_topic_id IS NULL THEN
                        -- Insertar un nuevo registro en la tabla topic y obtener su ID
                        INSERT INTO syllabus_topic(syllabus_id, topic_id, created_by, created_at)
                        VALUES (p_syllabus_id, p_new_topic_id, p_user, NOW())
                        RETURNING id INTO v_syllabus_topic_id;
                    END IF;
                -- Insertando un nuevo registro de la configuracion de esa semana con el nuevo topic_id
                    INSERT INTO syllabus_topic_week(syllabus_topic_id,week,total_questions_amount,created_by,created_at)
                    VALUES (v_syllabus_topic_id,v_week,v_total_questions_amount,p_user, now()) RETURNING id INTO v_new_syllabus_topic_week_id;

                    UPDATE syllabus_detail_subtopic
                    SET is_topic_modified = FALSE, syllabus_topic_week_id = v_new_syllabus_topic_week_id
                    WHERE id = v_syllabus_subtopic_id;
                END LOOP;
            ELSE
                UPDATE syllabus_detail_subtopic
                SET fl_status = FALSE,
                    is_topic_modified = FALSE,
                    deleted_by = p_user,
                    deleted_at = NOW()
                WHERE id = ANY(v_syllabus_detail_subtopics_ids);
            END IF;
        END;
        $$;


ALTER FUNCTION odiseo.fn_update_subtopic_syllabus(p_syllabus_id bigint, p_subtopic_id bigint, p_new_topic_id bigint, p_is_modified boolean, p_company_id bigint, p_user bigint) OWNER TO postgres;

--
