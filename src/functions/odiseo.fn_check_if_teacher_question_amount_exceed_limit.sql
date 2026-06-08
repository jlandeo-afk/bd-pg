-- Function: odiseo.fn_check_if_teacher_question_amount_exceed_limit(character varying, integer, integer)

--

CREATE FUNCTION odiseo.fn_check_if_teacher_question_amount_exceed_limit(p_question_status character varying, p_teacher_id integer, p_question_amount_limit integer) RETURNS TABLE(exceed_limit boolean, question_amount_to_fill integer)
    LANGUAGE plpgsql
    AS $$

            DECLARE question_amount INTEGER;
            DECLARE exceed_limit BOOLEAN;
            DECLARE question_amount_to_fill INTEGER;

            BEGIN
                SELECT
                    COUNT(*)
                INTO question_amount
                FROM odiseo.employee_question eq
                JOIN odiseo.question q ON eq.question_id = q.id
                JOIN odiseo.employees e ON e.id = eq.teacher_id
                WHERE 1 = 1
                  AND e.user_id = p_teacher_id
                  AND eq.fl_status IS TRUE
                  AND eq.deleted_at IS NULL
                  AND q.fl_status IS TRUE
                  And q.deleted_at IS NULL
                  AND q.status = p_question_status;

                exceed_limit := question_amount >= p_question_amount_limit;
                question_amount_to_fill := p_question_amount_limit - question_amount;

                RETURN QUERY
                SELECT exceed_limit, question_amount_to_fill;
            END;
            $$;


ALTER FUNCTION odiseo.fn_check_if_teacher_question_amount_exceed_limit(p_question_status character varying, p_teacher_id integer, p_question_amount_limit integer) OWNER TO postgres;

--
