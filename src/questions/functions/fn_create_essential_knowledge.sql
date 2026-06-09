-- Function: questions.fn_create_essential_knowledge(character varying, character varying, boolean, bigint, bigint, text, text, text, character varying, bigint, timestamp without time zone)

--

CREATE FUNCTION questions.fn_create_essential_knowledge(p_code character varying, p_name character varying, p_is_active boolean, p_topic_id bigint, p_course_id bigint, p_editor_content text, p_thumbnail text, p_filename text, p_extension character varying, p_created_by bigint, p_created_at timestamp without time zone) RETURNS TABLE(topic_id bigint, course_id bigint, name character varying, file_name text, code character varying, id bigint)
    LANGUAGE plpgsql
    AS $$
        DECLARE 
            v_essential_knowledge_id BIGINT;
        BEGIN
        INSERT INTO essential_knowledges (
            code,
            name,
            is_active,
            topic_id,
            course_id,
            editor_content,
            thumbnail,
            created_by,
            created_at
        )
        VALUES (
            p_code,
            p_name,
            p_is_active,
            p_topic_id,
            p_course_id,
            p_editor_content,
            p_thumbnail,
            p_created_by,
            p_created_at
        )
        returning essential_knowledges.id into v_essential_knowledge_id;

        insert into essential_knowledge_image (
            essential_knowledge_id,
            image,
            extension,
            created_by,
            created_at
        )
        values (
            v_essential_knowledge_id,
            p_filename,
            p_extension,
            p_created_by,
            p_created_at
        );

        RETURN QUERY
        SELECT
            p_topic_id,
            p_course_id,
            p_name,
            p_filename,
            p_code,
            v_essential_knowledge_id;

end;
$$;


ALTER FUNCTION questions.fn_create_essential_knowledge(p_code character varying, p_name character varying, p_is_active boolean, p_topic_id bigint, p_course_id bigint, p_editor_content text, p_thumbnail text, p_filename text, p_extension character varying, p_created_by bigint, p_created_at timestamp without time zone) OWNER TO postgres;

--
