-- Function: odiseo.fn_get_questions_by_didi_status(integer, integer, integer, integer, character varying, timestamp without time zone, timestamp without time zone, character varying, character varying, character varying, boolean)

--

CREATE FUNCTION odiseo.fn_get_questions_by_didi_status(p_per_page integer, p_n_page integer, p_course_id integer, p_employee_id integer, p_initial_status character varying, p_start_date timestamp without time zone, p_end_date timestamp without time zone, p_short_description character varying, p_code character varying, p_type_question character varying, p_is_ia_generated boolean DEFAULT NULL::boolean) RETURNS TABLE(id bigint, short_description text, question_code character varying, initial_status character varying, current_status character varying, status_created_at timestamp without time zone, type_question character varying, total bigint)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        WITH 
        TargetUser AS (
            SELECT e.id AS employee_id, e.user_id, e.charge_id
            FROM employees e
            WHERE e.id = p_employee_id
            LIMIT 1
        ),
        -- 1. UPLOADS
        Logic_Uploads AS (
            SELECT 
                q.id AS question_id,
                'UPLOADS'::VARCHAR AS derived_status,
                q.created_at AS derived_date
            FROM question q
            INNER JOIN TargetUser tu ON q.created_by = tu.user_id
            INNER JOIN employee_course ec ON tu.employee_id = ec.teacher_id AND ec.fl_status = TRUE
            WHERE 
                p_initial_status = 'UPLOADS'
                AND q.status NOT IN ('ARCH', 'DUPL')
                AND q.course_id = p_course_id
                AND ec.course_id = p_course_id
                AND q.created_at BETWEEN p_start_date AND p_end_date
                AND tu.charge_id IN (3, 4)
        ),
        -- 2. ESTADOS SIMPLES (Solo DIGI y DUPL)
        -- Se retiró DASI de aquí
        FirstStatusEver AS (
            SELECT 
                qs.question_id,
                qs.status,
                MIN(qs.created_at) AS first_date
            FROM question_status qs
            INNER JOIN question q ON q.id = qs.question_id
            WHERE 
                p_initial_status IN ('DIGI', 'DUPL') 
                AND qs.status = p_initial_status
                AND q.course_id = p_course_id
                AND q.fl_status IS TRUE
                AND (p_is_ia_generated IS NULL OR q.ia_generated = p_is_ia_generated)
            GROUP BY qs.question_id, qs.status
        ),
        Logic_Simple_Status AS (
            SELECT 
                fse.question_id,
                fse.status AS derived_status,
                fse.first_date AS derived_date
            FROM FirstStatusEver fse
            INNER JOIN question_status qs ON qs.question_id = fse.question_id 
                AND DATE_TRUNC('second', qs.created_at) = DATE_TRUNC('second', fse.first_date)
            INNER JOIN TargetUser tu ON qs.created_by = tu.user_id
            WHERE 
                DATE_TRUNC('minute', fse.first_date) BETWEEN DATE_TRUNC('minute', p_start_date) AND DATE_TRUNC('minute', p_end_date)
                AND tu.charge_id IN (3, 4)
        ),
        -- 3. LOGICA VERIFICADOS (Cuenta al Digitalizador)
        FirstVeriEver AS (
            SELECT 
                qs.question_id,
                MIN(qs.created_at) AS first_veri_date
            FROM question_status qs
            INNER JOIN question q ON q.id = qs.question_id
            WHERE 
                p_initial_status = 'VERI'
                AND qs.status IN ('VERI', 'APRB')
                AND q.course_id = p_course_id
                AND q.fl_status IS TRUE
                AND (p_is_ia_generated IS NULL OR q.ia_generated = p_is_ia_generated)
            GROUP BY qs.question_id
        ),
        FirstDigiForVeri AS (
            SELECT 
                qs.question_id,
                MIN(qs.created_at) AS first_digi_date
            FROM question_status qs
            WHERE 
                p_initial_status = 'VERI'
                AND qs.status = 'DIGI'
                AND qs.question_id IN (SELECT question_id FROM FirstVeriEver)
            GROUP BY qs.question_id
        ),
        Logic_Veri AS (
            SELECT 
                fve.question_id,
                'VERI'::VARCHAR AS derived_status,
                fve.first_veri_date AS derived_date
            FROM FirstVeriEver fve
            INNER JOIN question_status qs_veri ON qs_veri.question_id = fve.question_id
                AND DATE_TRUNC('second', qs_veri.created_at) = DATE_TRUNC('second', fve.first_veri_date)
                AND qs_veri.status IN ('VERI', 'APRB')
            INNER JOIN FirstDigiForVeri fdfv ON fdfv.question_id = fve.question_id
            INNER JOIN question_status qs_digi ON qs_digi.question_id = fdfv.question_id
                AND DATE_TRUNC('second', qs_digi.created_at) = DATE_TRUNC('second', fdfv.first_digi_date)
            INNER JOIN TargetUser tu ON qs_digi.created_by = tu.user_id -- Filtra por Digitalizador
            WHERE 
                DATE_TRUNC('minute', fve.first_veri_date) BETWEEN DATE_TRUNC('minute', p_start_date) AND DATE_TRUNC('minute', p_end_date)
                AND tu.charge_id IN (3, 4)
        ),
        -- 4. LOGICA OBSERVADOS (Cuenta al Digitalizador)
        FirstObseEver AS (
            SELECT 
                qs.question_id,
                MIN(qs.created_at) AS first_obse_date
            FROM question_status qs
            INNER JOIN question q ON q.id = qs.question_id
            WHERE 
                p_initial_status = 'OBSE'
                AND qs.status = 'OBSE'
                AND q.course_id = p_course_id
                AND q.fl_status IS TRUE
                AND (p_is_ia_generated IS NULL OR q.ia_generated = p_is_ia_generated)
            GROUP BY qs.question_id
        ),
        FirstDigiForObse AS (
            SELECT 
                qs.question_id,
                MIN(qs.created_at) AS first_digi_date
            FROM question_status qs
            WHERE 
                p_initial_status = 'OBSE'
                AND qs.status = 'DIGI'
                AND qs.question_id IN (SELECT question_id FROM FirstObseEver)
            GROUP BY qs.question_id
        ),
        Logic_Obse AS (
            SELECT 
                foe.question_id,
                'OBSE'::VARCHAR AS derived_status,
                foe.first_obse_date AS derived_date
            FROM FirstObseEver foe
            INNER JOIN question_status qs_obse ON qs_obse.question_id = foe.question_id
                AND DATE_TRUNC('second', qs_obse.created_at) = DATE_TRUNC('second', foe.first_obse_date)
            INNER JOIN FirstDigiForObse fdfo ON fdfo.question_id = foe.question_id
            INNER JOIN question_status qs_digi ON qs_digi.question_id = fdfo.question_id
                AND DATE_TRUNC('second', qs_digi.created_at) = DATE_TRUNC('second', fdfo.first_digi_date)
            INNER JOIN TargetUser tu ON qs_digi.created_by = tu.user_id -- Filtra por Digitalizador
            WHERE 
                DATE_TRUNC('minute', foe.first_obse_date) BETWEEN DATE_TRUNC('minute', p_start_date) AND DATE_TRUNC('minute', p_end_date)
                AND tu.charge_id IN (3, 4)
        ),
        FirstDasiEver AS (
            SELECT 
                eq.question_id,
                MIN(eq.created_at) AS first_dasi_date
            FROM employee_didi_question eq
            INNER JOIN question q ON q.id = eq.question_id
            INNER JOIN question_status qs ON qs.question_id = eq.question_id
            WHERE 
                p_initial_status = 'DASI'
                AND q.course_id = p_course_id
                AND q.fl_status IS TRUE
                AND (p_is_ia_generated IS NULL OR q.ia_generated = p_is_ia_generated)
            GROUP BY eq.question_id
        ),
        Logic_Dasi AS (
            SELECT 
                edq.question_id,
                'DASI'::VARCHAR AS derived_status,
                MIN(edq.created_at) AS derived_date -- Tomamos la primera vez en ESTE rango
            FROM employee_didi_question edq
            INNER JOIN question q ON q.id = edq.question_id
            INNER JOIN question_status qs ON qs.question_id = edq.question_id
            INNER JOIN employees e ON e.id = edq.employee_id
            INNER JOIN TargetUser tu ON e.user_id = tu.user_id
            WHERE 
                p_initial_status = 'DASI'
                AND qs.status = 'DASI'
                AND qs.created_at BETWEEN p_start_date AND p_end_date -- Filtro directo de fecha
                AND q.course_id = p_course_id
                AND q.fl_status IS TRUE
                AND (p_is_ia_generated IS NULL OR q.ia_generated = p_is_ia_generated)
                AND tu.charge_id IN (3, 4)
            GROUP BY edq.question_id
        ),
        -- UNIFICACIÓN
        All_Ids AS (
            SELECT * FROM Logic_Uploads
            UNION ALL
            SELECT * FROM Logic_Simple_Status
            UNION ALL
            SELECT * FROM Logic_Veri
            UNION ALL
            SELECT * FROM Logic_Obse
            UNION ALL
            SELECT * FROM Logic_Dasi
        ),
        FinalResult AS (
            SELECT 
                DISTINCT
                q.id,
                q.short_description,
                q.code AS question_code,
                ids.derived_status AS initial_status,
                q.status AS current_status,
                ids.derived_date AS status_created_at,
                q.type::VARCHAR AS type_question
            FROM All_Ids ids
            INNER JOIN question q ON ids.question_id = q.id
            WHERE 
                (p_short_description IS NULL OR p_short_description = '' OR q.short_description ILIKE '%' || p_short_description || '%')
                AND (p_code IS NULL OR p_code = '' OR q.code ILIKE '%' || p_code || '%')
                AND (p_type_question IS NULL OR q.type::VARCHAR = p_type_question)
                AND (p_is_ia_generated IS NULL OR q.ia_generated = p_is_ia_generated)
        ),
        TotalCount AS (
            SELECT COUNT(*) AS total FROM FinalResult
        )
        SELECT 
            fr.id,
            fr.short_description,
            fr.question_code,
            fr.initial_status,
            fr.current_status,
            fr.status_created_at,
            fr.type_question,
            tc.total
        FROM FinalResult fr, TotalCount tc
        ORDER BY fr.status_created_at DESC
        LIMIT p_per_page
        OFFSET (p_n_page - 1) * p_per_page;

    END;
    $$;


ALTER FUNCTION odiseo.fn_get_questions_by_didi_status(p_per_page integer, p_n_page integer, p_course_id integer, p_employee_id integer, p_initial_status character varying, p_start_date timestamp without time zone, p_end_date timestamp without time zone, p_short_description character varying, p_code character varying, p_type_question character varying, p_is_ia_generated boolean) OWNER TO postgres;

--
