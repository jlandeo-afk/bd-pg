-- Function: questions.fn_upload_question_missing(bigint, smallint, character varying, bigint, bigint, smallint, integer, bigint, character varying, text, text, boolean, numeric, bigint, smallint, character varying, integer, jsonb, integer, jsonb, jsonb, jsonb)

--

CREATE FUNCTION questions.fn_upload_question_missing(p_detail_id bigint, p_course_id smallint, p_type_td character varying, p_employee_id bigint, p_created_by bigint, p_topic_id smallint, p_subtopic_id integer, p_level_id bigint, p_type_question character varying, p_description text, p_short_description text, p_fl_diagrammed boolean, p_ter numeric, p_config_alternative_id bigint, p_question_columns smallint, p_status character varying, p_priority integer, p_alternatives jsonb, p_question_mode integer DEFAULT NULL::integer, p_files jsonb DEFAULT NULL::jsonb, p_alternative_images jsonb DEFAULT NULL::jsonb, p_question_images jsonb DEFAULT NULL::jsonb) RETURNS TABLE(question_id bigint, question_code character varying, status character varying, description text, alternatives jsonb)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_question_id bigint;
    v_question_code varchar;
    v_mmqd material_missing_question_detail%ROWTYPE;
    v_mmq material_missing_question%ROWTYPE;
    v_alt jsonb;
    v_alt_id bigint;
    v_answer_id bigint;
    v_pending_count bigint;
    v_process varchar;
    v_new_code varchar;
    v_new_number text;
    v_employee_name varchar;
    v_employee_question_id bigint;
