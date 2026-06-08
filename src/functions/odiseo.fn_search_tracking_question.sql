-- Function: odiseo.fn_search_tracking_question(integer, integer, character varying, integer, integer, integer, character varying, integer, character varying, smallint, smallint, smallint, smallint, character varying)

--

CREATE FUNCTION odiseo.fn_search_tracking_question(p_perpage integer, p_npage integer, p_name_text character varying, p_course_id integer, p_teacher_id integer, p_employee_didi_id integer, p_status character varying, p_created_by integer, p_type character varying, p_university_id smallint, p_option_id smallint, p_modality_id smallint, p_version smallint, p_year character varying) RETURNS TABLE(id bigint, key_question text, type_question text, parent_id bigint, code character varying, number_question character varying, short_description text, course_id smallint, course character varying, subtopic_id bigint, topic_id bigint, area_id bigint, area character varying, subquestions jsonb, status character varying, date_status timestamp without time zone, created_at timestamp without time zone, created_by_id bigint, created_by text, teacher_id bigint, teacher text, employee_didi_id bigint, employee_didi text, origin_question jsonb, search_text text, user_deleted_at timestamp without time zone, user_suspended boolean, shared_status text, total_count bigint)
    LANGUAGE plpgsql
    SET jit TO 'off'
    AS $$
DECLARE
    offset_val INTEGER := p_perpage * (p_npage - 1);
