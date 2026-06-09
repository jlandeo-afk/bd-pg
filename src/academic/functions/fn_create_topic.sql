-- Function: academic.fn_create_topic(character varying, character varying, integer, jsonb, integer)

--

CREATE FUNCTION academic.fn_create_topic(p_code character varying, p_name character varying, p_course_id integer, p_subtopics jsonb, p_created_by integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_new_topic_id INTEGER;
            BEGIN
                -- Insertar el tema principal
                INSERT INTO academic.topic (code, name, course_id, created_by, created_at)
                VALUES (p_code, p_name, p_course_id, p_created_by, now())
                RETURNING id INTO v_new_topic_id;

                -- Insertar los subtemas en lote
                INSERT INTO academic.subtopic (topic_id, code, name, created_by, created_at)
                SELECT v_new_topic_id, subtopic->>'code', subtopic->>'name', p_created_by, now()
                FROM jsonb_array_elements(p_subtopics) AS subtopic;

                RETURN v_new_topic_id;
            END;
            $$;


ALTER FUNCTION academic.fn_create_topic(p_code character varying, p_name character varying, p_course_id integer, p_subtopics jsonb, p_created_by integer) OWNER TO postgres;

--
