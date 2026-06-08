-- Function: odiseo.fn_params_index(bigint, smallint)

--

CREATE FUNCTION odiseo.fn_params_index(p_question_id bigint, p_subtopic_id smallint DEFAULT NULL::smallint) RETURNS TABLE(id bigint, course_id smallint, code_course character varying, course character varying, topic_id smallint, code_topic character varying, topic character varying, subtopics jsonb, level_id smallint, level character varying, type character varying, ter numeric, type_question text, status character varying, type_text_template_id smallint, type_text_template_name character varying, description_text character varying, description_subquestion character varying, text_attributes character varying, subquestion_attributes character varying, question_attributes jsonb, shared_status text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH context_data AS (
        SELECT
            q.id AS question_id,
            COALESCE(qsh.course_id, q.course_id) AS course_id,
            COALESCE(qsh.topic_id, q.topic_id) AS topic_id,
            qsh.subtopic_id,
            (qsh.id IS NOT NULL) AS has_share
        FROM question q
        LEFT JOIN question_shares qsh 
            ON qsh.question_id = q.id 
            AND qsh.subtopic_id = p_subtopic_id 
            AND qsh.deleted_at IS NULL
        WHERE q.id = p_question_id
    ),

    course_question AS (
        SELECT
            cd.course_id,
            CASE WHEN q.parent_id IS NULL THEN 'P' ELSE 'S' END AS type
        FROM context_data cd
        JOIN question q ON q.id = cd.question_id
    ),

    attributes_course AS (
        SELECT
            qatc.course_id,
            qat.id AS question_attribute_type_id,
            qat.name,
            qatv.label,
            qatv.description,
            qatv.value
        FROM question_attributes_type_course qatc
        JOIN course_question cq ON cq.course_id = qatc.course_id
        JOIN question_attributes_type qat 
            ON qatc.question_attributes_type_id = qat.id
            AND qat.deleted_at IS NULL
        LEFT JOIN question_attributes qa 
            ON qatc.id = qa.question_attributes_type_id
            AND qa.deleted_at IS NULL
            AND qa.question_id = p_question_id
        LEFT JOIN question_attributes_types_values qatv 
            ON qat.id = qatv.question_attributes_type_id
            AND qatv.deleted_at IS NULL
            AND qatv.value = qa.value
        WHERE qatc.types_questions ILIKE '%' || cq.type || '%'
          AND qatc.deleted_at IS NULL
    )

    SELECT
        q.id,
        cd.course_id::SMALLINT,
        c.code AS code_course,
        c.name AS course,
        cd.topic_id::SMALLINT,
        t.code AS code_topic,
        t.name AS topic,

        CASE 
            WHEN cd.has_share THEN
                JSONB_BUILD_ARRAY(
                    JSONB_BUILD_OBJECT(
                        'subtopic_id', s_override.id,
                        'code_subtopic', s_override.code,
                        'subtopic', s_override.name
                    )
                )
            ELSE
                COALESCE(
                    JSONB_AGG(
                        DISTINCT JSONB_BUILD_OBJECT (
                            'subtopic_id', qs.subtopic_id,
                            'code_subtopic', s.code,
                            'subtopic', s.name
                        )
                    ) FILTER (WHERE qs.subtopic_id IS NOT NULL), '[]'
                )
        END AS subtopics,

        q.level_id,
        l.description AS level,
        q.type,
        q.ter,

        CASE WHEN q.parent_id IS NOT NULL THEN 'S' ELSE 'P' END AS type_question,

        q.status,

        c.type_text_template_id,
        ttt.name,
        ttt.description_text,
        ttt.description_subquestion,
        ttt.text_attributes,
        ttt.subquestion_attributes,

        COALESCE(
            JSONB_AGG(
                DISTINCT JSONB_BUILD_OBJECT (
                    'question_attribute_type_id', ac.question_attribute_type_id,
                    'name', ac.name,
                    'label', ac.label,
                    'description', ac.description,
                    'value', ac.value
                )
            ) FILTER (WHERE ac.question_attribute_type_id IS NOT NULL), '[]'
        ) AS question_attributes,
        CASE 
            WHEN cd.has_share THEN get_shared_status(q.id, cd.subtopic_id)
            ELSE get_shared_status(q.id, qs.subtopic_id)
        END AS shared_status
    FROM context_data cd
    JOIN question q ON q.id = cd.question_id

    LEFT JOIN course c ON c.id = cd.course_id
    LEFT JOIN topic t ON t.id = cd.topic_id
    LEFT JOIN level l ON l.id = q.level_id

    LEFT JOIN question_subtopic qs 
        ON q.id = qs.question_id 
        AND qs.fl_status = true
        AND cd.has_share = false

    LEFT JOIN subtopic s ON s.id = qs.subtopic_id
    LEFT JOIN subtopic s_override ON s_override.id = cd.subtopic_id

    LEFT JOIN type_text_templates ttt ON ttt.id = c.type_text_template_id

    LEFT JOIN attributes_course ac ON ac.course_id = cd.course_id

    GROUP BY 
        q.id,
        cd.course_id,
        c.code,
        c.name,
        cd.topic_id,
        t.code,
        t.name,
        l.description,
        c.type_text_template_id,
        ttt.id,
        cd.has_share,
        s_override.id,
        s_override.code,
        qs.subtopic_id,
        cd.subtopic_id,
        s_override.name;
END;
$$;


ALTER FUNCTION odiseo.fn_params_index(p_question_id bigint, p_subtopic_id smallint) OWNER TO postgres;

--
