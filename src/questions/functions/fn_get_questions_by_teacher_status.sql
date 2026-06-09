-- Function: questions.fn_get_questions_by_teacher_status(integer, integer, integer, integer, character varying, timestamp without time zone, timestamp without time zone, character varying, character varying, character varying, boolean)

--

CREATE FUNCTION questions.fn_get_questions_by_teacher_status(p_per_page integer, p_n_page integer, p_course_id integer, p_employee_id integer, p_status character varying, p_start_date timestamp without time zone, p_end_date timestamp without time zone, p_short_description character varying, p_code character varying, p_type_question character varying, p_is_ia_generated boolean DEFAULT NULL::boolean) RETURNS TABLE(question_code character varying, current_status character varying, id bigint, initial_status character varying, status_created_at timestamp without time zone, type_question character varying, short_description text, total bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_real_status VARCHAR := CASE WHEN p_status = 'VERI_NQ' THEN 'VERI' ELSE p_status END;
BEGIN
    RETURN QUERY
    WITH

    -- PASO 1: Preguntas candidatas del empleado en el rango de fechas
    -- Partimos desde el empleado, no desde toda la tabla
    tbl_first_status_ever AS (
        SELECT
            qs.question_id,
            MIN(qs.created_at) AS first_status_date
        FROM question_status qs
        INNER JOIN question q ON q.id = qs.question_id
        WHERE qs.status = v_real_status
        AND q.fl_status IS TRUE
        AND q.status <> 'ARCH'
        AND (p_status = 'VERI_NQ' AND q.ia_generated IS TRUE
             OR p_status = 'VERI' AND (q.ia_generated IS FALSE OR q.ia_generated IS NULL)
             OR p_status NOT IN ('VERI', 'VERI_NQ'))
        AND (p_course_id IS NULL OR q.course_id = p_course_id)
        AND p_status <> 'ASIG'
        GROUP BY qs.question_id
    ),

    tbl_candidate_questions AS (
        SELECT 
            question_id, 
            first_status_date
        FROM tbl_first_status_ever
        WHERE DATE_TRUNC('minute', first_status_date) BETWEEN DATE_TRUNC('minute', p_start_date) AND DATE_TRUNC('minute', p_end_date)
    ),

    -- PASO 2: Para esas preguntas candidatas, quién ejecutó el estado
    tbl_executor AS (
        SELECT DISTINCT ON (cq.question_id)
            cq.question_id,
            cq.first_status_date,
            e.id AS employee_id
        FROM tbl_candidate_questions cq
        INNER JOIN question_status qs ON qs.question_id = cq.question_id
            AND qs.created_at = cq.first_status_date
            AND qs.status = v_real_status
        INNER JOIN users u ON qs.created_by = u.id
        INNER JOIN employees e ON e.user_id = u.id
        ORDER BY cq.question_id
    ),

    -- PASO 3: Para esas preguntas candidatas, quién fue el indexador original
    tbl_indexador AS (
        SELECT DISTINCT ON (qs.question_id)
            qs.question_id,
            e.id AS employee_id
        FROM question_status qs
        INNER JOIN users u ON qs.created_by = u.id
        INNER JOIN employees e ON e.user_id = u.id
        WHERE qs.status = 'INDE'
        -- Solo para las preguntas candidatas, no toda la BD
        AND qs.question_id IN (SELECT question_id FROM tbl_candidate_questions)
        ORDER BY qs.question_id, qs.created_at ASC
    ),

    tbl_normal_status AS (
        SELECT
            ex.question_id,
            ex.first_status_date,
            v_real_status AS found_status
        FROM tbl_executor ex
        LEFT JOIN tbl_indexador io ON io.question_id = ex.question_id
        WHERE ex.employee_id = p_employee_id
        AND (
            (p_status IN ('VERI', 'VERI_NQ') AND io.employee_id = ex.employee_id)
            OR p_status NOT IN ('VERI', 'VERI_NQ')
        )
    ),

    -- PASO 5: Flujo DIGI→VERI filtrado por employee_id
    tbl_digi_veri_status AS (
        SELECT DISTINCT ON (cq.question_id)
            cq.question_id,
            cq.first_status_date,
            v_real_status AS found_status
        FROM tbl_candidate_questions cq
        INNER JOIN employee_question eq ON eq.question_id = cq.question_id
            AND eq.fl_status IS TRUE
            AND eq.teacher_id = p_employee_id
        -- El asignado debe ser quien verificó
        INNER JOIN tbl_executor ex ON ex.question_id = cq.question_id
            AND ex.employee_id = p_employee_id
        -- Sin INDE
        LEFT JOIN tbl_indexador io ON io.question_id = cq.question_id
        -- Sin tbl_normal_status
        LEFT JOIN tbl_normal_status ns ON ns.question_id = cq.question_id
        WHERE p_status IN ('VERI', 'VERI_NQ')
        AND io.question_id IS NULL
        AND ns.question_id IS NULL
        ORDER BY cq.question_id, eq.created_at DESC
    ),

    -- PASO 6: ASIG
    tbl_asig_status AS (
        SELECT
            qs.question_id,
            qs.created_at   AS first_status_date,
            qs.status       AS found_status
        FROM employee_question eq
        INNER JOIN question q ON eq.question_id = q.id
            AND q.fl_status IS TRUE
            AND q.status <> 'ARCH'
        INNER JOIN question_status qs ON eq.question_id = qs.question_id
            AND qs.created_at >= eq.created_at
            AND qs.status = 'ASIG'
            AND qs.created_at BETWEEN DATE_TRUNC('minute', p_start_date)
                                   AND DATE_TRUNC('minute', p_end_date)
        WHERE p_status = 'ASIG'
        AND eq.fl_status IS TRUE
        AND eq.teacher_id = p_employee_id
        AND (p_course_id IS NULL OR q.course_id = p_course_id)
    ),

    -- PASO 7: Union y join final
    tbl_filtered_history AS (
        SELECT
            sd.question_id,
            sd.found_status      AS status_history,
            sd.first_status_date AS create_status,
            q.type               AS type_question,
            q.code               AS question_code,
            q.short_description
        FROM (
            SELECT * FROM tbl_normal_status    WHERE p_status <> 'ASIG'
            UNION ALL
            SELECT * FROM tbl_digi_veri_status
            UNION ALL
            SELECT * FROM tbl_asig_status      WHERE p_status = 'ASIG'
        ) sd
        INNER JOIN question q ON q.id = sd.question_id
        AND (p_code              IS NULL OR p_code = ''
             OR q.code ILIKE '%' || p_code || '%')
        AND (p_type_question     IS NULL OR p_type_question = ''
             OR q.type = p_type_question)
        AND (p_short_description IS NULL OR p_short_description = ''
             OR q.short_description ILIKE '%' || p_short_description || '%')
    )

    SELECT
        fh.question_code,
        qs_curr.status      AS current_status,
        fh.question_id      AS id,
        fh.status_history   AS initial_status,
        fh.create_status    AS status_created_at,
        fh.type_question,
        fh.short_description,
        COUNT(*) OVER ()    AS total
    FROM tbl_filtered_history fh
    LEFT JOIN question_status qs_curr ON qs_curr.question_id = fh.question_id
        AND qs_curr.fl_active = TRUE
    ORDER BY fh.create_status ASC
    LIMIT p_per_page
    OFFSET (p_n_page - 1) * p_per_page;

END;
$$;


ALTER FUNCTION questions.fn_get_questions_by_teacher_status(p_per_page integer, p_n_page integer, p_course_id integer, p_employee_id integer, p_status character varying, p_start_date timestamp without time zone, p_end_date timestamp without time zone, p_short_description character varying, p_code character varying, p_type_question character varying, p_is_ia_generated boolean) OWNER TO postgres;

--
