-- Function: odiseo.fn_get_ballot_question_single_type_material(integer)

--

CREATE FUNCTION odiseo.fn_get_ballot_question_single_type_material(p_week_type_material_id integer) RETURNS TABLE(id bigint, material_ballot_question_id bigint, question_id bigint, week_type_material_id bigint, course_id smallint, topic_id smallint, subtopic_id smallint, level_id bigint, type character varying, random boolean, "position" smallint, valid_question boolean, absolute_position smallint, topic_code character varying, subtopic_code character varying, parent_question_id bigint, type_text_id bigint, level smallint)
    LANGUAGE plpgsql
    AS $$
        
        BEGIN
                 RETURN QUERY
            WITH material_ballot_questions AS (
                SELECT
                    mbq.id,
                    mbq.id AS material_ballot_question_id,
                    COALESCE(mbq.question_id, mbq.id * -1) AS question_id,
                    mbq.week_type_material_id::bigint,
                    mbq.course_id,
                    mbq.topic_id,
                    mbq.subtopic_id,
                    mbq.level_id,
                    mbq.type,
                    mbq.random,
                    mbq.position,
                    (mbq.question_id IS NOT NULL OR mbq.parent_question_id IS NOT NULL) AS valid_question,
                    mbq.absolute_position,
                    t.code AS topic_code,
                    s.code AS subtopic_code,
                    mbq.parent_question_id,
                    mbq.type_text_id
                FROM material_ballot_question mbq
                LEFT JOIN topic t ON t.id = mbq.topic_id
                LEFT JOIN subtopic s ON s.id = mbq.subtopic_id
                WHERE mbq.fl_status IS TRUE
                  AND mbq.deleted_at IS NULL
                  AND mbq.week_type_material_id = p_week_type_material_id
            )
           	SELECT
           	    mqs.id,
           	    mqs.material_ballot_question_id,
           	    mqs.question_id,
           	    mqs.week_type_material_id,
           	    mqs.course_id,
           	    mqs.topic_id,
           	    mqs.subtopic_id,
           	    mqs.level_id,
           	    mqs.type,
           	    mqs.random,
           	    mqs.position,
           	    mqs.valid_question,
           	    mqs.absolute_position,
           	    mqs.topic_code,
           	    mqs.subtopic_code,
           	    mqs.parent_question_id,
           	    mqs.type_text_id,
           	    l.name::SMALLINT AS level
           	FROM material_ballot_questions mqs
           	LEFT JOIN level l ON l.id = mqs.level_id
           	ORDER BY
           	    mqs.course_id,
           	    mqs.topic_code ASC,
           	    mqs.subtopic_code ASC,
           	    l.name::SMALLINT ASC;
        END;
        $$;


ALTER FUNCTION odiseo.fn_get_ballot_question_single_type_material(p_week_type_material_id integer) OWNER TO postgres;

--
