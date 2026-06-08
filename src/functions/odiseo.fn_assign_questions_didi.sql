-- Function: odiseo.fn_assign_questions_didi(integer, jsonb, integer, integer, bigint)

--

CREATE FUNCTION odiseo.fn_assign_questions_didi(p_employee_id integer, p_question_ids jsonb, p_week integer, p_year integer, p_created_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
            BEGIN
                INSERT INTO odiseo.employee_didi_question (employee_id, question_id, week, year, created_by, created_at)
                SELECT p_employee_id, value::bigint, p_week, p_year, p_created_by, now()
                FROM jsonb_array_elements(p_question_ids) AS value;
            END;
            $$;


ALTER FUNCTION odiseo.fn_assign_questions_didi(p_employee_id integer, p_question_ids jsonb, p_week integer, p_year integer, p_created_by bigint) OWNER TO postgres;

--
