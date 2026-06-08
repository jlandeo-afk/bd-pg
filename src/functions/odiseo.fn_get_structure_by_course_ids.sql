-- Function: odiseo.fn_get_structure_by_course_ids(jsonb)

--

CREATE FUNCTION odiseo.fn_get_structure_by_course_ids(course_ids_json jsonb) RETURNS TABLE(unification json)
    LANGUAGE plpgsql
    AS $$
    DECLARE
        v_cid1 INTEGER;
        v_cid2 INTEGER;
    BEGIN
        SELECT value::int INTO v_cid1 FROM jsonb_array_elements_text(course_ids_json) WITH ORDINALITY WHERE ordinality = 1;
        SELECT value::int INTO v_cid2 FROM jsonb_array_elements_text(course_ids_json) WITH ORDINALITY WHERE ordinality = 2;

        RETURN QUERY
        SELECT 
            COALESCE(json_agg(
                json_build_object(
                    'uuid', n1.uuid,
                    
                    'first_course_id', n1.course_id,
                    'first_topic_id', n1.topic_id,
                    'first_last_name_topic', n1.last_name_topic,
                    'first_new_name_topic', n1.new_name_topic,
                    'first_subtopic_id', n1.subtopic_id,
                    'first_last_name_subtopic', n1.last_name_subtopic,
                    'first_new_name_subtopic', n1.new_name_subtopic,
                    
                    'second_course_id', n2.course_id,
                    'second_topic_id', n2.topic_id,
                    'second_last_name_topic', n2.last_name_topic,
                    'second_new_name_topic', n2.new_name_topic,
                    'second_subtopic_id', n2.subtopic_id,
                    'second_last_name_subtopic', n2.last_name_subtopic,
                    'second_new_name_subtopic', n2.new_name_subtopic
                )
            ), '[]'::json)
        
        FROM network_course_topic_subtopic n1
        INNER JOIN network_course_topic_subtopic n2 ON n1.uuid = n2.uuid
        WHERE n1.course_id = v_cid1
          AND n2.course_id = v_cid2;

    END;
    $$;


ALTER FUNCTION odiseo.fn_get_structure_by_course_ids(course_ids_json jsonb) OWNER TO postgres;

--
