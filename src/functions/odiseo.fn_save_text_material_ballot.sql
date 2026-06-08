-- Function: odiseo.fn_save_text_material_ballot(smallint, bigint, smallint, smallint, smallint, smallint, smallint, bigint, smallint, bigint, bigint, bigint, json)

--

CREATE FUNCTION odiseo.fn_save_text_material_ballot(p_week smallint, p_parent_question_id bigint, p_category_id smallint, p_subcategory_id smallint, p_course_id smallint, p_level_id smallint, p_position smallint, p_week_type_material_id bigint, p_type_material_id smallint, p_material_id bigint, p_material_distribution_id bigint, p_created_by bigint, p_subquestion json) RETURNS TABLE(id bigint, material_id bigint, week smallint, type_material_id smallint, week_type_material_id bigint, course_id smallint, code_course character varying, course character varying, "position" smallint, position_initial smallint, subtopic_id bigint, code_subtopic character varying, subtopic character varying, topic_id smallint, code_topic character varying, topic character varying, level_id bigint, level_description character varying, level_name character varying, usage_level_id bigint, question_id bigint, type character varying, usage_status boolean)
    LANGUAGE plpgsql
    AS $$
                DECLARE
                v_cycle_id BIGINT;
                v_cycle_start_date DATE;
                v_university_id SMALLINT;
                v_headquarters_id BIGINT;
                v_question_history_id BIGINT;
                v_ballot_question_id BIGINT;
                BEGIN
                -- Obtener ciclo y universidad del material
                SELECT
                    m.cycle_id, c.start_date, m.university_id, m.headquarte_id
                    INTO v_cycle_id, v_cycle_start_date, v_university_id, v_headquarters_id
                FROM material m
                INNER JOIN cycle c ON m.cycle_id = c.id
                WHERE m.id = p_material_id
                LIMIT 1;

                -- Traer o registrar historial
                SELECT
                    qhc.id INTO v_question_history_id
                FROM question_history_cycle qhc
                WHERE qhc.parent_question_id = p_parent_question_id
                    AND qhc.cycle_id = v_cycle_id
                    AND qhc.university_id = v_university_id
                    AND qhc.headquarters_id = v_headquarters_id
                    AND qhc.fl_status = true
                LIMIT 1;

                -- Si no hay historial se registra
                IF v_question_history_id IS NULL THEN
                    INSERT INTO question_history_cycle AS qhc (
                        parent_question_id,
                        cycle_id,
                        university_id,
                        headquarters_id,
                        created_by,
                        created_at,
                        automatic,
                        subquestion
                    )
                    VALUES (
                        p_parent_question_id,
                        v_cycle_id,
                        v_university_id,
                        v_headquarters_id,
                        p_created_by,
                        now(),
                        false,
                        p_subquestion
                    )
                    RETURNING qhc.id INTO v_question_history_id;
                END IF;

                -- Insertar o actualizar pregunta de balotario (UNIFICADO)
                IF p_material_distribution_id IS NOT NULL THEN
                    v_ballot_question_id := p_material_distribution_id;

                    UPDATE material_ballot_question mdbq
                    SET
                        type_text_id = p_category_id,
                        type_text_subcategory_id = p_subcategory_id,
                        level_id = p_level_id,
                        usage_level_id = p_level_id,
                        parent_question_id = p_parent_question_id,
                        question_history_id = v_question_history_id,
                        usage_status = FALSE,
                        added_in_completion = TRUE,
                        fl_is_manual = TRUE,
                        state = 'MANUAL_COMPLETED',
                        updated_by = p_created_by,
                        updated_at = NOW()
                    WHERE mdbq.id = p_material_distribution_id;
                ELSE
                    INSERT INTO material_ballot_question (
                        week_type_material_id,
                        material_id,
                        week,
                        type_material_id,
                        course_id,
                        type_text_id,
                        type_text_subcategory_id,
                        level_id,
                        parent_question_id,
                        question_history_id,
                        "position",
                        fl_is_manual,
                        created_by,
                        created_at,
                        state,
                        fl_status
                    )
                    VALUES (
                        p_week_type_material_id,
                        p_material_id,
                        p_week,
                        p_type_material_id,
                        p_course_id,
                        p_category_id,
                        p_subcategory_id,
                        p_level_id,
                        p_parent_question_id,
                        v_question_history_id,
                        p_position,
                        TRUE,
                        p_created_by,
                        NOW(),
                        'MANUAL_COMPLETED',
                        TRUE
                    )
                    RETURNING id INTO v_ballot_question_id;
                END IF;

                -- Desactivar subpreguntas anteriores
                UPDATE material_ballot_subquestions
                SET fl_status = FALSE, deleted_at = NOW(), deleted_by = p_created_by
                WHERE material_ballot_question_id = v_ballot_question_id AND fl_status = TRUE;

                -- Insertar nuevas subpreguntas (incluye faltantes con question_id NULL)
                INSERT INTO material_ballot_subquestions (material_ballot_question_id, question_id, position, state, topic_id, course_id, subtopic_id, fl_is_manual, added_in_completion, created_by, created_at)
                SELECT 
                    v_ballot_question_id,
                    (sub.obj->>'question_id')::bigint,
                    sub.ord::int,
                    CASE WHEN (sub.obj->>'question_id') IS NOT NULL THEN 'MANUAL_COMPLETED' ELSE 'MISSING' END,
                    (sub.obj->>'topic_id')::smallint,
                    (sub.obj->>'course_id')::smallint,
                    (sub.obj->>'subtopic_id')::smallint,
                    TRUE,
                    TRUE,
                    p_created_by,
                    NOW()
                FROM jsonb_array_elements(CASE WHEN jsonb_typeof(p_subquestion::jsonb) = 'array' THEN p_subquestion::jsonb ELSE '[]'::jsonb END) WITH ORDINALITY AS sub(obj, ord);

                -- Actualizar distribución
                UPDATE detail_week_type_mat dwtmupd
                SET
                    url_solution = null,
                    url_without_solution = null,
                    fl_process_status = 1,
                    fl_process_status_without = 1,
                    url_zip_class_mat = null,
                    fl_process_class_mat = 1,
                    fl_process_quality = 1,
                    url_quality = null,
                    fl_process_without_quality = 1,
                    url_without_quality = null,
                    updated_by = p_created_by,
                    updated_at = now()
                WHERE dwtmupd.id = (SELECT dwtmupdcp.id FROM detail_week_type_mat dwtmupdcp WHERE dwtmupdcp.material_id = p_material_id
                    AND dwtmupdcp.week = p_week AND dwtmupdcp.type_material_id = p_type_material_id);

                RETURN QUERY
                SELECT
                    fmdbq.id,
                    fmdbq.material_id,
                    fmdbq.week,
                    fmdbq.type_material_id,
                    fmdbq.week_type_material_id,
                    fmdbq.course_id,
                    fmdbq.code_course,
                    fmdbq.course,
                    fmdbq.position,
                    fmdbq.position_initial,
                    fmdbq.subtopic_id::bigint,
                    fmdbq.code_subtopic,
                    fmdbq.subtopic,
                    fmdbq.topic_id,
                    fmdbq.code_topic,
                    fmdbq.topic,
                    fmdbq.level_id,
                    fmdbq.level_description,
                    fmdbq.level_name,
                    fmdbq.usage_level_id,
                    fmdbq.question_id,
                    fmdbq.type,
                    fmdbq.usage_status
                FROM
                    fn_material_ballot_question(p_material_id, p_week, p_type_material_id, p_week_type_material_id) AS fmdbq;

                END;
            $$;


ALTER FUNCTION odiseo.fn_save_text_material_ballot(p_week smallint, p_parent_question_id bigint, p_category_id smallint, p_subcategory_id smallint, p_course_id smallint, p_level_id smallint, p_position smallint, p_week_type_material_id bigint, p_type_material_id smallint, p_material_id bigint, p_material_distribution_id bigint, p_created_by bigint, p_subquestion json) OWNER TO postgres;

--
