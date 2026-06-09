-- Function: questions.fn_assigned_question(integer, integer, character varying, character varying, integer, character varying, integer, integer, smallint, smallint, smallint, integer, character varying)

--

CREATE FUNCTION questions.fn_assigned_question(p_perpage integer, p_npage integer, p_name_text character varying, p_status character varying, p_course_id integer, p_type character varying, p_teacher_id integer, p_user_id integer, p_university_id smallint, p_option_id smallint, p_modality_id smallint, p_version integer, p_year character varying) RETURNS TABLE(key_question text, id bigint, code character varying, short_description text, number_question character varying, number character varying, course_id smallint, code_course character varying, course character varying, status character varying, fl_status boolean, parent_id bigint, teacher_id bigint, code_teacher character varying, teacher text, type_question text, subquestions jsonb, created_by bigint, date_status timestamp without time zone, user_name character varying, user_email odiseo.email_citext, total_refuzed bigint, origin_question jsonb, priority integer, is_missing_question boolean, total bigint)
    LANGUAGE plpgsql
    AS $$
                        DECLARE
                            C_MORE_RECENT_VERSION SMALLINT DEFAULT 1;
                            offset_val INTEGER := p_perpage * (p_npage - 1);
                            status_array varchar[];
                        begin
                            IF p_status IS NULL OR p_status = '' OR p_status NOT IN ('ASIG', 'RESO', 'SSOL') THEN
                                status_array := ARRAY['ASIG', 'RESO', 'SSOL'];
                            ELSE
                                status_array := ARRAY[p_status];
                            END IF;
                            RETURN QUERY
                            WITH questions AS (
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
                                    e.id as teacher_id,
                                    e.code AS code_teacher,
                                    CONCAT(e.first_surname,' ', e.second_surname,' ', e.first_name) AS teacher,
                                    CASE
                                        WHEN q.parent_id IS NULL THEN 'P'
                                        ELSE 'S'
                                    END AS type_question,
                                    qs.created_by,
                                    qs.created_at as date_status,
                                    u.user AS user_name,
                                    u.email AS user_email,
                                    (
                                        SELECT COUNT(*)
                                        FROM question_refuzed qr2
                                        WHERE qr2.question_id = q.id
                                        AND qr2.fl_status = true
                                    ) AS total_refuzed,
                                    qn.question_origin,
                                    q.priority,
                                    CASE
                                        WHEN mmqd.question_id IS NOT NULL THEN true
                                        ELSE false
                                    END AS is_missing_question
                                from employee_question eq
                                inner join question q  on eq.question_id = q.id
                                LEFT JOIN v_all_question_origins qn ON qn.question_id = q.id
                                left join course c on q.course_id = c.id
                                left join employees e on eq.teacher_id = e.id
                                LEFT JOIN users u ON eq.created_by = u.id
                                LEFT JOIN users usercreated ON q.created_by = usercreated.id
                                LEFT JOIN question_status qs ON q.id = qs.question_id AND q.status = qs.status AND qs.fl_active = true
                                LEFT JOIN material_missing_question_detail mmqd ON mmqd.question_id = q.id
                                where q.deleted_at IS null
                                AND q.fl_status = true
                                and eq.fl_status = true
                                AND q.status = ANY(ARRAY[status_array])
                                AND (p_teacher_id IS NULL OR e.id = p_teacher_id)
                                AND (p_user_id IS NULL OR usercreated.id = p_user_id)
                                AND ( p_university_id IS NULL OR qn.university_id = p_university_id )
                                AND ( p_option_id IS NULL OR qn.option_id = p_option_id )
                                AND ( p_modality_id IS NULL OR qn.modality_id = p_modality_id )
                                AND ( p_version IS NULL OR qn."version" = p_version )
                                AND ( p_year IS NULL OR qn."year" = p_year )
                            ), sub_questions AS (
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
                                            'teacher_id',e.id,
                                            'code_teacher',e.code,
                                            'teacher', CONCAT(e.first_surname,' ', e.second_surname,' ', e.first_name),
                                            'type_question', 'S',
                                            'created_by', qs.created_by,
                                            'date_status', qs.created_at,
                                            'user_name', u.user,
                                            'user_email', u.email,
                                            'origin_question', qn.question_origin,
                                            'total_refuzed', (
                                                SELECT COUNT(*)
                                                FROM question_refuzed qr
                                                WHERE qr.question_id = q.id
                                                AND qr.fl_status = true
                                            )
                                        )
                                    ) AS subquestions
                                from employee_question eq
                                inner join question q  on eq.question_id = q.id
                                LEFT JOIN v_all_question_origins qn ON qn.question_id = q.id
                                left join course c on q.course_id = c.id
                                left join employees e on eq.teacher_id = e.id
                                LEFT JOIN users u ON eq.created_by = u.id
                                LEFT JOIN users usercreated ON q.created_by = usercreated.id
                                LEFT JOIN question_status qs ON q.id = qs.question_id AND q.status = qs.status AND qs.fl_active = true
                                INNER JOIN parent_question pq ON q.parent_id = pq.id AND pq.status <> 'DUPL'
                                WHERE q.deleted_at IS null
                                and eq.fl_status = true
                                AND q.status = ANY(ARRAY[status_array])
                                AND (p_teacher_id IS NULL OR e.id = p_teacher_id)
                                AND (p_user_id IS NULL OR usercreated.id = p_user_id)
                                AND ( p_university_id IS NULL OR qn.university_id = p_university_id )
                                AND ( p_option_id IS NULL OR qn.option_id = p_option_id )
                                AND ( p_modality_id IS NULL OR qn.modality_id = p_modality_id )
                                AND ( p_version IS NULL OR qn."version" = p_version )
                                AND ( p_year IS NULL OR qn."year" = p_year )
                                GROUP BY pq.id
                            ), tbl_question AS (
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
                                    q.teacher_id,
                                    q.code_teacher,
                                    q.teacher,
                                    q.type_question,
                                    COALESCE(sq.subquestions, '[]'::jsonb) AS subquestions,
                                    q.created_by,
                                    q.date_status,
                                    q.user_name,
                                    q.user_email,
                                    q.total_refuzed,
                                    q.question_origin,
                                    q.priority,
                                    q.is_missing_question
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
                                    pq.id AS parent_id,
                                    -1 AS teacher_id,
                                    '' AS code_teacher,
                                    '' AS teacher,
                                    'T' AS type_question,
                                    COALESCE(sq.subquestions, '[]'::jsonb) AS subquestions,
                                    pq.created_by,
                                    pq.created_at  as date_status,
                                    u.user AS user_name,
                                    u.email AS user_email,
                                    0::BIGINT AS total_refuzed,
                                    opq.question_origin,
                                    pq.priority,
                                    false AS is_missing_question
                                FROM parent_question pq
                                INNER JOIN course c ON pq.course_id = c.id
                                LEFT JOIN users u ON pq.created_by = u.id
                                INNER JOIN sub_questions sq ON pq.id = sq.parent_id and sq.parent_id is not  null
                                LEFT JOIN v_all_parent_origins opq ON opq.parent_id = pq.id
                                WHERE pq.id = sq.parent_id
                                AND pq.deleted_at IS NULL
                                AND pq.status <> 'DUPL'
                                AND (sq.subquestions <> '[]')
                                AND ( p_university_id IS NULL OR opq.university_id = p_university_id )
                                AND ( p_option_id IS NULL OR opq.option_id = p_option_id )
                                AND ( p_modality_id IS NULL OR opq.modality_id = p_modality_id )
                                AND ( p_version IS NULL OR opq."version" = p_version )
                                AND ( p_year IS NULL OR opq."year" = p_year )
                            ), filtered_questions AS (
                                SELECT *
                                FROM tbl_question
                                WHERE(p_course_id IS NULL OR tbl_question.course_id = p_course_id)
                                AND (p_type IS NULL OR tbl_question.type_question = p_type)
                                AND (
                                    p_name_text IS NULL
                                    OR unaccent(LOWER(tbl_question.short_description)) LIKE '%' || LOWER(p_name_text) || '%'
                                    OR LOWER(tbl_question.number_question) LIKE '%' || LOWER(p_name_text) || '%'
                                    OR LOWER(tbl_question.number) LIKE '%' || LOWER(p_name_text) || '%'
                                    OR LOWER(tbl_question.code) LIKE '%' || LOWER(p_name_text) || '%'
                                    OR EXISTS (
                                        SELECT 1
                                        FROM jsonb_array_elements(tbl_question.subquestions) AS sq
                                        WHERE
                                            unaccent(LOWER(sq->>'short_description')) LIKE '%' || LOWER(p_name_text) || '%'
                                            OR LOWER(sq->>'number_question') LIKE '%' || LOWER(p_name_text) || '%'
                                            OR LOWER(sq->>'number') LIKE '%' || LOWER(p_name_text) || '%'
                                            OR LOWER(sq->>'code') LIKE '%' || LOWER(p_name_text) || '%'
                                        )
                                    )
                            ), counted_questions AS (
                                SELECT *, count(*) OVER () AS total
                                FROM filtered_questions
                            )
                            SELECT
                                *
                            FROM counted_questions AS cq
                            ORDER BY
                                priority DESC,
                                CASE
                                    WHEN cq.status = 'RESO' THEN 2
                                    WHEN cq.status = 'SSOL' THEN 3
                                    WHEN cq.status = 'ASIG' THEN 4
                                    ELSE 5
                                END,
                                CASE
                                    WHEN cq.status = 'RESO' THEN cq.date_status
                                    ELSE NULL
                                END ASC,
                                CASE
                                    WHEN cq.status = 'SSOL' THEN cq.date_status
                                    ELSE NULL
                                END ASC,
                                CASE
                                    WHEN cq.status = 'ASIG' THEN cq.date_status
                                    ELSE NULL
                                END ASC,
                                id ASC,
                                date_status ASC, key_question ASC
                            LIMIT p_perpage
                            OFFSET offset_val;
                    END;
                    $$;


ALTER FUNCTION questions.fn_assigned_question(p_perpage integer, p_npage integer, p_name_text character varying, p_status character varying, p_course_id integer, p_type character varying, p_teacher_id integer, p_user_id integer, p_university_id smallint, p_option_id smallint, p_modality_id smallint, p_version integer, p_year character varying) OWNER TO postgres;

--
