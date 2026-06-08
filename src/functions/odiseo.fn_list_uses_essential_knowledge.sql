-- Function: odiseo.fn_list_uses_essential_knowledge(integer, integer, character varying, bigint)

--

CREATE FUNCTION odiseo.fn_list_uses_essential_knowledge(p_perpage integer, p_npage integer, p_search character varying, p_essential_knowledge_id bigint) RETURNS TABLE(id bigint, question_id bigint, code character varying, status character varying, total bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    offset_val integer := p_perpage * (p_npage - 1);
BEGIN
    -- Listar los conocimientos esenciales asociados a un curso y tema específicos
    RETURN QUERY
    WITH tbl_essential_knowledges_questions AS (
        SELECT
            ek.id,
            q.id AS question_id,
            q.code,
            q.status
        FROM essential_knowledges ek
        JOIN essential_knowledge_image eki ON ek.id = eki.essential_knowledge_id
        JOIN essential_knowledge_questions ekq ON ek.id = ekq.essential_knowledge_id
        JOIN question q ON ekq.question_id = q.id
            AND q.fl_status = true
        WHERE 1 = 1
            AND ek.id = p_essential_knowledge_id
            AND (p_search IS NULL OR q.code ILIKE '%' || p_search || '%')
            AND ek.is_active is true
            AND ek.deleted_at IS NULL
            AND eki.deleted_at IS NULL
            AND ekq.deleted_at IS NULL
    ), counted_essential_knowledges AS (
        SELECT
            *,
            count(*) OVER () AS total
        FROM tbl_essential_knowledges_questions
    )
    SELECT
        *
    FROM
        counted_essential_knowledges cek
    ORDER BY
        cek.code DESC
    LIMIT p_perpage OFFSET offset_val;

END;
$$;


ALTER FUNCTION odiseo.fn_list_uses_essential_knowledge(p_perpage integer, p_npage integer, p_search character varying, p_essential_knowledge_id bigint) OWNER TO postgres;

--
