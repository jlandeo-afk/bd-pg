-- Function: odiseo.get_limit_question_by_didi(integer, integer, integer)

--

CREATE FUNCTION odiseo.get_limit_question_by_didi(p_week integer, p_year integer, p_didi_id integer) RETURNS TABLE(id bigint, assign_counts jsonb, name text, limit_general integer, start_week date, end_week date, total_courses bigint, courses_assigned jsonb)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT e.id,
                (
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'course_id', sub.course_id,
                            'total_dasi', sub.total_dasi,
                            'total_digi_by_week', sub.total_digi_by_week,
                            'course_name', sub.course_name,
                            'limit_question',  (SELECT as2.limit_assigned_questions_didi FROM odiseo.advanced_settings as2 WHERE as2.fl_status = true LIMIT 1)
                        )
                    )
                    FROM (
                        SELECT
                            q.course_id,
                            c.name as course_name,
                            COUNT(CASE
                                WHEN q.status = 'DASI'
                                THEN 1
                            END) AS total_dasi,
                            COUNT(CASE
                                WHEN EXTRACT(WEEK FROM qs.created_at) = p_week AND EXTRACT(YEAR FROM qs.created_at) = p_year
                                AND (q.status = 'DIGI' OR qs.status = 'DIGI')
                                THEN 1
                            END) AS total_digi_by_week
                        FROM
                            odiseo.employee_didi_question dq
                        JOIN
                            odiseo.question q ON q.id = dq.question_id
                       	LEFT JOIN
				        (
				            SELECT DISTINCT ON (qs.question_id) qs.question_id, qs.status, qs.created_at
				            FROM odiseo.question_status qs
				            WHERE qs.status = 'DIGI'
				            ORDER BY qs.question_id, qs.created_at DESC
				        ) AS qs ON qs.question_id = q.id
                        JOIN
                            odiseo.course c ON c.id = q.course_id
                        WHERE
                            dq.employee_id = e.id
							and dq.fl_status = true
                        GROUP BY
                            q.course_id,
                            c.name
                    ) sub
                ) AS assign_counts,
                CONCAT(SPLIT_PART(e.first_name, ' ', 1), ' ', UPPER(LEFT(e.first_surname, 1)), '. ', e.second_surname)  as name,
                (SELECT as2.limit_assigned_questions_didi FROM odiseo.advanced_settings as2 WHERE as2.fl_status = true LIMIT 1) limit_general,
                DATE_TRUNC('week', current_date)::DATE AS start_week,
                (DATE_TRUNC('week', current_date) + INTERVAL '6 days')::DATE AS end_week,
                COUNT(ec.*) total_courses,
				JSONB_AGG(
					JSONB_BUILD_OBJECT(
						'course_id', ec.course_id,
						'course_name', c.name
					)
				) courses_assigned
                FROM
                    odiseo.employees e
                JOIN
                    odiseo.employee_course ec ON e.id = ec.teacher_id
				JOIN 
					odiseo.course c ON c.id = ec.course_id
                WHERE
                e.fl_status = true
                    AND ec.fl_status = true
                    AND e.charge_id = 3
                    AND e.gpt = false
                AND e.id = p_didi_id
                GROUP BY e.id;
            END;
        $$;


ALTER FUNCTION odiseo.get_limit_question_by_didi(p_week integer, p_year integer, p_didi_id integer) OWNER TO postgres;

--
