-- Function: questions.fn_list_verified_questions_teacher(integer, integer, character varying, integer, integer[], integer, character varying, character varying[])

--

CREATE FUNCTION questions.fn_list_verified_questions_teacher(p_perpage integer, p_npage integer, p_name_text character varying, p_teacher_id integer, p_course_id integer[], p_didi_id integer, p_type character varying, p_status character varying[]) RETURNS TABLE(id bigint, key_question text, type_question text, code character varying, parent_id bigint, short_description text, subquestions jsonb, course_id smallint, course character varying, subtopic_id integer, status character varying, teacher_id bigint, teacher text, didi_id bigint, didi text, date_status timestamp without time zone, shared_status text, total_count bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    offset_val     integer;
    v_cut_off_date integer;
BEGIN
    SELECT ads.cut_off_date INTO v_cut_off_date
    FROM advanced_settings AS ads
    WHERE ads.fl_status = TRUE
    LIMIT 1;

    offset_val := p_perpage * (p_npage - 1);

    RETURN QUERY
    WITH date_range AS (
        SELECT
            CURRENT_TIMESTAMP - INTERVAL '30 days' AS start_date,
            CURRENT_TIMESTAMP                       AS end_date
    ),
    first_verified_date AS (
        SELECT
            qss.question_id,
            MIN(qss.created_at) AS created_at
        FROM question_status qss
        WHERE qss.status = 'VERI'
        GROUP BY qss.question_id
    ),
    latest_statuses AS (
        SELECT *
        FROM first_verified_date fvd
        WHERE fvd.created_at >= (SELECT start_date FROM date_range)
    ),
    all_verified_questions AS (
        -- Preguntas propias
        SELECT
            vq.id,
            vq.code,
            vq.status,
            vq.short_description,
            vq.parent_id,
            vq.course_id,
            qst.subtopic_id,
            c.name        AS course,
            ls.created_at AS status_date,
            NULL::bigint  AS share_id,
            FALSE         AS is_shared,
            get_shared_status(vq.id, qst.subtopic_id) AS shared_status
        FROM question vq
        LEFT JOIN course c           ON c.id  = vq.course_id
        LEFT JOIN question_subtopic qst ON qst.question_id = vq.id
                                      AND qst.deleted_at IS NULL
        JOIN  latest_statuses ls     ON ls.question_id = vq.id
        WHERE vq.fl_status   = TRUE
          AND vq.deleted_at  IS NULL
          AND (
              (p_status IS NULL AND vq.status IN ('VERI', 'PEND', 'RESV', 'APRB'))
              OR vq.status = ANY(p_status)
          )
          AND (
              p_type IS NULL
              OR (p_type = 'T' AND vq.parent_id IS NOT NULL)
              OR (p_type = 'P' AND vq.parent_id IS NULL)
          )
          AND (p_course_id IS NULL OR vq.course_id = ANY(p_course_id))

        UNION ALL

        -- Preguntas compartidas (question_shares)
        SELECT
            vq.id,
            qs.code,
            vq.status,
            vq.short_description,
            vq.parent_id,
            t.course_id,
            qs.subtopic_id,
            c.name        AS course,
            ls.created_at AS status_date,
            qs.id         AS share_id,
            TRUE          AS is_shared,
            get_shared_status(vq.id, qs.subtopic_id) AS shared_status
        FROM question vq
        JOIN  question_shares qs ON qs.question_id = vq.id
                                AND qs.deleted_at IS NULL
        JOIN  topic t            ON t.id = qs.topic_id
        LEFT JOIN course c       ON c.id = t.course_id
        JOIN  latest_statuses ls ON ls.question_id = vq.id
        WHERE vq.fl_status  = TRUE
          AND vq.deleted_at IS NULL
          AND (
              (p_status IS NULL AND vq.status IN ('VERI', 'PEND', 'RESV', 'APRB'))
              OR vq.status = ANY(p_status)
          )
          AND (
              p_type IS NULL
              OR (p_type = 'T' AND vq.parent_id IS NOT NULL)
              OR (p_type = 'P' AND vq.parent_id IS NULL)
          )
          AND (p_course_id IS NULL OR t.course_id = ANY(p_course_id))
    ),
    verified_s_subquestions AS (
        SELECT
            oq.parent_id,
            JSONB_AGG(
                JSONB_BUILD_OBJECT(
                    'id',                oq.id,
                    'key_question',      CASE
                                             WHEN oq.is_shared THEN 's_' || oq.id || '_' || oq.share_id
                                             ELSE 's_' || oq.id
                                         END,
                    'type_question',     'S',
                    'code',              oq.code,
                    'parent_id',         oq.parent_id,
                    'short_description', oq.short_description,
                    'course_id',         oq.course_id,
                    'course',            oq.course,
                    'subtopic_id',       oq.subtopic_id,
                    'status',            oq.status,
                    'teacher_id',        es1.id,
                    'teacher',           CONCAT(es1.first_surname, ' ', es1.second_surname, ' ', es1.first_name),
                    'didi_id',           es2.id,
                    'didi',              CONCAT(es2.first_surname, ' ', es2.second_surname, ' ', es2.first_name),
                    'date_status',       oq.status_date
                )
            ) AS subquestions
        FROM all_verified_questions oq
        LEFT JOIN employee_question      eoq ON eoq.question_id = oq.id AND eoq.fl_status = TRUE
        LEFT JOIN employees              es1 ON es1.id = eoq.teacher_id
        LEFT JOIN employee_didi_question edq ON edq.question_id = oq.id AND edq.fl_status = TRUE
        LEFT JOIN employees              es2 ON es2.id = edq.employee_id
        WHERE oq.parent_id IS NOT NULL
          AND (p_type IS NULL OR p_type = 'T')
          AND (p_teacher_id IS NULL OR es1.id = p_teacher_id)
          AND (p_didi_id    IS NULL OR es2.id = p_didi_id)
          AND (
              p_name_text IS NULL
              OR LOWER(oq.code)              LIKE '%' || LOWER(p_name_text) || '%'
              OR unaccent(LOWER(oq.short_description)) LIKE '%' || LOWER(p_name_text) || '%'
              OR EXISTS (
                  SELECT 1
                  FROM parent_question pp
                  WHERE pp.id = oq.parent_id
                    AND LOWER(pp.code) LIKE '%' || LOWER(p_name_text) || '%'
              )
          )
        GROUP BY oq.parent_id
    ),
    tbl_questions AS (
        -- Preguntas tipo P
        SELECT
            q.id,
            CASE
                WHEN q.is_shared THEN 'f_' || q.id || '_s_' || q.share_id
                ELSE 'p_' || q.id
            END                                                                   AS key_question,
            'P'                                                                   AS type_question,
            q.code,
            q.parent_id,
            q.short_description,
            NULL::jsonb                                                           AS subquestions,
            q.course_id,
            q.course,
            q.subtopic_id,
            q.status,
            e1.id                                                                 AS teacher_id,
            CONCAT(e1.first_surname, ' ', e1.second_surname, ' ', e1.first_name)  AS teacher,
            e2.id                                                                 AS didi_id,
            CONCAT(e2.first_surname, ' ', e2.second_surname, ' ', e2.first_name)  AS didi,
            q.status_date                                                         AS date_status,
            q.shared_status                                                       AS shared_status
        FROM all_verified_questions q
        LEFT JOIN employee_question      eq  ON eq.question_id  = q.id AND eq.fl_status  = TRUE
        LEFT JOIN employees              e1  ON e1.id = eq.teacher_id
        LEFT JOIN employee_didi_question edq ON edq.question_id = q.id AND edq.fl_status = TRUE
        LEFT JOIN employees              e2  ON e2.id = edq.employee_id
        WHERE (p_type IS NULL OR p_type = 'P')
          AND q.parent_id IS NULL
          AND (p_teacher_id IS NULL OR e1.id = p_teacher_id)
          AND (p_didi_id    IS NULL OR e2.id = p_didi_id)
          AND (
              p_name_text IS NULL
              OR LOWER(q.code)              LIKE '%' || LOWER(p_name_text) || '%'
              OR unaccent(LOWER(q.short_description)) LIKE '%' || LOWER(p_name_text) || '%'
          )

        UNION ALL

        -- Preguntas tipo T (compuestas)
        SELECT
            pq.id,
            't_' || pq.id AS key_question,
            'T'           AS type_question,
            pq.code,
            pq.id         AS parent_id,
            pq.short_description,
            COALESCE(vq.subquestions, '[]'::jsonb),
            pq.course_id,
            c.name,
            NULL::integer AS subtopic_id,
            pq.status,
            0::bigint,
            '',
            0::bigint,
            '',
            pq.created_at,
            NULL::text    AS shared_status
        FROM parent_question pq
        INNER JOIN verified_s_subquestions vq ON vq.parent_id = pq.id
                                              AND pq.status IN ('VERI', 'PEND', 'RESV', 'APRB')
        INNER JOIN course c                   ON c.id = pq.course_id
        WHERE (
            (p_status IS NOT NULL AND pq.status = ANY(p_status))
            OR (p_status IS NULL  AND pq.status IN ('VERI', 'PEND', 'RESV', 'APRB'))
        )
          AND EXISTS (
              SELECT 1
              FROM all_verified_questions avq
              WHERE avq.parent_id = pq.id
          )
    ),
    counted_questions AS (
        SELECT
            *,
            count(*) OVER () AS total_count
        FROM tbl_questions
    )
    SELECT *
    FROM counted_questions
    ORDER BY date_status DESC
    LIMIT p_perpage
    OFFSET offset_val;

END;
$$;


ALTER FUNCTION questions.fn_list_verified_questions_teacher(p_perpage integer, p_npage integer, p_name_text character varying, p_teacher_id integer, p_course_id integer[], p_didi_id integer, p_type character varying, p_status character varying[]) OWNER TO postgres;

--
