-- Function: odiseo.fn_process_material_ballot_by_courses(bigint, jsonb)

--

CREATE FUNCTION odiseo.fn_process_material_ballot_by_courses(p_material_per_period_ballot_id bigint, p_courses jsonb) RETURNS TABLE(course_id smallint, detail_ids jsonb, week smallint, questions jsonb)
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
        ), courses AS (
            SELECT
                cgm.course_id
            FROM courses_generate_material cgm
            WHERE (p_courses IS NULL OR
                cgm.course_id = ANY (
                    SELECT value::SMALLINT FROM jsonb_array_elements_text(p_courses::jsonb)
                )
            )
        )
        SELECT
            c.course_id,
            d.detail_ids,
            d.week,
            q.questions
        FROM courses c
        CROSS JOIN details_weeks d
        CROSS JOIN LATERAL (
            SELECT jsonb_agg(row_to_json(t)) AS questions
            FROM fn_question_material_ballot_pdf(
                d.detail_ids::jsonb,
                c.course_id::int2
            ) t
        ) q;
    END;
    $$;


ALTER FUNCTION odiseo.fn_process_material_ballot_by_courses(p_material_per_period_ballot_id bigint, p_courses jsonb) OWNER TO postgres;

--
