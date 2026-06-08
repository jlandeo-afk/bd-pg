-- Function: odiseo.fn_get_exam_subquestions_per_text(bigint, smallint, smallint)

--

CREATE FUNCTION odiseo.fn_get_exam_subquestions_per_text(p_type_material_id bigint, p_course_id smallint, p_exam_area_id smallint) RETURNS TABLE(course_id smallint, exam_area_id smallint, subquestion_amount smallint, text_number smallint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        ttma.course_id AS course_id,
        ttma.exam_area_id AS exam_area_id,
        ttma.subquestion_amount AS subquestion_amount,
        ttma.position AS text_number
    FROM type_material tm
    LEFT JOIN type_text_material_type_course_area ttma ON tm.id = ttma.type_material_id
    WHERE 1 = 1
      AND tm.id = p_type_material_id
      AND ( p_course_id IS NULL OR ttma.course_id = p_course_id )
      AND ( p_exam_area_id IS NULL OR ttma.exam_area_id = p_exam_area_id )
      AND ttma.deleted_at IS NULL
    ORDER BY
        ttma.exam_area_id,
        ttma.course_id,
        ttma.position ASC;
END;
$$;


ALTER FUNCTION odiseo.fn_get_exam_subquestions_per_text(p_type_material_id bigint, p_course_id smallint, p_exam_area_id smallint) OWNER TO postgres;

--
