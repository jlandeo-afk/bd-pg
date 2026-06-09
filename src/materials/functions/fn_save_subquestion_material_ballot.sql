-- Function: materials.fn_save_subquestion_material_ballot(bigint, bigint, bigint, bigint, json)

--

CREATE FUNCTION materials.fn_save_subquestion_material_ballot(p_parent_question_id bigint, p_material_id bigint, p_material_distribution_id bigint, p_created_by bigint, p_subquestion json) RETURNS void
    LANGUAGE plpgsql
    AS $$
                DECLARE
                v_cycle_id BIGINT;
                v_cycle_start_date DATE;
                v_university_id SMALLINT;
                v_headquarters_id BIGINT;
                v_question_history_id BIGINT;
                v_week_type_material_id BIGINT;
                BEGIN

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
                        question_id,
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

                UPDATE material_ballot_question mdbq
                SET
                    updated_by = p_created_by,
                    updated_at = NOW()
                WHERE mdbq.id = p_material_distribution_id
                RETURNING mdbq.week_type_material_id into v_week_type_material_id;

                -- Soft-delete subpreguntas anteriores
                UPDATE material_ballot_subquestions
                SET fl_status = FALSE, deleted_at = NOW(), deleted_by = p_created_by
                WHERE material_ballot_question_id = p_material_distribution_id AND fl_status = TRUE;

                -- Insertar nuevas subpreguntas desde el JSON
                INSERT INTO material_ballot_subquestions (material_ballot_question_id, question_id, position, state, topic_id, course_id, subtopic_id, fl_is_manual, added_in_completion, created_by, created_at)
                SELECT
                    p_material_distribution_id,
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

                END;
            $$;


ALTER FUNCTION materials.fn_save_subquestion_material_ballot(p_parent_question_id bigint, p_material_id bigint, p_material_distribution_id bigint, p_created_by bigint, p_subquestion json) OWNER TO postgres;

--
