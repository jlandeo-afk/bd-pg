-- Function: academic.fn_edit_position_topics(smallint, jsonb, bigint)

--

CREATE FUNCTION academic.fn_edit_position_topics(p_course_id smallint, p_topics jsonb, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_topics JSONB;
            v_validate_topic_id SMALLINT;
            v_topic_id SMALLINT;
        BEGIN
            FOR v_topics IN SELECT jsonb_array_elements(p_topics) LOOP
                SELECT t.id INTO v_validate_topic_id FROM academic.topic t
                WHERE t.id = (v_topics->>'id')::SMALLINT AND t.course_id = p_course_id AND t.fl_status = true LIMIT 1;

                IF v_validate_topic_id IS NOT NULL THEN
                    SELECT top.id INTO v_topic_id FROM academic.topic top WHERE top.code = (v_topics->>'code')::VARCHAR AND top.id = (v_topics->>'id')::SMALLINT AND top.course_id = p_course_id LIMIT 1;

                    IF v_topic_id IS NULL THEN
                        UPDATE academic.topic SET code = (v_topics->>'code')::VARCHAR, updated_by = p_updated_by, updated_at = now() WHERE id = (v_topics->>'id')::SMALLINT;
                    END IF;
                END IF;

            END LOOP;
        END;
        $$;


ALTER FUNCTION academic.fn_edit_position_topics(p_course_id smallint, p_topics jsonb, p_updated_by bigint) OWNER TO postgres;

--
