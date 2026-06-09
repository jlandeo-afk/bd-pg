-- Function: questions.fn_list_essential_knowledge(integer, integer, bigint, bigint)

--

CREATE FUNCTION questions.fn_list_essential_knowledge(p_perpage integer, p_npage integer, p_course_id bigint, p_topic_id bigint) RETURNS TABLE(id bigint, code character varying, name character varying, course_id bigint, topic_id bigint, image text, total bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    offset_val integer := p_perpage * (p_npage - 1);
BEGIN
    -- Listar los conocimientos esenciales asociados a un curso y tema específicos
    RETURN QUERY
    WITH essential_knowledges AS (
        SELECT
            ek.id,
            ek.code,
            ek.name,
            ek.course_id,
            ek.topic_id,
            eki.image
        FROM essential_knowledges ek
        INNER JOIN essential_knowledge_image eki ON ek.id = eki.essential_knowledge_id
        WHERE 1 = 1
          AND ek.course_id = p_course_id
          AND ( p_topic_id IS NULL OR ek.topic_id = p_topic_id )
          AND ek.is_active is true
          AND ek.deleted_at IS NULL
          AND eki.deleted_at IS NULL
    ), counted_essential_knowledges AS (
        SELECT
            *,
            count(*) OVER () AS total
        FROM essential_knowledges
    )
    SELECT
        *
    FROM
        counted_essential_knowledges cek
    ORDER BY
        split_part(cek.code, '-', 1) ASC,
        split_part(cek.code, '-', 2) ASC,
        split_part(cek.code, '-', 3) ASC
    LIMIT p_perpage OFFSET offset_val;

END;
$$;


ALTER FUNCTION questions.fn_list_essential_knowledge(p_perpage integer, p_npage integer, p_course_id bigint, p_topic_id bigint) OWNER TO postgres;

--
