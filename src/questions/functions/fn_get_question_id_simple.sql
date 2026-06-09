-- Function: questions.fn_get_question_id_simple(bigint)

--

CREATE FUNCTION questions.fn_get_question_id_simple(p_id bigint) RETURNS TABLE(id bigint, code character varying, description text, short_description text, parent_id bigint, status character varying, course_id smallint, area_id bigint, url_pdf character varying, type_question text, type_text_template_id smallint, text_attributes character varying, subquestion_attributes character varying, shared_status text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        q.id,
        q.code,
        q.description,
        q.short_description,
        q.parent_id,
        q.status,
        q.course_id,
        c.area_id,
        q.url_pdf,
        CASE
            WHEN q.parent_id IS NOT NULL THEN 'S'
            ELSE 'P'
        END AS type_question,
        c.type_text_template_id,
        ttt.text_attributes,
        ttt.subquestion_attributes,
        get_shared_status(q.id, qs.subtopic_id) AS shared_status
    FROM question q
    LEFT JOIN course c ON q.course_id = c.id
    LEFT JOIN type_text_templates ttt ON c.type_text_template_id = ttt.id
    LEFT JOIN question_subtopic qs ON qs.question_id = q.id
    WHERE q.id = p_id
      AND q.fl_status = TRUE;
END;
$$;


ALTER FUNCTION questions.fn_get_question_id_simple(p_id bigint) OWNER TO postgres;

--
