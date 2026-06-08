-- Function: odiseo.fn_paginate_compatible_questions(bigint, integer, integer)

--

CREATE FUNCTION odiseo.fn_paginate_compatible_questions(p_material_ballot_question_id bigint, p_per_page integer DEFAULT 3, p_page integer DEFAULT 1) RETURNS TABLE(id bigint, total bigint)
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_offset INTEGER;
    v_max_questions INTEGER;
BEGIN
    IF p_page < 1 THEN
        p_page := 1;
    END IF;

    v_offset := p_per_page * (p_page - 1);

    SELECT amount_questions_alternatives INTO v_max_questions 
    FROM advanced_settings 
    LIMIT 1;

    RETURN QUERY
    WITH question_attribute AS (
        SELECT 
            mbq.course_id, 
            mbq.topic_id, 
            mbq.subtopic_id, 
            mbq.level_id,
            dwtm.material_id 
        FROM material_ballot_question mbq 
        INNER JOIN detail_week_type_mat dwtm ON dwtm.id = mbq.week_type_material_id 
        WHERE mbq.id = p_material_ballot_question_id
    ),
    matching_questions AS (
        SELECT 
            flq.id,
            flq.status,
            q.updated_at
        FROM question_attribute qa
        CROSS JOIN LATERAL fn_list_questions_verified_and_not_excluded(qa.material_id) flq
        INNER JOIN question q ON q.id = flq.id
        WHERE flq.course_id = qa.course_id 
          AND flq.level_id = qa.level_id 
          AND flq.subtopic_id = qa.subtopic_id
          AND flq.topic_id = qa.topic_id
        ORDER BY 
            flq.status ASC,
            q.updated_at DESC,
            flq.id DESC
        LIMIT v_max_questions
    )
    SELECT 
        mq.id,
        COUNT(*) OVER()::BIGINT AS total 
    FROM matching_questions mq
    ORDER BY 
        mq.status ASC,
        mq.updated_at DESC,
        mq.id DESC
    LIMIT p_per_page 
    OFFSET v_offset;
END;
$$;


ALTER FUNCTION odiseo.fn_paginate_compatible_questions(p_material_ballot_question_id bigint, p_per_page integer, p_page integer) OWNER TO postgres;

--