BEGIN
    -- 1. Verificar detalle pendiente
    SELECT
        mmqd.* INTO v_mmqd
    FROM
        material_missing_question_detail mmqd
    WHERE
        mmqd.id = p_detail_id
        AND mmqd.status = 'pending';

    -- 2. Obtener maestro
    SELECT
        mmq.* INTO v_mmq
    FROM
        material_missing_question mmq
    WHERE
        mmq.id = v_mmqd.material_missing_question_id;

    -- 3. Generar código
    SELECT
        fq.full_code,
        fq.number_str INTO v_new_code,
        v_new_number
    FROM
        fn_generate_question_code (p_course_id::integer, 'P'::varchar) fq;
    -- 4. Insertar pregunta
    INSERT INTO question (code, "number", course_id, topic_id, level_id, type, description, short_description, fl_diagrammed, ter, config_alternative_id, columns, status, priority, teacher_id, fl_status, created_by, created_at)
        VALUES (v_new_code, v_new_number, p_course_id, p_topic_id, p_level_id, p_type_td, p_description, p_short_description, p_fl_diagrammed, p_ter, p_config_alternative_id, p_question_columns, p_status, p_priority, p_employee_id, TRUE, p_created_by, NOW())
    RETURNING
        question.id, question.code INTO v_question_id, v_question_code;
    -- 5. Subtopic
    IF p_subtopic_id IS NOT NULL THEN
        INSERT INTO question_subtopic (question_id, subtopic_id, fl_status, created_by, created_at)
            VALUES (v_question_id, p_subtopic_id, TRUE, p_created_by, NOW());
    END IF;
    -- 6. Alternativas
    FOR v_alt IN
    SELECT
        value
    FROM
        jsonb_array_elements(p_alternatives)
        LOOP
            INSERT INTO alternative (question_id, description, created_by, created_at)
                VALUES (v_question_id, (v_alt ->> 'description')::text, p_created_by, NOW())
            RETURNING
                alternative.id INTO v_alt_id;
            IF (v_alt ->> 'answer') = 'true' OR (v_alt ->> 'answer') = '100' THEN
                v_answer_id := v_alt_id;
            END IF;
        END LOOP;
    -- 7. Update answer_id
    UPDATE
        question q
    SET
        answer_id = v_answer_id,
        updated_by = p_created_by,
        updated_at = NOW()
    WHERE
        q.id = v_question_id;
    -- 8. employee_question
    INSERT INTO employee_question (teacher_id, question_id, alternative_id, type, fl_status, week, year, created_by, created_at)
        VALUES (p_employee_id, v_question_id, v_answer_id, p_status, TRUE, EXTRACT(WEEK FROM NOW())::integer, EXTRACT(YEAR FROM NOW())::integer, p_created_by, NOW())
    RETURNING
        id INTO v_employee_question_id;
    -- 9. question_status
    v_process := CASE WHEN p_status = 'INDE' THEN
        'INDEXACIÓN'
    WHEN p_status = 'ASIG' THEN
        'ASIGNACIÓN'
    ELSE
        p_status
    END;

    -- Guardar las imagenes asociadas a la pregunta
    IF p_files IS NOT NULL AND jsonb_array_length(p_files) > 0 THEN
        INSERT INTO employee_question_document
        (
            employee_question_id, 
            type_archive_id, 
            document, 
            created_by, 
            created_at
        )
        SELECT 
            v_employee_question_id, 
            (elem->>'type_id')::integer,
            elem->>'path', 
            p_created_by, 
            NOW()
        FROM jsonb_array_elements(p_files) AS elem;
    END IF;

    -- Insertar imágenes de la pregunta (si existen)
    IF p_question_images IS NOT NULL AND jsonb_array_length(p_question_images) > 0 THEN
        INSERT INTO question_image (code, extension, image, question_id, created_by, created_at)
        SELECT code, extension, image, v_question_id, p_created_by, NOW()
        FROM jsonb_to_recordset(p_question_images) AS x(code varchar, extension varchar, image text);
    END IF;

    -- Insertar imágenes de las alternativas (si existen)
    IF p_alternative_images IS NOT NULL AND jsonb_array_length(p_alternative_images) > 0 THEN
        INSERT INTO question_image (code, extension, image, question_id, created_by, created_at)
        SELECT code, extension, image, v_question_id, p_created_by, NOW()
        FROM jsonb_to_recordset(p_alternative_images) AS x(code varchar, extension varchar, image text);
    END IF;

    SELECT
        CONCAT(split_part(e.first_name, ' ', 1), ' ', upper(
            LEFT (e.first_surname, 1)), '. ', e.second_surname) INTO v_employee_name
    FROM
        employees e
    WHERE
        e.id = p_employee_id;
    UPDATE
        question_status qs
    SET
        fl_active = FALSE
    WHERE
        qs.question_id = v_question_id;
    INSERT INTO question_status (question_id, status, process, description, created_by, created_at)
        VALUES (v_question_id, p_status, v_process, 'La pregunta fue registrada como faltante por el docente <span class=''text-teacher''>' || COALESCE(v_employee_name, 'Docente') || '</span>', p_created_by, NOW());
    -- 10. Actualizar detalle
    UPDATE
        material_missing_question_detail mmqd
    SET
        question_id = v_question_id,
        employee_id = p_employee_id,
        status = 'completed',
        updated_at = NOW()
    WHERE
        mmqd.id = p_detail_id;

    -- 12. Recalcular maestro
    SELECT
        COUNT(*) INTO v_pending_count
    FROM
        material_missing_question_detail mmqd
    WHERE
        mmqd.material_missing_question_id = v_mmq.id
        AND mmqd.status = 'pending';
        
    UPDATE
        material_missing_question mmq
    SET
        status = CASE WHEN v_pending_count = 0
            AND NOW() <= v_mmq.expiration_date THEN
            'completed'
        WHEN v_pending_count = 0
            AND NOW() > v_mmq.expiration_date THEN
            'completed_late'
        ELSE
            mmq.status
        END,
        updated_at = NOW()
    WHERE
        mmq.id = v_mmq.id;
    -- 13. Retorno (sin cambios)
    RETURN QUERY
    SELECT
        q.id,
        q.code,
        q.status,
        q.description,
        COALESCE(
            (SELECT JSONB_AGG(
                JSONB_BUILD_OBJECT(
                    'id', a.id,
                    'description', a.description
                )
            )
            FROM alternative a
            WHERE a.question_id = q.id
                AND a.fl_status = true),
            '[]'::JSONB
        ) as alternatives
    FROM question q
    WHERE q.id = v_question_id;
END;
$$;


ALTER FUNCTION questions.fn_upload_question_missing(p_detail_id bigint, p_course_id smallint, p_type_td character varying, p_employee_id bigint, p_created_by bigint, p_topic_id smallint, p_subtopic_id integer, p_level_id bigint, p_type_question character varying, p_description text, p_short_description text, p_fl_diagrammed boolean, p_ter numeric, p_config_alternative_id bigint, p_question_columns smallint, p_status character varying, p_priority integer, p_alternatives jsonb, p_question_mode integer, p_files jsonb, p_alternative_images jsonb, p_question_images jsonb) OWNER TO postgres;

--
