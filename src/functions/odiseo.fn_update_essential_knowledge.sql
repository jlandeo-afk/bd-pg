-- Function: odiseo.fn_update_essential_knowledge(bigint, character varying, character varying, bigint, bigint, text, text, text, character varying, bigint, timestamp without time zone)

--

CREATE FUNCTION odiseo.fn_update_essential_knowledge(p_id bigint, p_code character varying, p_name character varying, p_topic_id bigint, p_course_id bigint, p_editor_content text, p_thumbnail text, p_filename text, p_extension character varying, p_updated_by bigint, p_updated_at timestamp without time zone) RETURNS TABLE(topic_id bigint, course_id bigint, name character varying, file_name text, code character varying, id bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE essential_knowledges
    SET 
        code = p_code,
        name = p_name,
        topic_id = p_topic_id,
        course_id = p_course_id,
        editor_content = p_editor_content,
        thumbnail = p_thumbnail,
        updated_by = p_updated_by,
        updated_at = p_updated_at
    WHERE essential_knowledges.id = p_id;

    UPDATE essential_knowledge_image
    SET 
        deleted_at = p_updated_at,
        deleted_by = p_updated_by
    WHERE essential_knowledge_id = p_id AND deleted_at IS NULL;

    INSERT INTO essential_knowledge_image (essential_knowledge_id, image, extension, created_by, updated_at)
    VALUES (p_id, p_filename, p_extension, p_updated_by, p_updated_at);

    RETURN QUERY
    SELECT
        p_topic_id,
        p_course_id,
        p_name,
        p_filename,
        p_code,
        p_id;
END;
$$;


ALTER FUNCTION odiseo.fn_update_essential_knowledge(p_id bigint, p_code character varying, p_name character varying, p_topic_id bigint, p_course_id bigint, p_editor_content text, p_thumbnail text, p_filename text, p_extension character varying, p_updated_by bigint, p_updated_at timestamp without time zone) OWNER TO postgres;

--
