-- Function: odiseo.fn_paginate_material_revision_questions(integer, integer, integer, character varying, integer, integer, integer, integer, integer, integer, character varying, integer)

--

CREATE FUNCTION odiseo.fn_paginate_material_revision_questions(p_detail_course_id integer, p_per_page integer, p_page integer, p_search character varying DEFAULT NULL::character varying, p_topic_id integer DEFAULT NULL::integer, p_subtopic_id integer DEFAULT NULL::integer, p_week integer DEFAULT NULL::integer, p_university_id integer DEFAULT NULL::integer, p_option_id integer DEFAULT NULL::integer, p_modality_id integer DEFAULT NULL::integer, p_year character varying DEFAULT NULL::character varying, p_version integer DEFAULT NULL::integer) RETURNS TABLE(detail_course_id bigint, material_ballot_question_id bigint, question_id bigint, type_material character varying, level smallint, code character varying, type character varying, status character varying, topic_code character varying, subtopic_code character varying, topic character varying, subtopic character varying, origin_question jsonb, updated_at timestamp without time zone, week smallint, amount_questions_changed smallint, reason text, correlative text, total bigint)
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_offset INTEGER;
BEGIN
    v_offset := p_per_page * (p_page - 1);

    RETURN QUERY
    WITH all_week_type_material AS (
        SELECT 
            mrc.id AS detail_course_id,
            mri.detail_week_type_mat_id, 
            mrc.course_id,
            mrc.amount_questions_changed
        FROM material_revision_courses mrc
        JOIN material_revisions mr ON mr.id = mrc.material_revision_id 
        JOIN material_revision_items mri ON mri.material_revision_id = mr.id
        WHERE mrc.id = p_detail_course_id
    ),
    filtered_questions AS (
        SELECT 
            awtm.detail_course_id,
            mbq.id AS material_ballot_question_id,
            mbq.question_id,
            tm.description AS type_material,
            l.name::smallint AS level,
            q.code,
            q.type,
            q.status,
            t.code AS topic_code,
            s.code AS subtopic_code,
            t.name AS topic,
            s.name AS subtopic,
            mbq.updated_at,
            dwtm.week::smallint,
            m.university_id AS material_university_id,
            awtm.amount_questions_changed,
            mqcr.reason,
            CONCAT_WS('-', UPPER(LEFT(tm.description, 4)), mbq.position + 1) AS correlative
        FROM material_ballot_question mbq
        JOIN all_week_type_material awtm ON awtm.detail_week_type_mat_id = mbq.week_type_material_id AND awtm.course_id = mbq.course_id
        JOIN question q ON q.id = mbq.question_id
        JOIN detail_week_type_mat dwtm ON dwtm.id = mbq.week_type_material_id
        JOIN type_material tm ON tm.id = dwtm.type_material_id
        JOIN material m ON m.id = dwtm.material_id
        LEFT JOIN "level" l ON l.id = mbq.level_id
        LEFT JOIN topic t ON t.id = mbq.topic_id
        LEFT JOIN subtopic s ON s.id = mbq.subtopic_id
        LEFT JOIN material_question_change_reason mqcr ON mqcr.material_ballot_question_id = mbq.id AND mqcr.material_revision_course_id = awtm.detail_course_id
        WHERE mbq.fl_status = true
        AND (p_topic_id IS NULL OR mbq.topic_id = p_topic_id)
        AND (p_subtopic_id IS NULL OR mbq.subtopic_id = p_subtopic_id)
        AND (p_week IS NULL OR dwtm.week = p_week)
        AND (p_search IS NULL OR q.code ILIKE '%' || p_search || '%')
        AND (
            p_university_id IS NULL AND p_option_id IS NULL AND p_modality_id IS NULL AND p_version IS NULL AND p_year IS NULL 
            OR EXISTS (
                SELECT 1
                FROM v_all_question_origins_by_university vq
                WHERE vq.question_id = mbq.question_id
                AND vq.university_id = m.university_id
                AND (p_university_id IS NULL OR vq.university_id = p_university_id)
                AND (p_option_id IS NULL OR vq.option_id = p_option_id)
                AND (p_modality_id IS NULL OR vq.modality_id = p_modality_id)
                AND (p_version IS NULL OR vq.version::integer = p_version)
                AND (p_year IS NULL OR vq.year = p_year)
            )
        )
        ORDER BY dwtm.week, LEFT(tm.description, 1), mbq.position
    )
    SELECT
        fq.detail_course_id,
        fq.material_ballot_question_id,
        fq.question_id,
        fq.type_material,
        fq.level,
        fq.code,
        fq.type,
        fq.status,
        fq.topic_code,
        fq.subtopic_code,
        fq.topic,
        fq.subtopic,
        (
            SELECT vo.question_origin
            FROM v_all_question_origins_by_university vo
            WHERE vo.question_id = fq.question_id 
            AND vo.university_id = fq.material_university_id
            LIMIT 1
        ) AS origin_question,
        fq.updated_at,
        fq.week,
        fq.amount_questions_changed,
        fq.reason,
        fq.correlative,
        COUNT(*) OVER() AS total 
    FROM filtered_questions fq
    LIMIT p_per_page OFFSET v_offset;
END;
$$;


ALTER FUNCTION odiseo.fn_paginate_material_revision_questions(p_detail_course_id integer, p_per_page integer, p_page integer, p_search character varying, p_topic_id integer, p_subtopic_id integer, p_week integer, p_university_id integer, p_option_id integer, p_modality_id integer, p_year character varying, p_version integer) OWNER TO postgres;

--
