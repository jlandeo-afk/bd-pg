-- Function: questions.fn_index_essential_knowledge(integer, integer, character varying, bigint, bigint[], bigint, boolean)

--

CREATE FUNCTION questions.fn_index_essential_knowledge(p_npage integer, p_perpage integer, p_name_text character varying, p_course_id bigint, p_user_course_ids bigint[], p_topic_id bigint, p_is_active boolean) RETURNS TABLE(id bigint, code character varying, name character varying, is_active boolean, topic_id bigint, topic_name character varying, course_id bigint, course_name character varying, thumbnail text, created_at timestamp without time zone, total_use bigint, total bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_offset INTEGER;
BEGIN
    -- Validación de página mínima
    IF p_npage < 1 THEN p_npage := 1; END IF;

    v_offset := (p_npage - 1) * p_perpage;

    RETURN QUERY
    SELECT
        ek.id,
        ek.code,
        ek.name,
        ek.is_active,
        ek.topic_id,
        concat(t.code, ' - ', t.name)::varchar as topic_name,
        ek.course_id,
        concat(c.code, ' - ', c.name)::varchar as course_name,
        ek.thumbnail,
        ek.created_at,
        COUNT(ekq.id) AS total_use,
        COUNT(*) OVER() AS total
    FROM essential_knowledges ek
    JOIN topic t ON t.id = ek.topic_id
    JOIN course c ON c.id = ek.course_id
    LEFT JOIN essential_knowledge_questions ekq ON ekq.essential_knowledge_id = ek.id
        AND ekq.deleted_at IS NULL
    WHERE 1 = 1
        AND (p_is_active IS NULL OR ek.is_active = p_is_active)
        AND (p_course_id IS NULL OR ek.course_id = p_course_id)
        AND ek.course_id = ANY(p_user_course_ids)
        AND (p_topic_id IS NULL OR ek.topic_id = p_topic_id)
        AND (
            NULLIF(p_name_text, '') IS NULL
            OR unaccent(ek.name) ILIKE unaccent('%' || p_name_text || '%')
            OR ek.code ILIKE '%' || p_name_text || '%'
        )
        AND ek.deleted_at IS NULL
    GROUP BY ek.id, t.id, c.id
    ORDER BY ek.created_at DESC
    LIMIT p_perpage
    OFFSET v_offset;
END;
$$;


ALTER FUNCTION questions.fn_index_essential_knowledge(p_npage integer, p_perpage integer, p_name_text character varying, p_course_id bigint, p_user_course_ids bigint[], p_topic_id bigint, p_is_active boolean) OWNER TO postgres;

--