BEGIN
    RETURN QUERY
    with questions AS (
        SELECT
            concat('p_',q.id) as  key_question,
            q.id,
            q.code,
            q.short_description,
            q.number_question,
            q.number,
            q.course_id,
            c.code AS code_course,
            c.name AS course,
            qs.subtopic_id,
            q.topic_id,
            a.id as area_id,
            a.description as area,
            q.status,
            q.fl_status,
            q.parent_id,
            CASE
                WHEN q.parent_id IS NULL THEN 'P'
                ELSE 'S'
            END AS type_question,
            q.created_by,
            q.status_changed_at created_at,
            u.user AS user_name,
            u.email AS user_email,
            e.id as employee_id,
            CONCAT(e.first_surname,' ', e.second_surname,' ', e.first_name) AS name_employee,
            e1.id as teacher_id,
            CONCAT(e1.first_surname,' ', e1.second_surname,' ', e1.first_name) AS teacher,
            e2.id as employee_didi_id,
            CONCAT(e2.first_surname,' ', e2.second_surname,' ', e2.first_name) AS employee_didi,
            q.search_text,
            u.deleted_at as user_deleted_at,
            u.fl_suspended as user_suspended,
            get_shared_status(q.id, qs.subtopic_id) AS shared_status,
            qn.question_origin,
            qn.university_id,
            qn.option_id,
            qn.modality_id,
            qn."version",
            qn."year"
        FROM question q
        INNER JOIN course c ON q.course_id = c.id
        LEFT JOIN area a ON c.area_id = a.id
        LEFT JOIN users u ON q.created_by = u.id
        LEFT JOIN employees e on u.id = e.user_id
        LEFT JOIN employee_question eoq ON eoq.question_id = q.id AND eoq.fl_status = true
        LEFT JOIN employees e1 ON eoq.teacher_id = e1.id
        LEFT JOIN employee_didi_question oedq ON q.id = oedq.question_id AND oedq.fl_status = true
        LEFT JOIN employees e2 ON oedq.employee_id = e2.id
        LEFT JOIN question_subtopic qs ON qs.question_id = q.id
        LEFT JOIN v_all_question_origins qn ON qn.question_id = q.id
        WHERE 1 = 1
            AND q.fl_status = true
            AND q.deleted_at IS NULL
            AND q.code IS NOT NULL
            AND q.status <> 'ARCH'
            AND ( p_university_id IS NULL OR qn.university_id = p_university_id )
            AND ( p_option_id IS NULL OR qn.option_id = p_option_id )
            AND ( p_modality_id IS NULL OR qn.modality_id = p_modality_id )
            AND ( p_version IS NULL OR qn."version" = p_version )
            AND ( p_year IS NULL OR qn."year" = p_year )
            AND ( p_name_text IS NULL OR q.search_text LIKE '%' || p_name_text || '%' )
            AND (p_course_id IS NULL OR q.course_id = p_course_id)
            AND (p_status IS NULL OR q.status = p_status)
            AND (p_employee_didi_id is null or e2.id = p_employee_didi_id)

        UNION ALL

        SELECT
            concat('p_',q.id) as  key_question,
            q.id,
            qsh.code,
            q.short_description,
            q.number_question,
            q.number,
            c.id as course_id,
            c.code AS code_course,
            c.name AS course,
            qsh.subtopic_id,
            qsh.topic_id,
            a.id as area_id,
            a.description as area,
            q.status,
            q.fl_status,
            q.parent_id,
            CASE
                WHEN q.parent_id IS NULL THEN 'P'
                ELSE 'S'
            END AS type_question,
            q.created_by,
            q.status_changed_at created_at,
            u.user AS user_name,
            u.email AS user_email,
            e.id as employee_id,
            CONCAT(e.first_surname,' ', e.second_surname,' ', e.first_name) AS name_employee,
            e1.id as teacher_id,
            CONCAT(e1.first_surname,' ', e1.second_surname,' ', e1.first_name) AS teacher,
            e2.id as employee_didi_id,
            CONCAT(e2.first_surname,' ', e2.second_surname,' ', e2.first_name) AS employee_didi,
            q.search_text,
            u.deleted_at as user_deleted_at,
            u.fl_suspended as user_suspended,
            get_shared_status(q.id, qsh.subtopic_id) AS shared_status,
            qn.question_origin,
            qn.university_id,
            qn.option_id,
            qn.modality_id,
            qn."version",
            qn."year"
        FROM question q
        LEFT JOIN users u ON q.created_by = u.id
        LEFT JOIN employees e on u.id = e.user_id
        LEFT JOIN employee_question eoq ON eoq.question_id = q.id AND eoq.fl_status = true
        LEFT JOIN employees e1 ON eoq.teacher_id = e1.id
        LEFT JOIN employee_didi_question oedq ON q.id = oedq.question_id AND oedq.fl_status = true
        LEFT JOIN employees e2 ON oedq.employee_id = e2.id
        INNER JOIN question_shares qsh ON qsh.question_id = q.id AND qsh.deleted_at IS NULL
        LEFT JOIN subtopic st ON qsh.subtopic_id = st.id
        LEFT JOIN topic t ON qsh.topic_id = t.id
        LEFT JOIN course c ON c.id = t.course_id
        LEFT JOIN area a ON c.area_id = a.id
        LEFT JOIN v_all_question_origins qn ON qn.question_id = q.id
        WHERE 1 = 1
            AND q.fl_status = true
            AND q.deleted_at IS NULL
            AND qsh.code IS NOT NULL
            AND q.status <> 'ARCH'
            AND ( p_university_id IS NULL OR qn.university_id = p_university_id )
            AND ( p_option_id IS NULL OR qn.option_id = p_option_id )
            AND ( p_modality_id IS NULL OR qn.modality_id = p_modality_id )
            AND ( p_version IS NULL OR qn."version" = p_version )
            AND ( p_year IS NULL OR qn."year" = p_year )
            AND ( p_name_text IS NULL OR qsh.code LIKE '%' || p_name_text || '%' OR q.search_text LIKE '%' || p_name_text || '%' )
            AND (p_course_id IS NULL OR t.course_id = p_course_id)
            AND (p_status IS NULL OR q.status = p_status)
            AND (p_employee_didi_id is null or e2.id = p_employee_didi_id)

    ), sub_questions AS (
        SELECT
            pq.id AS parent_id,
            JSONB_AGG(
                JSONB_BUILD_OBJECT(
                    'id', q.id,
                    'key_question', CONCAT('s_', q.id),
                    'type_question', 'S',
                    'parent_id', q.parent_id,
                    'code', q.code,
                    'number_question', q.number_question,
                    'short_description', q.short_description,
                    'course_id', q.course_id,
                    'course', c.name,
                    'area_id', a.id,
                    'area', a.description,
                    'status', q.status,
                    'date_status', q.status_changed_at,
                    'created_at', q.created_at,
                    'created_by_id', q.created_by,
                    'created_by', CONCAT(e.first_surname, ' ', e.second_surname, ' ', e.first_name),
                    'teacher_id', e1.id,
                    'teacher', CONCAT(e1.first_surname, ' ', e1.second_surname, ' ', e1.first_name),
                    'employee_didi_id', e2.id,
                    'employee_didi', CONCAT(e2.first_surname, ' ', e2.second_surname, ' ', e2.first_name),
                    'origin_question', qn.question_origin
                )
            ) AS subquestions
        FROM question q
        INNER JOIN parent_question pq ON q.parent_id = pq.id
        INNER JOIN course c ON q.course_id = c.id
        LEFT JOIN users u ON q.created_by = u.id
        LEFT JOIN employees e ON u.id = e.user_id
        LEFT JOIN area a ON c.area_id = a.id
        LEFT JOIN employee_question eoq ON eoq.question_id = q.id AND eoq.fl_status = true
        LEFT JOIN employees e1 ON eoq.teacher_id = e1.id
        LEFT JOIN employee_didi_question oedq ON q.id = oedq.question_id AND oedq.fl_status = true
        LEFT JOIN employees e2 ON oedq.employee_id = e2.id
        LEFT JOIN v_all_question_origins qn ON qn.question_id = q.id
        WHERE q.fl_status = true
        AND q.deleted_at IS NULL
        AND q.code IS NOT NULL
        AND q.status <> 'ARCH'
        AND (p_type IS NULL OR p_type = 'T')
        AND (p_status IS NULL OR q.status = p_status)
        AND (p_course_id IS NULL OR q.course_id = p_course_id)
        GROUP BY pq.id
    ),
    tbl_question AS (
        SELECT
            q.id,
            q.key_question,
            q.type_question,
            q.parent_id,
            q.code,
            q.number_question,
            q.short_description,
            q.course_id,
            q.course,
            q.subtopic_id,
            q.topic_id,
            q.area_id,
            q.area,
            COALESCE(sq.subquestions, '[]'::jsonb) AS subquestions,
            q.status,
            q.created_at as date_status,
            q.created_at,
            q.created_by as created_by_id,
            q.name_employee as created_by,
            q.teacher_id,
            q.teacher,
            q.employee_didi_id,
            q.employee_didi,
            q.question_origin,
            q.search_text,
            q.user_deleted_at,
            q.user_suspended,
            q.shared_status
        FROM questions q
        LEFT JOIN sub_questions sq ON q.parent_id = sq.parent_id
        -- WHERE q.parent_id IS NULL

        UNION ALL

        SELECT DISTINCT
            pq.id,
            concat('t_', pq.id) AS key_question,
            'T' AS type_question,
            pq.id as parent_id,
            pq.code,
            pq.number_question,
            pq.short_description,
            pq.course_id,
            c.name AS course,
            NULL::BIGINT AS subtopic_id,
            NULL::BIGINT AS topic_id,
            a.id as area_id,
            a.description as area,
            COALESCE(sq.subquestions, '[]'::jsonb) AS subquestions,
            pq.status,
            NULL::TIMESTAMP as date_status,
            pq.created_at,
            pq.created_by as created_by_id,
            CONCAT(e.first_surname,' ', e.second_surname,' ', e.first_name) AS created_by,
            NULL::BIGINT as teacher_id,
            NULL::TEXT as teacher,
            e.id as employee_didi_id,
            CONCAT(e.first_surname,' ', e.second_surname,' ', e.first_name) AS employee_didi,
            opq.question_origin,
            pq.search_text,
            u.deleted_at as user_deleted_at,
            u.fl_suspended as user_suspended,
            NULL::TEXT AS shared_status
        FROM parent_question pq
        INNER JOIN course c ON pq.course_id = c.id
        LEFT JOIN area a ON c.area_id = a.id
        LEFT JOIN users u ON pq.created_by = u.id
        LEFT JOIN employees e on u.id = e.user_id
        LEFT JOIN sub_questions sq ON pq.id = sq.parent_id and sq.parent_id is not null
        LEFT JOIN v_all_parent_origins opq ON opq.parent_id = pq.id
        WHERE pq.fl_status = true
        AND pq.deleted_at IS null
        AND pq.code IS NOT NULL
        AND pq.status <> 'ARCH'
        AND (p_employee_didi_id is null or e.id = p_employee_didi_id)
        AND (sq.subquestions <> '[]')
        AND ( p_university_id IS NULL OR opq.university_id = p_university_id )
        AND ( p_option_id IS NULL OR opq.option_id = p_option_id )
        AND ( p_modality_id IS NULL OR opq.modality_id = p_modality_id )
        AND ( p_version IS NULL OR opq."version" = p_version )
        AND ( p_year IS NULL OR opq."year" = p_year )
        AND ( p_name_text IS NULL OR pq.search_text LIKE '%' || p_name_text || '%' )
    ),
    filtered_questions AS (
        SELECT *
        FROM tbl_question
        WHERE (p_course_id IS NULL OR tbl_question.course_id = p_course_id)
        AND (p_created_by IS NULL OR tbl_question.created_by_id = p_created_by)
        AND (p_type IS NULL OR tbl_question.type_question = p_type)
        AND (p_teacher_id IS NULL OR tbl_question.teacher_id = p_teacher_id OR EXISTS (
            SELECT 1
            FROM jsonb_array_elements(tbl_question.subquestions) AS sq
            WHERE (sq->>'teacher_id')::BIGINT = p_teacher_id
        ))
        AND (p_employee_didi_id IS NULL OR tbl_question.employee_didi_id = p_employee_didi_id OR EXISTS (
            SELECT 1
            FROM jsonb_array_elements(tbl_question.subquestions) AS sq
            WHERE (sq->>'employee_didi_id')::BIGINT = p_employee_didi_id
        ))
    ),
    counted_questions AS (
        SELECT *, COUNT(*) OVER () AS total_count
        FROM filtered_questions
        ORDER BY created_at DESC
    )
    SELECT *
    FROM counted_questions
    LIMIT p_perpage
    OFFSET offset_val;
END;
$$;


ALTER FUNCTION odiseo.fn_search_tracking_question(p_perpage integer, p_npage integer, p_name_text character varying, p_course_id integer, p_teacher_id integer, p_employee_didi_id integer, p_status character varying, p_created_by integer, p_type character varying, p_university_id smallint, p_option_id smallint, p_modality_id smallint, p_version smallint, p_year character varying) OWNER TO postgres;

--
