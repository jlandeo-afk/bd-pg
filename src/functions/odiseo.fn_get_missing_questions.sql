-- Function: odiseo.fn_get_missing_questions(integer, integer, integer[])

--

CREATE FUNCTION odiseo.fn_get_missing_questions(p_material_id integer, p_week integer, p_type_material_ids integer[]) RETURNS TABLE(material character varying, course character varying, topic character varying, subtopic character varying, level character varying, type character varying)
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                    RETURN QUERY
                    SELECT 
                        tm.description AS material,
                        c.name AS course,
                        t.name AS topic,
                        s.name AS subtopic,
                        l.name AS level,
                        mdbq."type"
                    FROM 
                        material_ballot_question mdbq
                    JOIN "level" l ON l.id = mdbq.level_id
                    JOIN course c ON c.id = mdbq.course_id
                    JOIN type_material tm ON tm.id = mdbq.type_material_id
                    JOIN topic t ON t.id = mdbq.topic_id 
                    JOIN subtopic s ON s.id = mdbq.subtopic_id 
                    WHERE 
                    mdbq.material_id = p_material_id
                    AND mdbq.week = p_week
                    AND mdbq.type_material_id = ANY(p_type_material_ids)
                    AND mdbq.fl_status = TRUE
                    AND mdbq.type_text_id IS NULL
                    AND mdbq.question_id IS NULL;

                    END;
                $$;


ALTER FUNCTION odiseo.fn_get_missing_questions(p_material_id integer, p_week integer, p_type_material_ids integer[]) OWNER TO postgres;

--
