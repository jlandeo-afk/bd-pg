-- Function: odiseo.fn_archived_question(integer, integer, integer, character varying, integer, character varying)

--

CREATE FUNCTION odiseo.fn_archived_question(p_perpage integer, p_npage integer, p_employee_id integer, p_name_text character varying, f_course_id integer, f_type character varying) RETURNS TABLE(key_question text, id bigint, code character varying, short_description text, number_question character varying, number character varying, course_id smallint, code_course character varying, course character varying, status character varying, fl_status boolean, parent_id bigint, type_question text, subquestions jsonb, created_by bigint, date_status timestamp without time zone, observation text, similitaries text, user_name character varying, user_email odiseo.email_citext, total bigint)
    LANGUAGE plpgsql
    AS $$
                                        DECLARE
                                            offset_val INTEGER := p_perpage * (p_npage - 1);
                                        BEGIN
                                            RETURN QUERY
                                            WITH employee_course AS (
                                                    SELECT ec.course_id
                                                    FROM employee_course ec
                                                    WHERE (p_employee_id IS NULL OR ec.teacher_id = p_employee_id)
                                                ),questions AS (
                                                select
                                                    concat('p_',q.id) as  key_question,
                                                    q.id,
                                                    q.code,
                                                    q.short_description,
                                                    q.number_question,
                                                    q.number,
                                                    q.course_id,
                                                    c.code AS code_course,
                                                    c.name AS course,
                                                    q.status,
                                                    q.fl_status,
                                                    q.parent_id,
                                                    CASE
                                                        WHEN q.parent_id IS NULL THEN 'P'
                                                        ELSE 'S'
                                                    END AS type_question,
                                                    q.created_by,
                                                    qs.created_at as date_status,
                                                    qo.description as observation,
                                                    qo.similitaries,
                                                    u.user AS user_name,
                                                    u.email AS user_email
                                                FROM question q
                                                INNER JOIN course c ON q.course_id = c.id
                                                LEFT JOIN users u ON q.created_by = u.id
                                                LEFT JOIN question_status qs ON q.id = qs.question_id AND q.status = qs.status AND qs.fl_active = true
                                                LEFT JOIN question_observation qo ON q.id = qo.question_id AND q.status = qo.type AND qo.fl_status = true
                                                WHERE q.status = 'ARCH'
                                                AND q.deleted_at IS NULL
                                            ),
                                            sub_questions AS (
                                                SELECT
                                                    pq.id AS parent_id,
                                                    jsonb_agg(
                                                        jsonb_build_object(
                                                            'key_question', concat('s_', q.id),
                                                            'id', q.id,
                                                            'code', q.code,
                                                            'short_description', q.short_description,
                                                            'number_question', q.number_question,
                                                            'number', q.number,
                                                            'course_id', q.course_id,
                                                            'code_course', c.code,
                                                            'course', c.name,
                                                            'status', q.status,
                                                            'fl_status', q.fl_status,
                                                            'parent_id',q.parent_id,
                                                            'type_question', 'S',
                                                            'created_by', q.created_by,
                                                            'date_status', qs.created_at,
                                                            'observation',qo.description,
                                                            'similitaries',qo.similitaries,
                                                            'user_name', u.user,
                                                            'user_email', u.email
                                                        )
                                                    ) AS subquestions
                                                FROM question q
                                                INNER JOIN course c ON q.course_id = c.id
                                                LEFT JOIN users u ON q.created_by = u.id
                                                LEFT JOIN question_status qs ON q.id = qs.question_id AND q.status = qs.status AND qs.fl_active = true
                                                LEFT JOIN question_observation qo ON q.id = qo.question_id AND q.status = qo.type AND qo.fl_status = true
                                                INNER JOIN parent_question pq ON q.parent_id = pq.id
                                                WHERE q.deleted_at IS null
                                                AND q.status = 'ARCH'
                                                GROUP BY pq.id
                                            ),
                                            tbl_question AS (
                                                SELECT
                                                    concat('p_', q.id) AS key_question,
                                                    q.id,
                                                    q.code,
                                                    q.short_description,
                                                    q.number_question,
                                                    q.number,
                                                    q.course_id,
                                                    q.code_course,
                                                    q.course,
                                                    q.status,
                                                    q.fl_status,
                                                    q.parent_id,
                                                    q.type_question,
                                                    COALESCE(sq.subquestions, '[]'::jsonb) AS subquestions,
                                                    q.created_by,
                                                    q.date_status,
                                                    q.observation,
                                                    q.similitaries,
                                                    q.user_name,
                                                    q.user_email
                                                FROM questions q
                                                LEFT JOIN sub_questions sq ON q.parent_id = sq.parent_id
                                                WHERE q.parent_id IS NULL
                                                UNION ALL
                                                SELECT DISTINCT
                                                    concat('t_', pq.id) AS key_question,
                                                    pq.id,
                                                    pq.code,
                                                    pq.short_description,
                                                    pq.number_question,
                                                    pq.number,
                                                    pq.course_id,
                                                    c.code AS code_course,
                                                    c.name AS course,
                                                    pq.status,
                                                    pq.fl_status,
                                                    pq.id as parent_id,
                                                    'T' AS type_question,
                                                    COALESCE(sq.subquestions, '[]'::jsonb) AS subquestions,
                                                    pq.created_by,
                                                    pq.created_at as date_status,
                                                    po.description  as observation,
                                                    po.similitaries,
                                                    u.user AS user_name,
                                                    u.email AS user_email
                                                FROM parent_question pq
                                                INNER JOIN course c ON pq.course_id = c.id
                                                LEFT JOIN users u ON pq.created_by = u.id
                                                LEFT JOIN sub_questions sq ON pq.id = sq.parent_id
                                                left join parent_observation po  on pq.id = po.parent_id
                                                WHERE pq.id = sq.parent_id
                                                AND pq.deleted_at IS NULL
                                            ),
                                            filtered_questions AS (
                                                SELECT *
                                                FROM tbl_question
                                                WHERE(f_course_id IS NULL OR tbl_question.course_id = f_course_id)
                                                AND (f_type IS NULL OR tbl_question.type_question = f_type)
                                                AND (p_employee_id IS NULL OR tbl_question.course_id IN (SELECT * FROM employee_course))
                                                AND (
                                                    p_name_text IS NULL
                                                    OR LOWER(unaccent(tbl_question.short_description)) ILIKE '%' || LOWER(p_name_text) || '%'
                                                    OR LOWER(tbl_question.number_question) LIKE '%' || LOWER(p_name_text) || '%'
                                                    OR LOWER(tbl_question.number) LIKE '%' || LOWER(p_name_text) || '%'
                                                    OR LOWER(tbl_question.code) LIKE '%' || LOWER(p_name_text) || '%'
                                                    OR EXISTS (
                                                        SELECT 1
                                                        FROM jsonb_array_elements(tbl_question.subquestions) AS sq
                                                        WHERE
                                                            LOWER(sq->>'short_description') ILIKE '%' || LOWER(p_name_text) || '%'
                                                            OR LOWER(sq->>'number_question') LIKE '%' || LOWER(p_name_text) || '%'
                                                            OR LOWER(sq->>'number') LIKE '%' || LOWER(p_name_text) || '%'
                                                            OR LOWER(sq->>'code') LIKE '%' || LOWER(p_name_text) || '%'
                                                    )
                                                )
                                            ),
                                            counted_questions AS (
                                                SELECT *, count(*) OVER () AS total
                                                FROM filtered_questions
                                            )
                                            SELECT *
                                            FROM counted_questions cq
                                            ORDER BY cq.date_status ASC, key_question ASC
                                            LIMIT p_perpage
                                            OFFSET offset_val;
                                        END;
                                    $$;


ALTER FUNCTION odiseo.fn_archived_question(p_perpage integer, p_npage integer, p_employee_id integer, p_name_text character varying, f_course_id integer, f_type character varying) OWNER TO postgres;

--
