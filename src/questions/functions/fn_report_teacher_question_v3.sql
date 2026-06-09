-- Function: questions.fn_report_teacher_question_v3(timestamp without time zone, timestamp without time zone, bigint, bigint[], boolean, character varying, character varying, integer, integer)

--

CREATE FUNCTION questions.fn_report_teacher_question_v3(p_start_date timestamp without time zone, p_end_date timestamp without time zone, p_course_id bigint, p_employee_id bigint[], p_fl_status boolean, p_order_column character varying, p_order_direction character varying, p_per_page integer, p_n_page integer) RETURNS TABLE(id bigint, code character varying, collaborator text, fl_status_user boolean, limit_assigned_questions smallint, fl_unlimit_questions boolean, course_id bigint, course character varying, asig bigint, inde bigint, veri_nq bigint, veri bigint, aprb bigint, obse bigint, type_document_id bigint, type_document_name character varying, document character varying, total bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    
    -- [PRE-PROCESAMIENTO]: Identificación del Indexador Original
    -- Necesario para validar que quien verifica/aprueba sea el autor original en flujos manuales.
    WITH tbl_indexador_original AS (
        SELECT DISTINCT ON (qs.question_id)
            qs.question_id,
            e.id AS employee_id
        FROM question_status qs
        INNER JOIN users u ON qs.created_by = u.id
        INNER JOIN employees e ON e.user_id = u.id
        WHERE qs.status = 'INDE'
        ORDER BY qs.question_id, qs.created_at ASC
    ),

    -- [ESTADO: VERIFICACIÓN (VERI)]
    -- Lógica dual: Valida autoría para humanos y permite conteo directo para IA (NQ).
    tbl_first_veri_ever AS (
        SELECT DISTINCT ON (qs.question_id)
            qs.question_id,
            qs.id,
            qs.created_at AS first_veri_date,
            qs.created_by
        FROM question_status qs
        JOIN question q ON q.id = qs.question_id
        WHERE qs.status = 'VERI'
        AND q.fl_status IS TRUE
        ORDER BY qs.question_id, qs.created_at
    ),
    tbl_valid_employee_veri AS (
        SELECT
            fve.question_id,
            fve.first_veri_date,
            e.id AS employee_id
        FROM tbl_first_veri_ever fve
        JOIN users u ON fve.created_by = u.id
        JOIN employees e ON e.user_id = u.id
    ),
    tbl_status_veri_std AS (
        -- Verificación Estándar: Requiere que verificador = indexador original.
        SELECT vev.employee_id, vev.question_id, q.course_id, q.status AS status_question,
               'VERI' AS status_history, vev.first_veri_date AS create_status, q.ia_generated
        FROM tbl_valid_employee_veri vev
        INNER JOIN question q ON q.id = vev.question_id
        INNER JOIN tbl_indexador_original io ON io.question_id = vev.question_id 
            AND io.employee_id = vev.employee_id
        WHERE (q.ia_generated IS FALSE OR q.ia_generated IS NULL)
        AND DATE_TRUNC('minute', vev.first_veri_date) BETWEEN DATE_TRUNC('minute', p_start_date) AND DATE_TRUNC('minute', p_end_date)
        AND q.status <> 'ARCH'
    ),
    tbl_status_veri_nq AS (
        -- Verificación NQ/IA: No requiere validación de autoría previa.
        SELECT vev.employee_id, vev.question_id, q.course_id, q.status AS status_question,
               'VERI' AS status_history, vev.first_veri_date AS create_status, q.ia_generated
        FROM tbl_valid_employee_veri vev
        INNER JOIN question q ON q.id = vev.question_id
        WHERE q.ia_generated IS TRUE
        AND DATE_TRUNC('minute', vev.first_veri_date) BETWEEN DATE_TRUNC('minute', p_start_date) AND DATE_TRUNC('minute', p_end_date)
        AND q.status <> 'ARCH'
    ),
    tbl_status_veri_digi AS (
        SELECT 
            eq.teacher_id AS employee_id,
            fve.question_id, 
            q.course_id, 
            q.status AS status_question,
            'VERI' AS status_history, 
            fve.first_veri_date AS create_status, 
            q.ia_generated
        FROM tbl_first_veri_ever fve
        INNER JOIN question q ON q.id = fve.question_id
        INNER JOIN employee_question eq 
            ON eq.question_id = fve.question_id 
            AND eq.fl_status IS TRUE
        INNER JOIN question_status qs_veri 
            ON qs_veri.question_id = fve.question_id
            AND DATE_TRUNC('second', qs_veri.created_at) = DATE_TRUNC('second', fve.first_veri_date)
            AND qs_veri.status = 'VERI'
        INNER JOIN users u_veri 
            ON u_veri.id = qs_veri.created_by
        INNER JOIN employees e_veri 
            ON e_veri.user_id = u_veri.id
            AND e_veri.id = eq.teacher_id
        WHERE NOT EXISTS (
            SELECT 1 FROM tbl_indexador_original io 
            WHERE io.question_id = fve.question_id
        )
        AND (q.ia_generated IS FALSE OR q.ia_generated IS NULL)
        AND DATE_TRUNC('minute', fve.first_veri_date) 
            BETWEEN DATE_TRUNC('minute', p_start_date) AND DATE_TRUNC('minute', p_end_date)
        AND q.status <> 'ARCH'
    ),
    tbl_question_veri_teacher AS (
        SELECT DISTINCT e.id AS employee_id, e.code AS code_employee,
            CONCAT(e.first_surname,' ', e.second_surname,' ', e.first_name) AS collaborator,
            u.fl_status AS fl_status_user, e.limit_assigned_questions, e.fl_unlimit_questions,
            qs.course_id, c.name AS course, qs.question_id, qs.status_question, 
            qs.status_history, qs.create_status, qs.ia_generated
        FROM (
            SELECT * FROM tbl_status_veri_std 
            UNION ALL SELECT * FROM tbl_status_veri_nq
            UNION ALL SELECT * FROM tbl_status_veri_digi
        ) qs
        INNER JOIN employees e ON qs.employee_id = e.id
        INNER JOIN users u ON e.user_id = u.id
        LEFT JOIN course c ON qs.course_id = c.id
    ),

    -- [ESTADO: ASIGNACIÓN (ASIG)]
    -- Mide las preguntas asignadas a un docente en el rango de tiempo.
    tbl_question_status_asig AS (
        SELECT qs.question_id, q.course_id, q.status AS status_question, qs.status AS status_history,
               qs.created_at AS create_status, eq.teacher_id AS employee_id, q.ia_generated,
               ROW_NUMBER() OVER (PARTITION BY qs.question_id ORDER BY qs.created_at DESC) AS rn
        FROM employee_question eq
        INNER JOIN question q ON eq.question_id = q.id
        INNER JOIN question_status qs ON eq.question_id = qs.question_id AND qs.created_at >= eq.created_at
        WHERE qs.status = 'ASIG' AND eq.fl_status IS TRUE
        AND DATE_TRUNC('minute', qs.created_at) BETWEEN DATE_TRUNC('minute', p_start_date) AND DATE_TRUNC('minute', p_end_date)
    ),
    tbl_question_asig_teacher AS (
        SELECT DISTINCT e.id AS employee_id, e.code AS code_employee,
               CONCAT(e.first_surname,' ', e.second_surname,' ', e.first_name) AS collaborator,
               u.fl_status AS fl_status_user, e.limit_assigned_questions, e.fl_unlimit_questions,
               qs.course_id, c.name AS course, qs.question_id, qs.status_question, qs.status_history, qs.create_status, qs.ia_generated
        FROM tbl_question_status_asig qs
        INNER JOIN employees e ON qs.employee_id = e.id
        INNER JOIN users u ON e.user_id = u.id
        LEFT JOIN course c ON qs.course_id = c.id
        WHERE qs.rn = 1 AND qs.status_question <> 'ARCH'
    ),

    -- [ESTADO: INDEXACIÓN (INDE)]
    -- Mide la primera vez que una pregunta fue indexada.
    tbl_first_inde_ever AS (
        SELECT qs.question_id, MIN(qs.created_at) AS first_inde_date
        FROM question_status qs
        INNER JOIN question q ON q.id = qs.question_id
        WHERE qs.status = 'INDE' AND q.fl_status IS TRUE
        GROUP BY qs.question_id
    ),
    tbl_question_status_inde AS (
        SELECT io.employee_id, fie.question_id, q.course_id, q.status AS status_question,
               'INDE' AS status_history, fie.first_inde_date AS create_status, q.ia_generated
        FROM tbl_first_inde_ever fie
        INNER JOIN tbl_indexador_original io ON fie.question_id = io.question_id
        INNER JOIN question q ON q.id = fie.question_id
        WHERE DATE_TRUNC('minute', fie.first_inde_date) BETWEEN DATE_TRUNC('minute', p_start_date) AND DATE_TRUNC('minute', p_end_date)
        AND q.status <> 'ARCH'
    ),
    tbl_question_inde_teacher AS (
        SELECT DISTINCT e.id AS employee_id, e.code AS code_employee,
               CONCAT(e.first_surname,' ', e.second_surname,' ', e.first_name) AS collaborator,
               u.fl_status AS fl_status_user, e.limit_assigned_questions, e.fl_unlimit_questions,
               qs.course_id, c.name AS course, qs.question_id, qs.status_question, qs.status_history, qs.create_status, qs.ia_generated
        FROM tbl_question_status_inde qs
        INNER JOIN employees e ON qs.employee_id = e.id
        INNER JOIN users u ON e.user_id = u.id
        LEFT JOIN course c ON qs.course_id = c.id
    ),

    -- [ESTADO: APROBACIÓN (APRB)]
    -- Se atribuye la aprobación al indexador original de la pregunta.
    tbl_first_aprb_ever AS (
        SELECT qs.question_id, MIN(qs.created_at) AS first_aprb_date
        FROM question_status qs
        INNER JOIN question q ON q.id = qs.question_id
        WHERE qs.status = 'APRB' AND q.fl_status IS TRUE
        GROUP BY qs.question_id
    ),
    tbl_valid_employee_aprb AS (
        SELECT DISTINCT fae.question_id, fae.first_aprb_date, e.id AS employee_id
        FROM tbl_first_aprb_ever fae
        INNER JOIN question_status qs ON qs.question_id = fae.question_id 
            AND DATE_TRUNC('second', qs.created_at) = DATE_TRUNC('second', fae.first_aprb_date)
            AND qs.status = 'APRB'
        INNER JOIN users u ON qs.created_by = u.id
        INNER JOIN employees e ON e.user_id = u.id
    ),
    tbl_question_status_aprb AS (
        SELECT vea.employee_id, vea.question_id, q.course_id, q.status AS status_question,
               'APRB' AS status_history, vea.first_aprb_date AS create_status, q.ia_generated
        FROM tbl_valid_employee_aprb vea
        INNER JOIN question q ON q.id = vea.question_id
        WHERE DATE_TRUNC('minute', vea.first_aprb_date) BETWEEN DATE_TRUNC('minute', p_start_date) AND DATE_TRUNC('minute', p_end_date)
        AND q.status <> 'ARCH'
    ),
    tbl_question_aprb_teacher AS (
        SELECT DISTINCT e.id AS employee_id, e.code AS code_employee,
               CONCAT(e.first_surname,' ', e.second_surname,' ', e.first_name) AS collaborator,
               u.fl_status AS fl_status_user, e.limit_assigned_questions, e.fl_unlimit_questions,
               qs.course_id, c.name AS course, qs.question_id, qs.status_question, qs.status_history, qs.create_status, qs.ia_generated
        FROM tbl_question_status_aprb qs
        INNER JOIN employees e ON qs.employee_id = e.id
        INNER JOIN users u ON e.user_id = u.id
        LEFT JOIN course c ON qs.course_id = c.id
    ),
    -- [ESTADO: OBSERVACIÓN (OBSE)]
    -- Mide las observaciones realizadas por el docente a las preguntas.
    tbl_first_obse_ever AS (
        SELECT qs.question_id, MIN(qs.created_at) AS first_obse_date
        FROM question_status qs
        INNER JOIN question q ON q.id = qs.question_id
        WHERE qs.status = 'OBSE' AND q.fl_status IS TRUE
        GROUP BY qs.question_id
    ),
    tbl_valid_employee_obse AS (
        SELECT DISTINCT foe.question_id, foe.first_obse_date, e.id AS employee_id
        FROM tbl_first_obse_ever foe
        INNER JOIN question_status qs ON qs.question_id = foe.question_id 
            AND DATE_TRUNC('second', qs.created_at) = DATE_TRUNC('second', foe.first_obse_date)
        INNER JOIN users u ON qs.created_by = u.id
        INNER JOIN employees e ON e.user_id = u.id
    ),
    tbl_question_status_obse AS (
        SELECT veo.employee_id, veo.question_id, q.course_id, q.status AS status_question,
               'OBSE' AS status_history, veo.first_obse_date AS create_status, q.ia_generated
        FROM tbl_valid_employee_obse veo
        INNER JOIN question q ON q.id = veo.question_id
        WHERE DATE_TRUNC('minute', veo.first_obse_date) BETWEEN DATE_TRUNC('minute', p_start_date) AND DATE_TRUNC('minute', p_end_date)
        AND q.status <> 'ARCH'
    ),
    tbl_question_obse_teacher AS (
        SELECT DISTINCT e.id AS employee_id, e.code AS code_employee,
               CONCAT(e.first_surname,' ', e.second_surname,' ', e.first_name) AS collaborator,
               u.fl_status AS fl_status_user, e.limit_assigned_questions, e.fl_unlimit_questions,
               qs.course_id, c.name AS course, qs.question_id, qs.status_question, qs.status_history, qs.create_status, qs.ia_generated
        FROM tbl_question_status_obse qs
        INNER JOIN employees e ON qs.employee_id = e.id
        INNER JOIN users u ON e.user_id = u.id
        LEFT JOIN course c ON qs.course_id = c.id
    ),
    
    -- [PROCESAMIENTO FINAL]: Agrupación, Filtros de Entrada y Conteo por Columnas
    tbl_group_question_teacher AS (
        SELECT
            cq.employee_id, cq.code_employee, cq.collaborator, cq.fl_status_user,
            cq.limit_assigned_questions, cq.fl_unlimit_questions, cq.course_id::BIGINT, cq.course,
            COALESCE(SUM(CASE WHEN cq.status_history = 'ASIG' THEN 1 ELSE 0 END), 0) AS asig,
            COALESCE(SUM(CASE WHEN cq.status_history = 'INDE' THEN 1 ELSE 0 END), 0) AS inde,
            COALESCE(SUM(CASE WHEN cq.status_history = 'VERI' AND cq.ia_generated IS TRUE THEN 1 ELSE 0 END), 0) AS veri_nq,
            COALESCE(SUM(CASE WHEN cq.status_history = 'VERI' AND (cq.ia_generated IS FALSE OR cq.ia_generated IS NULL) THEN 1 ELSE 0 END), 0) AS veri,
            COALESCE(SUM(CASE WHEN cq.status_history = 'APRB' THEN 1 ELSE 0 END), 0) AS aprb,
            COALESCE(SUM(CASE WHEN cq.status_history = 'OBSE' THEN 1 ELSE 0 END), 0) AS obse,
            o_e.type_document_id, p_td.name as type_document_name, o_e.document
        FROM (
            SELECT * FROM tbl_question_asig_teacher UNION ALL
            SELECT * FROM tbl_question_inde_teacher UNION ALL
            SELECT * FROM tbl_question_veri_teacher UNION ALL
            SELECT * FROM tbl_question_aprb_teacher UNION ALL
            SELECT * FROM tbl_question_obse_teacher
        ) AS cq
        LEFT JOIN employees o_e ON cq.employee_id = o_e.id
        LEFT JOIN common.type_documents p_td ON o_e.type_document_id = p_td.id
        GROUP BY
            cq.employee_id, cq.code_employee, cq.collaborator,
            cq.fl_status_user, cq.limit_assigned_questions,
            cq.fl_unlimit_questions, cq.course_id, cq.course,
            o_e.id, p_td.name
        HAVING (p_course_id IS NULL OR cq.course_id = p_course_id)
        AND (p_employee_id IS NULL OR cq.employee_id = ANY(p_employee_id))
    )

    -- [SALIDA]: Aplicación de Ordenamiento y Paginación
    SELECT q.*, COUNT(*) OVER()::bigint AS total
    FROM tbl_group_question_teacher q
    ORDER BY
        CASE WHEN p_order_column IN ('asig','inde','veri','veri_nq','aprb','obse')
            THEN (
                CASE p_order_column
                    WHEN 'asig'    THEN q.asig
                    WHEN 'inde'    THEN q.inde
                    WHEN 'veri'    THEN q.veri
                    WHEN 'veri_nq' THEN q.veri_nq
                    WHEN 'aprb'    THEN q.aprb
                    WHEN 'obse'    THEN q.obse
                END * CASE p_order_direction WHEN 'desc' THEN -1 ELSE 1 END
            )
        END,
        q.employee_id ASC, q.course_id ASC
    LIMIT p_per_page
    OFFSET COALESCE((p_n_page - 1) * p_per_page, 0);
END;
$$;


ALTER FUNCTION questions.fn_report_teacher_question_v3(p_start_date timestamp without time zone, p_end_date timestamp without time zone, p_course_id bigint, p_employee_id bigint[], p_fl_status boolean, p_order_column character varying, p_order_direction character varying, p_per_page integer, p_n_page integer) OWNER TO postgres;

--
