-- Function: odiseo.fn_list_eligible_teachers_for_missing_questions()

--

CREATE FUNCTION odiseo.fn_list_eligible_teachers_for_missing_questions() RETURNS TABLE(employee_id integer, limit_missing_questions integer, teacher_name text, courses json)
    LANGUAGE plpgsql STABLE
    AS $$
            BEGIN
                RETURN QUERY
                WITH active_eligible_teachers AS (
                    SELECT 
                        t.employee_id,
                        t.limit_missing_questions,
                        TRIM(CONCAT_WS(' ', e.first_name, e.first_surname, e.second_surname)) AS teacher_name,
                        e.first_name,
                        e.first_surname,
                        e.second_surname
                    FROM teachers t
                    JOIN employees e ON e.id = t.employee_id
                    JOIN users u ON u.id = e.user_id
                    WHERE t.fl_active = true
                      AND e.fl_status = true
                      AND t.fl_resolve_missing_questions = true
                      AND u.fl_status = true
                      AND u.fl_suspended = false
                      AND u.deleted_at IS NULL
                ),
                eligible_courses AS (
                    SELECT 
                        ec.teacher_id, 
                        ec.course_id
                    FROM employee_course ec
                    JOIN active_eligible_teachers aet ON aet.employee_id = ec.teacher_id
                    WHERE ec.fl_status = true 
                      AND ec.deleted_at IS NULL
                      AND NOT EXISTS (
                          SELECT 1
                          FROM material_missing_question_detail mmqd
                          JOIN material_ballot_question mdbq 
                            ON mdbq.id = mmqd.material_ballot_question_id
                          WHERE mmqd.employee_id = ec.teacher_id
                            AND mmqd.question_id IS NULL
                            AND mmqd.deleted_at IS NULL
                            AND mdbq.course_id = ec.course_id
                      )
                ),
                teacher_courses AS (
                    SELECT 
                        ec.teacher_id, 
                        json_agg(ec.course_id) AS courses_array
                    FROM eligible_courses ec
                    GROUP BY ec.teacher_id
                ),
                tracking_summary AS (
                    SELECT 
                        trk.employee_id, 
                        MAX(trk.created_at) AS last_assigned_at
                    FROM material_missing_question_tracking trk
                    WHERE trk.action = 'assigned'
                    GROUP BY trk.employee_id
                )
                SELECT
                    aet.employee_id::integer,
                    aet.limit_missing_questions::integer,
                    aet.teacher_name::text,
                    tc.courses_array::json AS courses
                FROM active_eligible_teachers aet
                JOIN teacher_courses tc ON tc.teacher_id = aet.employee_id
                LEFT JOIN tracking_summary ts ON ts.employee_id = aet.employee_id
                ORDER BY ts.last_assigned_at ASC NULLS FIRST,
                         aet.first_name ASC,
                         aet.first_surname ASC,
                         aet.second_surname ASC;
            END;
            $$;


ALTER FUNCTION odiseo.fn_list_eligible_teachers_for_missing_questions() OWNER TO postgres;

--
