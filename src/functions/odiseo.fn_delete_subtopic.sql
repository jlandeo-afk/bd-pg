-- Function: odiseo.fn_delete_subtopic(smallint, bigint)

--

CREATE FUNCTION odiseo.fn_delete_subtopic(p_subtopic_id smallint, p_deleted_by bigint) RETURNS TABLE(r_subtopic_id smallint, question_codes jsonb, has_no_siblings boolean)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_topic_id odiseo.subtopic.topic_id%TYPE;
            v_question_codes VARCHAR[] := '{}';
            v_count_subtopics INTEGER;
        BEGIN
            SELECT
                COALESCE(array_agg(q.code), '{}'::VARCHAR[])
            INTO v_question_codes
            FROM odiseo.question q
            INNER JOIN odiseo.question_subtopic qs
            ON q.id = qs.question_id AND qs.fl_status = true
            WHERE
                qs.subtopic_id = p_subtopic_id
                AND q.deleted_at IS NULL AND q.fl_status
                AND qs.deleted_at IS NULL AND qs.fl_status;

            SELECT sb.topic_id INTO v_topic_id FROM odiseo.subtopic as sb WHERE sb.id = p_subtopic_id;
            SELECT count(id) INTO v_count_subtopics
            FROM odiseo.subtopic WHERE topic_id = v_topic_id AND fl_status AND deleted_at IS NULL;

            IF v_count_subtopics <= 1 THEN
                RETURN QUERY SELECT NULL::SMALLINT, '[]'::jsonb, TRUE;
            END IF;

            IF (array_length(v_question_codes, 1) IS NULL) OR (array_length(v_question_codes, 1) = 0) THEN
                UPDATE odiseo.subtopic SET fl_status = false, deleted_by = p_deleted_by, deleted_at = now()
                WHERE id = p_subtopic_id;

                -- Eliminacion del subtema en el template syllabus
                UPDATE odiseo.syllabus_template_topic_subtopic SET fl_status = false, deleted_by =  p_deleted_by, deleted_at  = now() WHERE  subtopic_id =  p_subtopic_id;

                  -- Eliminar el subtema del detail_syllabus_subtopic
                UPDATE odiseo.syllabus_detail_subtopic SET is_subtopic_deleted = TRUE WHERE subtopic_id = p_subtopic_id AND fl_status = true;

                RETURN QUERY SELECT p_subtopic_id, '[]'::jsonb, FALSE;
            ELSE
                RETURN QUERY SELECT NULL::SMALLINT, to_jsonb(v_question_codes), FALSE;
            END IF;
        END;
        $$;


ALTER FUNCTION odiseo.fn_delete_subtopic(p_subtopic_id smallint, p_deleted_by bigint) OWNER TO postgres;

--
