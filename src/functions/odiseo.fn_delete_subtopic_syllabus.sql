-- Function: odiseo.fn_delete_subtopic_syllabus(bigint, bigint, boolean, bigint)

--

CREATE FUNCTION odiseo.fn_delete_subtopic_syllabus(p_syllabus_id bigint, p_subtopic_id bigint, p_is_deleted boolean, p_user bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_syllabus_detail_subtopics_ids BIGINT[];
        BEGIN
            -- Obtener los IDs de los subtemas del syllabus
            SELECT ARRAY(
                SELECT sds.id
                FROM odiseo.syllabus s
                LEFT JOIN odiseo.syllabus_topic st ON st.syllabus_id = s.id
                LEFT JOIN odiseo.syllabus_topic_week stw ON stw.syllabus_topic_id = st.id
                LEFT JOIN odiseo.syllabus_detail_subtopic sds ON sds.syllabus_topic_week_id = stw.id
                WHERE st.fl_status = TRUE
                AND stw.fl_status = TRUE
                AND sds.fl_status = TRUE
                AND s.id = p_syllabus_id
                AND sds.subtopic_id = p_subtopic_id
            ) INTO v_syllabus_detail_subtopics_ids;
            -- Actualizar el estado de los subtemas relacionados
            IF p_is_deleted THEN
                UPDATE odiseo.syllabus_detail_subtopic
                SET is_subtopic_deleted = FALSE
                WHERE id = ANY(v_syllabus_detail_subtopics_ids);
            ELSE
                UPDATE odiseo.syllabus_detail_subtopic
                SET fl_status = FALSE,
                    is_subtopic_deleted = FALSE,
                    deleted_by = p_user,
                    deleted_at = NOW()
                WHERE id = ANY(v_syllabus_detail_subtopics_ids);
            END IF;
        END;
        $$;


ALTER FUNCTION odiseo.fn_delete_subtopic_syllabus(p_syllabus_id bigint, p_subtopic_id bigint, p_is_deleted boolean, p_user bigint) OWNER TO postgres;

--
