-- Function: academic.fn_delete_topic(smallint, bigint)

--

CREATE FUNCTION academic.fn_delete_topic(p_topic_id smallint, p_deleted_by bigint) RETURNS TABLE(r_topic_id smallint)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_count_questions BIGINT;
        BEGIN
            SELECT
                count(q.id) INTO v_count_questions
            FROM odiseo.question q
            WHERE q.topic_id = p_topic_id;

            IF v_count_questions = 0 THEN
                UPDATE academic.topic SET fl_status = false, deleted_by = p_deleted_by, deleted_at = now()
                WHERE id = p_topic_id;
                -- Eliminando el tema en el template syllabus
                UPDATE academic.syllabus_template_topic SET fl_status = false, deleted_by =  p_deleted_by, deleted_at  = now() WHERE  topic_id =  p_topic_id;

                -- Eliminando el tema de syllabus_topic
                UPDATE academic.syllabus_topic SET is_topic_deleted = true WHERE  id IN  (SELECT st.id FROM academic.syllabus_topic st
                JOIN academic.syllabus_topic_week stw
                ON stw.syllabus_topic_id = st.id
                WHERE st.topic_id = p_topic_id  AND st.fl_status = true AND stw.fl_status = TRUE );

                RETURN QUERY SELECT p_topic_id;
            ELSE
                RETURN QUERY SELECT NULL::SMALLINT;
            END IF;
        END;
        $$;


ALTER FUNCTION academic.fn_delete_topic(p_topic_id smallint, p_deleted_by bigint) OWNER TO postgres;

--
