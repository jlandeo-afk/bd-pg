-- Function: materials.fn_get_missing_ballot_questions_per_period(integer, integer, smallint, smallint)

--

CREATE FUNCTION materials.fn_get_missing_ballot_questions_per_period(p_material_id integer, p_type_material_id integer, p_start_week smallint, p_end_week smallint) RETURNS TABLE(week smallint, material character varying, course character varying, course_id smallint, topic character varying, subtopic character varying, level character varying, type character varying)
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                        RETURN QUERY
                        WITH type_material_ids AS (
                            SELECT UNNEST(
                                CASE
                                    WHEN EXISTS (SELECT 1 FROM type_material tm WHERE tm.parent_id = p_type_material_id)
                                    THEN ARRAY(SELECT tm.id FROM type_material tm WHERE tm.parent_id = p_type_material_id)
                                    ELSE ARRAY[p_type_material_id]
                                END
                            ) AS id
                        )
                        SELECT 
                            mdbq.week,
                            tm.description AS material,
                            c.name AS course,
                            c.id as course_id,
                            t.name AS topic,
                            s.name AS subtopic,
                            l.name AS level,
                            mdbq."type"
                        FROM material_ballot_question mdbq 
                        JOIN "level" l ON l.id = mdbq.level_id
                        JOIN course c ON c.id = mdbq.course_id
                        JOIN type_material tm ON tm.id = mdbq.type_material_id
                        JOIN topic t ON t.id = mdbq.topic_id 
                        JOIN subtopic s ON s.id = mdbq.subtopic_id 
                        WHERE mdbq.material_id = p_material_id
                        AND mdbq.fl_status = TRUE
                        AND mdbq.type_material_id IN (SELECT * FROM type_material_ids)
                        AND mdbq.week BETWEEN p_start_week AND p_end_week
                        AND mdbq.type_text_id IS NULL
                        AND mdbq.question_id IS NULL;
                    END;
                $$;


ALTER FUNCTION materials.fn_get_missing_ballot_questions_per_period(p_material_id integer, p_type_material_id integer, p_start_week smallint, p_end_week smallint) OWNER TO postgres;

--
