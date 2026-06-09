-- Function: academic.fn_get_course_categories(bigint)

--

CREATE FUNCTION academic.fn_get_course_categories(p_course_id bigint) RETURNS TABLE(id bigint, category_name character varying, category_assigned_id bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT t.id, t.name AS category_name, c.id AS category_assigned_id
    FROM course_assigned_categories c
    JOIN type_text t ON c.type_text_id = t.id
    WHERE c.course_id = p_course_id AND c.deleted_at IS NULL;
END;
$$;


ALTER FUNCTION academic.fn_get_course_categories(p_course_id bigint) OWNER TO postgres;

--
