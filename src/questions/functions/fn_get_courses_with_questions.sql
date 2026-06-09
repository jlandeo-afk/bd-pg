-- Function: questions.fn_get_courses_with_questions(bigint, jsonb)

--

CREATE FUNCTION questions.fn_get_courses_with_questions(p_material_per_period_ballot_id bigint, p_courses jsonb) RETURNS TABLE(id smallint, name character varying)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        WITH details_weeks AS (
            SELECT dw.week, dw.detail_ids
            FROM fn_get_available_weeks_per_period(p_material_per_period_ballot_id) dw
        ), courses_generate_material AS (
            SELECT DISTINCT
                mbq.course_id
            FROM detail_week_type_mat dwtm
            JOIN details_weeks dw
                ON dwtm.id = ANY (
                    SELECT value::BIGINT
                    FROM jsonb_array_elements_text(dw.detail_ids::jsonb) value
                )
            JOIN material_ballot_question mbq ON dwtm.id = mbq.week_type_material_id
                AND mbq.fl_status = true
        )
        SELECT
            cgm.course_id AS id,
            c.name
        FROM courses_generate_material cgm
        JOIN course c ON cgm.course_id = c.id
        WHERE (p_courses IS NULL OR
            cgm.course_id = ANY (
                SELECT value::SMALLINT FROM jsonb_array_elements_text(p_courses::jsonb)
            )
        );
    END;
    $$;


ALTER FUNCTION questions.fn_get_courses_with_questions(p_material_per_period_ballot_id bigint, p_courses jsonb) OWNER TO postgres;

--
