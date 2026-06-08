-- Function: odiseo.fn_report_didi_gm_question(timestamp without time zone, timestamp without time zone, bigint, bigint, bigint[], boolean, character varying, character varying, integer, integer)

--

CREATE FUNCTION odiseo.fn_report_didi_gm_question(p_start_date timestamp without time zone, p_end_date timestamp without time zone, p_course_id bigint, p_charge_id bigint, p_employee_didi_gm_id bigint[], p_fl_status boolean, p_order_column character varying, p_order_direction character varying, p_per_page integer, p_n_page integer) RETURNS TABLE(id bigint, collaborator text, charge_id bigint, charge character varying, fl_status_user boolean, course_id bigint, course character varying, uploads bigint, dasi bigint, obse bigint, digi bigint, dupl bigint, veri bigint, type_document_id bigint, type_document_name character varying, document character varying, total bigint)
    LANGUAGE plpgsql
    SET jit TO 'off'
    AS $$
            BEGIN
                RETURN QUERY
                WITH
                tbl_scope_employees AS MATERIALIZED (
                    SELECT e.id, e.user_id, e.charge_id, e.first_surname, e.second_surname, e.first_name, e.type_document_id, e.document
                    FROM employees e
                    WHERE e.charge_id IN (3, 4)
                    AND (p_charge_id IS NULL OR e.charge_id = p_charge_id)
                    AND (p_employee_didi_gm_id IS NULL OR e.id = ANY(p_employee_didi_gm_id))
                ),
                tbl_user_validated AS MATERIALIZED (
                    SELECT u.id, u.fl_status
                    FROM users u
                    JOIN tbl_scope_employees e ON u.id = e.user_id
                    WHERE (p_fl_status IS NULL OR u.fl_status = p_fl_status)
                ),

                -- 1. UPLOADS
                tbl_question_created_didi_gm AS (
                    SELECT DISTINCT
                        e.id AS employee_id,
                        CONCAT(e.first_surname,' ', e.second_surname,' ', e.first_name) AS collaborator,
                        e.charge_id, ch.name AS charge, u.fl_status AS fl_status_user,
                        ec.course_id, c.name AS course, q.id AS question_id,
                        q.status AS status_question,
                        CASE WHEN q.id IS NULL THEN null ELSE 'up'::VARCHAR(5) END AS status_history,
                        q.created_at AS create_status
                    FROM tbl_scope_employees e
                    INNER JOIN tbl_user_validated u ON e.user_id = u.id
                    INNER JOIN charge ch ON e.charge_id = ch.id
                    INNER JOIN employee_course ec ON e.id = ec.teacher_id AND ec.fl_status = TRUE
                    LEFT JOIN course c ON ec.course_id = c.id
                    LEFT JOIN question q ON e.user_id = q.created_by
                                        AND ec.course_id = q.course_id
                                        AND q.status NOT IN ('ARCH', 'DUPL')
                                        AND q.created_at BETWEEN p_start_date AND p_end_date
                    WHERE (p_course_id IS NULL OR ec.course_id = p_course_id)
                ),
                -- 2. DIGI (HUB CENTRAL: Esta tabla define las preguntas base para las demás)
                order_first_digitization AS (
                    SELECT qs.question_id, MIN(qs.created_at) AS first_digi_date
                    FROM question_status qs
                    WHERE qs.status = 'DIGI'
                    GROUP BY qs.question_id
                ), tbl_valid_employee_digi_total AS (
                    SELECT DISTINCT fde.question_id, fde.first_digi_date, e.id AS employee_id
                    FROM order_first_digitization fde
                    -- Unimos directo con question_status para validar autoría
                    JOIN question_status qs ON qs.question_id = fde.question_id
                        AND qs.created_at = fde.first_digi_date
                    JOIN users u ON qs.created_by = u.id
                    JOIN tbl_scope_employees e ON e.user_id = u.id
                ),
                tbl_first_digi_ever AS (
                    SELECT ofd.question_id, ofd.first_digi_date
                    FROM order_first_digitization ofd
                    WHERE ofd.first_digi_date BETWEEN p_start_date AND p_end_date
                ),
                tbl_valid_employee_digi AS MATERIALIZED (
                    SELECT DISTINCT fde.question_id, fde.first_digi_date, e.id AS employee_id
                    FROM tbl_first_digi_ever fde
                    -- Unimos directo con question_status para validar autoría
                    JOIN question_status qs ON qs.question_id = fde.question_id
                        AND qs.created_at = fde.first_digi_date
                    JOIN users u ON qs.created_by = u.id
                    JOIN tbl_scope_employees e ON e.user_id = u.id
                ),
                tbl_question_digi_didi AS (
                    SELECT e.id AS employee_id, CONCAT(e.first_surname,' ', e.second_surname,' ', e.first_name) AS collaborator,
                        e.charge_id, ch.name AS charge, u.fl_status AS fl_status_user,
                        q.course_id, c.name AS course, ved.question_id, q.status AS status_question,
                        'DIGI'::varchar AS status_history, ved.first_digi_date AS create_status
                    FROM tbl_valid_employee_digi ved
                    INNER JOIN question q ON q.id = ved.question_id
                    INNER JOIN tbl_scope_employees e ON ved.employee_id = e.id
                    INNER JOIN tbl_user_validated u ON e.user_id = u.id
                    INNER JOIN charge ch ON e.charge_id = ch.id
                    LEFT JOIN course c ON q.course_id = c.id
                    WHERE q.fl_status IS TRUE
                    AND (p_course_id IS NULL OR q.course_id = p_course_id)
                ),

                -- Observadas
                 tbl_question_obse_didi_initial AS (
                    SELECT DISTINCT
                        vedt.employee_id,
                        CONCAT(e.first_surname,' ', e.second_surname,' ', e.first_name) AS collaborator,
                        e.charge_id, ch.name AS charge, u.fl_status AS fl_status_user,
                        q.course_id, c.name AS course, vedt.question_id, q.status AS status_question,
                        'OBSE'::varchar AS status_history,
                        MIN(qs.created_at) OVER(PARTITION BY qs.question_id) AS create_status
                    FROM tbl_valid_employee_digi_total vedt
                    INNER JOIN question_status qs ON qs.question_id = vedt.question_id
                    INNER JOIN question q ON q.id = vedt.question_id
                    INNER JOIN tbl_scope_employees e ON vedt.employee_id = e.id
                    INNER JOIN tbl_user_validated u ON e.user_id = u.id
                    INNER JOIN charge ch ON e.charge_id = ch.id
                    LEFT JOIN course c ON q.course_id = c.id
                    WHERE qs.status = 'OBSE'
                    AND (p_course_id IS NULL OR q.course_id = p_course_id)
                ),

                tbl_question_obse_didi AS (
                    SELECT DISTINCT
                        qodi.employee_id,
                        qodi.collaborator,
                        qodi.charge_id, qodi.charge, qodi.fl_status_user,
                        qodi.course_id, qodi.course, qodi.question_id, qodi.status_question,
                        qodi.status_history,
                        qodi.create_status
                    FROM tbl_question_obse_didi_initial qodi
                    WHERE qodi.create_status BETWEEN p_start_date AND p_end_date
                ),

                -- 4. VERI/APRB (OPTIMIZADO: Misma estrategia)
                tbl_question_veri_aprob_initial AS (
                    SELECT DISTINCT
                        ved.employee_id,
                        CONCAT(e.first_surname,' ', e.second_surname,' ', e.first_name) AS collaborator,
                        e.charge_id, ch.name AS charge, u.fl_status AS fl_status_user,
                        q.course_id, c.name AS course, ved.question_id, q.status AS status_question,
                        'VERI'::varchar AS status_history,
                        MIN(qs.created_at) OVER(PARTITION BY qs.question_id) AS create_status
                    FROM tbl_valid_employee_digi_total ved
                    INNER JOIN question_status qs ON qs.question_id = ved.question_id
                    INNER JOIN question q ON q.id = ved.question_id
                    INNER JOIN tbl_scope_employees e ON ved.employee_id = e.id
                    INNER JOIN tbl_user_validated u ON e.user_id = u.id
                    INNER JOIN charge ch ON e.charge_id = ch.id
                    LEFT JOIN course c ON q.course_id = c.id
                    WHERE qs.status IN ('VERI', 'APRB')
                    AND (p_course_id IS NULL OR q.course_id = p_course_id)
                ),
                tbl_question_veri_aprb AS (
                    SELECT
                        vedt.employee_id,
                        vedt.collaborator,
                        vedt.charge_id,
                        vedt.charge,
                        vedt.fl_status_user,
                        vedt.course_id,
                        vedt.course,
                        vedt.question_id,
                        vedt.status_question,
                        vedt.status_history,
                        vedt.create_status
                    FROM tbl_question_veri_aprob_initial vedt
                    WHERE vedt.create_status BETWEEN p_start_date AND p_end_date
                ),

                -- 5. DASI
                tbl_question_dasi_didi_initial AS (
                    SELECT DISTINCT
                        e.id AS employee_id,
                        CONCAT(e.first_surname,' ', e.second_surname,' ', e.first_name) AS collaborator,
                        e.charge_id,
                        ch.name AS charge,
                        u.fl_status AS fl_status_user,
                        q.course_id,
                        c.name AS course,
                        edq.question_id,
                        q.status AS status_question,
                        'DASI'::varchar AS status_history,
                        MIN(qs.created_at) OVER(PARTITION BY qs.question_id) AS create_status
                    FROM employee_didi_question edq
                    INNER JOIN question q ON q.id = edq.question_id
                    INNER JOIN question_status qs ON qs.question_id = q.id
                    INNER JOIN tbl_scope_employees e ON e.id = edq.employee_id
                    INNER JOIN tbl_user_validated u ON e.user_id = u.id
                    INNER JOIN charge ch ON e.charge_id = ch.id
                    LEFT JOIN course c ON q.course_id = c.id
                    WHERE qs.status = 'DASI'
                        AND q.fl_status IS TRUE
                        AND qs.created_at BETWEEN p_start_date AND p_end_date
                        AND (p_course_id IS NULL OR q.course_id = p_course_id)
                ),
                tbl_question_dasi_didi AS (
                    SELECT
                        tqddi.*
                    FROM tbl_question_dasi_didi_initial tqddi
                    WHERE tqddi.create_status BETWEEN p_start_date AND p_end_date
                ),

                -- 6. DUPL
                tbl_question_dupl_initial AS (
                    SELECT DISTINCT
                        e.id AS employee_id,
                        CONCAT(e.first_surname,' ', e.second_surname,' ', e.first_name) AS collaborator,
                        e.charge_id,
                        ch.name AS charge,
                        u.fl_status AS fl_status_user,
                        q.course_id,
                        c.name AS course,
                        qs.question_id,
                        q.status AS status_question,
                        'DUPL'::varchar AS status_history,
                        MIN(qs.created_at) OVER(PARTITION BY qs.question_id) AS create_status
                    FROM question_status qs
                    INNER JOIN question q ON q.id = qs.question_id
                    INNER JOIN users u_stat ON qs.created_by = u_stat.id
                    INNER JOIN tbl_scope_employees e ON e.user_id = u_stat.id
                    INNER JOIN tbl_user_validated u ON e.user_id = u.id
                    INNER JOIN charge ch ON e.charge_id = ch.id
                    LEFT JOIN course c ON q.course_id = c.id
                    WHERE qs.status = 'DUPL'
                        AND q.fl_status = true
                        AND (p_course_id IS NULL OR q.course_id = p_course_id)
                ),
                tbl_question_dupl AS (
                    SELECT
                        tqdi.*
                    FROM tbl_question_dupl_initial tqdi
                    WHERE tqdi.create_status BETWEEN p_start_date AND p_end_date
                ),

                -- UNION FINAL
                tbl_group_question_didi AS (
                    SELECT
                        cq.employee_id, cq.collaborator, cq.charge_id, cq.charge, cq.fl_status_user, cq.course_id, cq.course,
                        COALESCE(SUM(CASE WHEN cq.status_history = 'up' THEN 1 ELSE 0 END), 0) AS uploads,
                        COALESCE(SUM(CASE WHEN cq.status_history = 'DASI' THEN 1 ELSE 0 END), 0) AS dasi,
                        COALESCE(SUM(CASE WHEN cq.status_history = 'OBSE' THEN 1 ELSE 0 END), 0) AS obse,
                        COALESCE(SUM(CASE WHEN cq.status_history = 'DIGI' THEN 1 ELSE 0 END), 0) AS digi,
                        COALESCE(SUM(CASE WHEN cq.status_history = 'DUPL' THEN 1 ELSE 0 END), 0) AS dupl,
                        COALESCE(SUM(CASE WHEN cq.status_history = 'VERI' THEN 1 ELSE 0 END), 0) AS veri,
                        o_e.type_document_id, p_td.name as type_document_name, o_e.document
                    FROM (
                        SELECT * FROM tbl_question_created_didi_gm UNION ALL
                        SELECT * FROM tbl_question_dasi_didi UNION ALL
                        SELECT * FROM tbl_question_obse_didi UNION ALL
                        SELECT * FROM tbl_question_digi_didi UNION ALL
                        SELECT * FROM tbl_question_dupl UNION ALL
                        SELECT * FROM tbl_question_veri_aprb
                    ) AS cq
                    LEFT JOIN tbl_scope_employees o_e ON cq.employee_id = o_e.id
                    LEFT JOIN public.type_documents p_td ON o_e.type_document_id = p_td.id
                    GROUP BY cq.employee_id, cq.collaborator, cq.charge_id, cq.charge,
                            cq.fl_status_user, cq.course_id, cq.course, o_e.type_document_id, p_td.name, o_e.document
                )
                SELECT
                    q.*,
                    COUNT(*) OVER()::bigint AS total
                FROM tbl_group_question_didi q
                ORDER BY
                    CASE WHEN p_order_column = 'uploads' AND p_order_direction = 'asc' THEN q.uploads END ASC,
                    CASE WHEN p_order_column = 'uploads' AND p_order_direction = 'desc' THEN q.uploads END DESC,
                    CASE WHEN p_order_column = 'dasi' AND p_order_direction = 'asc' THEN q.dasi END ASC,
                    CASE WHEN p_order_column = 'dasi' AND p_order_direction = 'desc' THEN q.dasi END DESC,
                    CASE WHEN p_order_column = 'obse' AND p_order_direction = 'asc' THEN q.obse END ASC,
                    CASE WHEN p_order_column = 'obse' AND p_order_direction = 'desc' THEN q.obse END DESC,
                    CASE WHEN p_order_column = 'digi' AND p_order_direction = 'asc' THEN q.digi END ASC,
                    CASE WHEN p_order_column = 'digi' AND p_order_direction = 'desc' THEN q.digi END DESC,
                    CASE WHEN p_order_column = 'dupl' AND p_order_direction = 'asc' THEN q.dupl END ASC,
                    CASE WHEN p_order_column = 'dupl' AND p_order_direction = 'desc' THEN q.dupl END DESC,
                    CASE WHEN p_order_column = 'veri' AND p_order_direction = 'asc' THEN q.veri END ASC,
                    CASE WHEN p_order_column = 'veri' AND p_order_direction = 'desc' THEN q.veri END DESC,
                    q.collaborator ASC, q.course ASC
                LIMIT p_per_page
                OFFSET COALESCE((p_n_page - 1) * p_per_page, 0);
            END;
            $$;


ALTER FUNCTION odiseo.fn_report_didi_gm_question(p_start_date timestamp without time zone, p_end_date timestamp without time zone, p_course_id bigint, p_charge_id bigint, p_employee_didi_gm_id bigint[], p_fl_status boolean, p_order_column character varying, p_order_direction character varying, p_per_page integer, p_n_page integer) OWNER TO postgres;

--
