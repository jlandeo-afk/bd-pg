-- Function: questions.fn_get_available_missing_questions_count()

--

CREATE FUNCTION questions.fn_get_available_missing_questions_count() RETURNS integer
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN (
        SELECT COUNT(id)::integer
        FROM material_missing_question_detail
        WHERE employee_id IS NULL
          AND question_id IS NULL
          AND status = 'pending'
          AND deleted_at IS NULL
    );
END;
$$;


ALTER FUNCTION questions.fn_get_available_missing_questions_count() OWNER TO postgres;

--
