-- Function: academic.fn_edit_position_subtopics(smallint, jsonb, bigint)

--

CREATE FUNCTION academic.fn_edit_position_subtopics(p_topic_id smallint, p_subtopics jsonb, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_subtopics JSONB;
            v_validate_subtopic_id SMALLINT;
            v_subtopic_id SMALLINT;
        BEGIN
            FOR v_subtopics IN SELECT jsonb_array_elements(p_subtopics) LOOP
                SELECT s.id INTO v_validate_subtopic_id FROM academic.subtopic s
                WHERE s.id = (v_subtopics->>'id')::SMALLINT AND s.topic_id = p_topic_id AND s.fl_status = true LIMIT 1;

                IF v_validate_subtopic_id IS NOT NULL THEN
                    SELECT st.id INTO v_subtopic_id FROM academic.subtopic st WHERE st.code = (v_subtopics->>'code')::VARCHAR AND st.id = (v_subtopics->>'id')::SMALLINT AND st.topic_id = p_topic_id LIMIT 1;

                    IF v_subtopic_id IS NULL THEN
                        UPDATE academic.subtopic SET code = (v_subtopics->>'code')::VARCHAR, updated_by = p_updated_by, updated_at = now() WHERE id = (v_subtopics->>'id')::SMALLINT;
                    END IF;
                END IF;

            END LOOP;
        END;
        $$;


ALTER FUNCTION academic.fn_edit_position_subtopics(p_topic_id smallint, p_subtopics jsonb, p_updated_by bigint) OWNER TO postgres;

--
