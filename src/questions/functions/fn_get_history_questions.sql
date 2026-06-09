-- Function: questions.fn_get_history_questions(integer)

--

CREATE FUNCTION questions.fn_get_history_questions(p_question_id integer) RETURNS TABLE(id bigint, status character varying, process character varying, description character varying, created_by text, created_at timestamp without time zone, image character varying)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    qs.id,
                    qs.status,
                    qs.process,
                    qs.description,
                    CASE
                        WHEN qs.created_by = 1 THEN 'SISTEMA'
                        ELSE concat(split_part(e.first_name, ' ', 1), ' ', upper(left(e.first_surname, 1)), '. ', e.second_surname)
                    END AS created_by,
                    qs.created_at,
                    u.image
                FROM
                    questions.question_status qs
                LEFT JOIN
                    auth.users u
                    ON qs.created_by = u.id
                LEFT JOIN
                    odiseo.employees e
                    ON e.user_id = u.id
                WHERE
                    qs.question_id = p_question_id
                ORDER BY qs.id DESC;
            END;
            $$;


ALTER FUNCTION questions.fn_get_history_questions(p_question_id integer) OWNER TO postgres;

--
