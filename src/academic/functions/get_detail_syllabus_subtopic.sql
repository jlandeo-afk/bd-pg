-- Function: academic.get_detail_syllabus_subtopic(integer, integer)

--

CREATE FUNCTION academic.get_detail_syllabus_subtopic(p_syllabus_id integer, p_company_id integer) RETURNS TABLE(subtopics_observations jsonb, topics_observations jsonb)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_subtopic RECORD;
            v_topic RECORD;
            subtopics_array jsonb := '[]'; -- Array para subtopics
            topics_array jsonb := '[]';    -- Array para topics
        BEGIN
            -- Subtopics Observations
            FOR v_subtopic IN
                SELECT
                    DISTINCT
                    s.id AS syllabus_id,
                    s2.id AS subtopic_id,
                    s2.name AS subtopic_name,
                    t2.name AS old_topic_name,
                    t.id AS topic_id,
                    t.name AS new_topic_name,
                    CASE
                        WHEN sds.is_topic_modified THEN 'Modified'
                        WHEN sds.is_subtopic_deleted THEN 'Deleted'
                        ELSE 'No Change'
                    END AS action
                FROM syllabus s
                LEFT JOIN syllabus_topic st
                    ON st.syllabus_id = s.id
                    AND st.fl_status = TRUE
                    AND st.deleted_at IS NULL
                LEFT JOIN syllabus_topic_week stw
                    ON stw.syllabus_topic_id = st.id
                    AND stw.fl_status = TRUE
                    AND stw.deleted_at IS NULL
                LEFT JOIN syllabus_detail_subtopic sds
                    ON sds.syllabus_topic_week_id = stw.id
                    AND sds.fl_status = TRUE
                    AND sds.deleted_at IS NULL
                LEFT JOIN subtopic s2
                    ON s2.id = sds.subtopic_id
                LEFT JOIN topic t
                    ON s2.topic_id = t.id
                LEFT JOIN subtopic_history sh
                    ON sh.subtopic_id = s2.id
                LEFT JOIN topic t2
                    ON sh.topic_id = t2.id
                WHERE s.id = p_syllabus_id
                AND s.company_id = p_company_id
                AND (sds.is_topic_modified = TRUE OR sds.is_subtopic_deleted = TRUE)
            LOOP
                -- Agregar cada subtopic con observaciones al array
                subtopics_array := subtopics_array || jsonb_build_object(
                    'syllabus_id', v_subtopic.syllabus_id,
                    'subtopic_id', v_subtopic.subtopic_id,
                    'subtopic_name', v_subtopic.subtopic_name,
                    'old_topic_name', v_subtopic.old_topic_name,
                    'new_topic_name', v_subtopic.new_topic_name,
                    'new_topic_id', v_subtopic.topic_id,
                    'action', v_subtopic.action
                );
            END LOOP;

            -- Topics Observations
            FOR v_topic IN
                SELECT
                    st.syllabus_id,
                    st.topic_id AS topic_id,
                    t.name AS topic_name,
                    'Deleted' AS action
                FROM syllabus_topic st
                LEFT JOIN topic t
                ON st.topic_id = t.id
                WHERE st.syllabus_id = p_syllabus_id
                AND st.company_id = p_company_id
                AND st.is_topic_deleted = TRUE
                AND st.deleted_at IS NULL
            LOOP
                -- Agregar cada topic con observaciones al array
                topics_array := topics_array || jsonb_build_object(
                    'syllabus_id', v_topic.syllabus_id,
                    'topic_id', v_topic.topic_id,
                    'topic_name', v_topic.topic_name,
                    'action', v_topic.action
                );
            END LOOP;

            -- Devolver los resultados
            RETURN QUERY SELECT subtopics_array, topics_array;
        END;
        $$;


ALTER FUNCTION academic.get_detail_syllabus_subtopic(p_syllabus_id integer, p_company_id integer) OWNER TO postgres;

--
