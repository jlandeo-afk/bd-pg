-- Function: odiseo.fn_get_missing_text_with_subquestions(integer, integer, integer[])

--

CREATE FUNCTION odiseo.fn_get_missing_text_with_subquestions(p_material_id integer, p_week integer, p_type_material_ids integer[]) RETURNS TABLE(material character varying, course character varying, category character varying, subcategory character varying, level character varying, topic character varying, subtopic character varying, distribution_id bigint)
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                        RETURN QUERY
                        SELECT 
                            tm.description AS material,
                            c.name AS course,
                            tt.name AS category,
                            tts.name AS subcategory,
                            l.name AS level,
                            t.name AS topic,
                            st.name AS subtopic,
                            mdbq.id AS distribution_id
                        FROM 
                            material_ballot_question mdbq
                        JOIN material_ballot_subquestions mbs ON mbs.material_ballot_question_id = mdbq.id AND mbs.fl_status = TRUE
                        JOIN type_text tt ON tt.id = mdbq.type_text_id 
                        JOIN type_text_subcategories tts ON tts.id = mdbq.type_text_subcategory_id
                        JOIN "level" l ON l.id = mdbq.level_id
                        JOIN course c ON c.id = mdbq.course_id
                        JOIN type_material tm ON tm.id = mdbq.type_material_id 
                        JOIN topic t ON t.id = mbs.topic_id
                        JOIN subtopic st ON st.id = mbs.subtopic_id
                        WHERE 
                            mdbq.material_id = p_material_id
                            AND mdbq.week = p_week
                            AND mdbq.type_material_id = ANY(p_type_material_ids)
                            AND mdbq.fl_status = TRUE
                            AND mdbq.type_text_id IS NOT NULL
                            AND mbs.state = 'MISSING';

                    END;
                $$;


ALTER FUNCTION odiseo.fn_get_missing_text_with_subquestions(p_material_id integer, p_week integer, p_type_material_ids integer[]) OWNER TO postgres;

--
