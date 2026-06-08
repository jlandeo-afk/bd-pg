-- Function: odiseo.fn_group_didi_question(integer, integer)

--

CREATE FUNCTION odiseo.fn_group_didi_question(p_week integer, p_year integer) RETURNS TABLE(employee_id bigint, employee_name text, question_total numeric, questions json)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    e.id AS employeee_id,
                    CONCAT(split_part(e.first_name, ' ', 1), ' ', upper(left(e.first_surname, 1)), '. ', e.second_surname)  as employee_name,
                    COALESCE(SUM(eq.question_total), 0) AS question_total,
                    CASE
                        WHEN count(eq.employee_id) > 0 THEN json_agg(eq.*)
                        ELSE '[]'::json
                    END AS questions
                FROM
                    odiseo.employees e
                LEFT JOIN (
                    SELECT
                        eq.employee_id,
                        q.course_id,
                        COUNT(eq.question_id) AS question_total,
                        COALESCE(SUM(CASE WHEN eq.diagrammed = true THEN 1 ELSE 0 END), 0) AS diagrammed_total,
                        COALESCE(SUM(CASE WHEN eq.diagrammed = false THEN 1 ELSE 0 END), 0) AS not_diagrammed_total
                    FROM
                        odiseo.employee_didi_question eq
                    INNER JOIN odiseo.question q
                    ON q.id = eq.question_id AND q.fl_status = TRUE
                    WHERE
                        eq.week = p_week AND eq.year = p_year AND eq.fl_status = TRUE AND eq.deleted_at IS NULL
                    GROUP BY
                        eq.employee_id, q.course_id
                    ORDER BY question_total ASC
                ) eq
                ON eq.employee_id = e.id
                WHERE e.charge_id = 3
                AND	e.fl_status = true
                AND e.gpt = false
                GROUP BY
                    e.id
                ORDER BY
                    question_total ASC,
                    e.id ASC;
            END;
            $$;


ALTER FUNCTION odiseo.fn_group_didi_question(p_week integer, p_year integer) OWNER TO postgres;

--
