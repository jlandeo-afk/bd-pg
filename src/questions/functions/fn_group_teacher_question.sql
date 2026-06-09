-- Function: questions.fn_group_teacher_question(integer, integer)

--

CREATE FUNCTION questions.fn_group_teacher_question(p_week integer, p_year integer) RETURNS TABLE(teacher_id bigint, teacher_name text, question_total numeric, questions json, limit_assigned_questions smallint, fl_unlimit_questions boolean, lot smallint, past_unresolved_questions bigint)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
            WITH base_data (id, teacher_id, course_id, solved, parent_id) AS (
                SELECT
                    eq.id,
                    eq.teacher_id,
                    q.course_id,
                    eq.solved,
                    q.parent_id
                FROM employee_question AS eq
                INNER JOIN question AS q ON q.id = eq.question_id AND q.fl_status = TRUE
                WHERE
                    eq.week = p_week
                    AND eq.year = p_year
                    AND eq.fl_status = TRUE
                    AND eq.deleted_at IS NULL
                    AND q.status != 'DUPL'
            ), question_unresolved (teacher_id, past_unresolved_questions) AS (
                SELECT
                    eq.teacher_id,
                    COALESCE(COUNT(eq.*), 0) AS past_unresolved_questions
                FROM employee_question AS eq
                INNER JOIN question AS q ON q.id = eq.question_id AND q.fl_status = TRUE
                WHERE
                    eq.id NOT IN (SELECT bd.id FROM base_data bd)
                    AND (eq.solved = false OR q.status = 'RECH')
                    AND eq.fl_status = TRUE
                    AND eq.deleted_at IS NULL
                    AND q.status in ('ASIG','RESO','INDE','RECH')
                GROUP BY eq.teacher_id
            ), normal_questions (teacher_id, course_id, question_total, solved_total, unsolved_total) AS (
                SELECT
                    bd.teacher_id,
                    bd.course_id,
                    COUNT(*),
                    COALESCE(SUM(CASE WHEN bd.solved = true THEN 1 ELSE 0 END), 0),
                    COALESCE(SUM(CASE WHEN bd.solved = false THEN 1 ELSE 0 END), 0)
                FROM base_data AS bd
                WHERE bd.parent_id IS NULL
                GROUP BY
                    bd.teacher_id,
                    bd.course_id
            ), parent_question_logic (teacher_id, course_id, parent_id, sub_unsolved_count) AS (
                SELECT
                    bd.teacher_id,
                    bd.course_id,
                    bd.parent_id,
                    COALESCE(SUM(CASE WHEN bd.solved = false THEN 1 ELSE 0 END), 0)
                FROM base_data AS bd
                WHERE bd.parent_id IS NOT NULL
                GROUP BY
                    bd.teacher_id,
                    bd.course_id,
                    bd.parent_id
            ), parent_questions_agg (teacher_id, course_id, question_total, solved_total, unsolved_total) AS (
                SELECT
                    pql.teacher_id,
                    pql.course_id,
                    COUNT(pql.parent_id),
                    COALESCE(SUM(CASE WHEN pql.sub_unsolved_count = 0 THEN 1 ELSE 0 END), 0),
                    COALESCE(SUM(CASE WHEN pql.sub_unsolved_count > 0 THEN 1 ELSE 0 END), 0)
                FROM parent_question_logic AS pql
                GROUP BY
                    pql.teacher_id,
                    pql.course_id
            ), employee_question_summary (teacher_id, course_id, question_total, solved_total, unsolved_total) AS (
                SELECT
                    teacher_all.teacher_id,
                    teacher_all.course_id,
                    SUM(teacher_all.question_total),
                    SUM(teacher_all.solved_total),
                    SUM(teacher_all.unsolved_total)
                FROM (
                    SELECT nq.* FROM normal_questions AS nq
                    UNION ALL
                    SELECT pqa.* FROM parent_questions_agg AS pqa
                ) AS teacher_all
                GROUP BY
                    teacher_all.teacher_id,
                    teacher_all.course_id
            )
            SELECT
                e.id AS teacher_id,
                CONCAT(split_part(e.first_name, ' ', 1), ' ', upper(left(e.first_surname, 1)), '. ', e.second_surname) as teacher_name,
                COALESCE(SUM(eq.question_total), 0) AS question_total,
                CASE
                    WHEN count(eq.teacher_id) > 0 THEN json_agg(eq.* ORDER BY eq.course_id)
                    ELSE '[]'::json
                END AS questions,
                e.limit_assigned_questions,
                e.fl_unlimit_questions,
                e.lot,
                COALESCE(qi.past_unresolved_questions, 0) AS past_unresolved_questions
            FROM employees AS e
            LEFT JOIN employee_question_summary AS eq ON eq.teacher_id = e.id
            LEFT JOIN question_unresolved qi ON e.id = qi.teacher_id
            WHERE e.charge_id = 2
                AND e.fl_status = true
                AND e.gpt = false
            GROUP BY e.id, qi.past_unresolved_questions
            ORDER BY
                question_total ASC,
                e.id ASC;
        END;
        $$;


ALTER FUNCTION questions.fn_group_teacher_question(p_week integer, p_year integer) OWNER TO postgres;

--
