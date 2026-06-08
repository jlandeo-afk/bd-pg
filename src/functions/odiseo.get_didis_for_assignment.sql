-- Function: odiseo.get_didis_for_assignment(integer, integer, integer)

--

CREATE FUNCTION odiseo.get_didis_for_assignment(p_week integer, p_year integer, p_course_id integer) RETURNS TABLE(id bigint, assign_counts jsonb, name text)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        SELECT
            e.id,
            (
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'course_id', sub.course_id,
                        'question_count', sub.question_count
                    )
                )
                FROM (
                    SELECT
                        q.course_id,
                        COUNT(CASE WHEN q.status = 'DASI' THEN 1 END) AS question_count
                    FROM employee_didi_question dq
                    JOIN question q ON q.id = dq.question_id
                    WHERE dq.employee_id = e.id
                    GROUP BY q.course_id
                ) sub
            ) AS assign_counts,
            CONCAT(split_part(e.first_name, ' ', 1), ' ', upper(left(e.first_surname, 1)), '. ', e.second_surname)  as name
        FROM employees e
        JOIN employee_course ec ON e.id = ec.teacher_id
        JOIN users u ON e.user_id = u.id
            AND u.fl_suspended = false
            AND u.fl_status = true
        WHERE ec.course_id = p_course_id
            AND e.fl_status = true
            AND ec.fl_status = true
            AND e.charge_id = 3
            AND e.gpt = false;
    END;
    $$;


ALTER FUNCTION odiseo.get_didis_for_assignment(p_week integer, p_year integer, p_course_id integer) OWNER TO postgres;

--
