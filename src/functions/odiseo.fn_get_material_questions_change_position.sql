-- Function: odiseo.fn_get_material_questions_change_position(integer, jsonb)

--

CREATE FUNCTION odiseo.fn_get_material_questions_change_position(p_week_type_material_id integer, p_topic_ids jsonb) RETURNS TABLE(week_type_material_id bigint, course_id smallint, topic_id smallint, subtopic_id smallint, level_id bigint, level smallint, question_id bigint, type character varying)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    mbq.week_type_material_id,
                    mbq.course_id,
                    mbq.topic_id,
                    mbq.subtopic_id,
                    mbq.level_id,
                    l."name"::SMALLINT  AS level,
                    mbq.question_id, 
                    mbq."type"
                FROM odiseo.material_ballot_question mbq
                LEFT JOIN odiseo."level" l
                    ON mbq.level_id = l.id
                WHERE mbq.fl_status = TRUE
                    AND mbq.week_type_material_id = p_week_type_material_id
                    AND mbq.topic_id = ANY (
                        SELECT jsonb_array_elements_text(p_topic_ids)::BIGINT
                    );
            END;
            $$;


ALTER FUNCTION odiseo.fn_get_material_questions_change_position(p_week_type_material_id integer, p_topic_ids jsonb) OWNER TO postgres;

--
