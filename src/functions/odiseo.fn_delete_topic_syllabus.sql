-- Function: odiseo.fn_delete_topic_syllabus(bigint, bigint, boolean, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_delete_topic_syllabus(p_syllabus_id bigint, p_topic_id bigint, p_is_deleted boolean, p_company_id bigint, p_user bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_syllabus_topic_ids BIGINT[];
        BEGIN
            -- Obtener los IDs de los subtemas del syllabus
            SELECT ARRAY(
                SELECT st.id
                FROM syllabus s
                LEFT JOIN syllabus_topic st ON st.syllabus_id = s.id
                WHERE st.fl_status = TRUE
                AND s.company_id = p_company_id
                AND s.id = p_syllabus_id
                AND st.topic_id = p_topic_id
            ) INTO v_syllabus_topic_ids;
            -- Actualizar el estado de los subtemas relacionados
            IF p_is_deleted THEN
                UPDATE syllabus_topic
                SET is_topic_deleted = FALSE
                WHERE id = ANY(v_syllabus_topic_ids)
                AND company_id = p_company_id;
            ELSE
                UPDATE syllabus_topic
                SET fl_status = FALSE,
                    is_topic_deleted = FALSE,
                    deleted_by = p_user,
                    deleted_at = NOW()
                WHERE id = ANY(v_syllabus_topic_ids)
                AND company_id = p_company_id;
            END IF;
        END;
        $$;


ALTER FUNCTION odiseo.fn_delete_topic_syllabus(p_syllabus_id bigint, p_topic_id bigint, p_is_deleted boolean, p_company_id bigint, p_user bigint) OWNER TO postgres;

--
