-- Function: questions.fn_teacher_questions_totals(bigint)

--

CREATE FUNCTION questions.fn_teacher_questions_totals(p_teacher_id bigint) RETURNS TABLE(assigned bigint, indexed bigint, revised bigint, verified bigint)
    LANGUAGE plpgsql
    AS $$
    DECLARE 
        v_total_verified BIGINT;
    BEGIN

        -- Calcular total verificado (VERI + APRB) usando 30 días fijos
        WITH date_range AS (
            SELECT
                CURRENT_TIMESTAMP - INTERVAL '30 days' AS start_date,
                NOW() AS end_date
        ),
        -- Primera fecha de verificación desde question_status
        first_verified_date AS (
            SELECT
                qs.question_id,
                MIN(qs.created_at) AS first_veri_date
            FROM question_status qs
            WHERE qs.status = 'VERI'
            GROUP BY qs.question_id
        ),
        -- Preguntas válidas en rango (verificadas en los últimos 30 días)
        valid_questions_in_range AS (
            SELECT
                vq.id,
                vq.parent_id,
                vq.status
            FROM question vq
            INNER JOIN first_verified_date fvd ON fvd.question_id = vq.id
            CROSS JOIN date_range dr
            WHERE vq.fl_status = TRUE
                AND vq.deleted_at IS NULL
                AND fvd.first_veri_date >= dr.start_date
        ),
        -- Filtrar por profesor
        teacher_questions AS (
            SELECT 
                vqr.id,
                vqr.parent_id,
                vqr.status
            FROM valid_questions_in_range vqr
            INNER JOIN employee_question eq ON eq.question_id = vqr.id
            WHERE (p_teacher_id IS NULL OR eq.teacher_id = p_teacher_id)
                AND eq.fl_status = TRUE
        ),
        -- Contar standalone (VERI + APRB)
        standalone_counts AS (
            SELECT COUNT(*) AS total
            FROM teacher_questions tq
            WHERE tq.parent_id IS NULL
                AND tq.status IN ('VERI', 'APRB')
        ),
        -- Contar parents (VERI + APRB)
        parent_counts AS (
            SELECT COUNT(DISTINCT pq.id) AS total
            FROM parent_question pq
            WHERE pq.id IN (
                SELECT DISTINCT parent_id 
                FROM teacher_questions 
                WHERE parent_id IS NOT NULL
            )
            AND pq.status IN ('VERI', 'APRB')
        )
        SELECT COALESCE(
            (SELECT total FROM standalone_counts) + (SELECT total FROM parent_counts), 
            0
        ) INTO v_total_verified;

        -- Retornar totales
        RETURN QUERY 
        WITH base_questions AS (
            SELECT 
                CONCAT('S', q.id) AS id,
                'S' AS type,
                ARRAY[]::TEXT[] AS children_status,
                q.status AS status
            FROM employee_question eq
            INNER JOIN question q ON eq.question_id = q.id
            WHERE (p_teacher_id IS NULL OR eq.teacher_id = p_teacher_id)
                AND q.fl_status IS TRUE
                AND q.deleted_at IS NULL
                AND eq.fl_status IS TRUE
                AND eq.deleted_at IS NULL
                AND q.status NOT IN ('SASI', 'ARCH')
                AND q.parent_id IS NULL
        ),
        parents AS (
            SELECT 
                CONCAT('T', pq.id) AS id,
                'T' AS type,
                ARRAY_AGG(child_q.status) AS children_status,
                NULL AS status
            FROM parent_question pq
            INNER JOIN question child_q ON child_q.parent_id = pq.id
            WHERE EXISTS (
                SELECT 1
                FROM employee_question eq2
                JOIN question q2 ON eq2.question_id = q2.id
                WHERE q2.parent_id = pq.id
                    AND (p_teacher_id IS NULL OR eq2.teacher_id = p_teacher_id)
                    AND q2.fl_status IS TRUE
                    AND q2.deleted_at IS NULL
                    AND eq2.fl_status IS TRUE
                    AND eq2.deleted_at IS NULL
                    AND q2.status NOT IN ('SASI', 'ARCH')
            )
            AND pq.status <> 'DUPL'
            GROUP BY pq.id
        ),
        all_questions_status AS (
            SELECT * FROM base_questions
            UNION ALL
            SELECT DISTINCT id, type, children_status, status
            FROM parents
        )
        SELECT 
            COALESCE(SUM(
                CASE
                    WHEN type = 'S' AND status IN ('ASIG', 'RESO', 'SSOL', 'RECH') THEN 1
                    WHEN type = 'T' AND children_status && ARRAY['ASIG', 'RESO', 'SSOL', 'RECH']::TEXT[] THEN 1
                    ELSE 0
                END
            ), 0) AS assigned,
            COALESCE(SUM(
                CASE
                    WHEN type = 'S' AND status IN ('DASI', 'INDE') THEN 1
                    WHEN type = 'T' AND children_status && ARRAY['DASI', 'INDE']::TEXT[] THEN 1
                    ELSE 0
                END
            ), 0) AS indexed,
            COALESCE(SUM(
                CASE
                    WHEN type = 'S' AND status IN ('DIGI', 'OBSE') THEN 1
                    WHEN type = 'T' AND children_status && ARRAY['DIGI', 'OBSE']::TEXT[] THEN 1
                    ELSE 0
                END
            ), 0) AS revised,
            v_total_verified AS verified
        FROM all_questions_status;
    END;
    $$;


ALTER FUNCTION questions.fn_teacher_questions_totals(p_teacher_id bigint) OWNER TO postgres;

--
