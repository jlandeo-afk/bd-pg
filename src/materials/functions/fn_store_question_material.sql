-- Function: materials.fn_store_question_material(boolean, jsonb, bigint, smallint, jsonb, bigint)

--

CREATE FUNCTION materials.fn_store_question_material(p_fl_exam boolean, p_questions jsonb, p_material_id bigint, p_week_type_material_id smallint, p_areas jsonb, p_created_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_data_question JSONB;
            v_question_history_id BIGINT;
            v_cycle_id BIGINT;
            v_university_id SMALLINT;
            v_headquarters_id BIGINT;
            v_headquarters_classroom_id BIGINT;
            v_exam_area_key TEXT;
            v_exam_area_value BIGINT;
            v_material_exam_area_week BIGINT;
            v_week SMALLINT;
            v_type_material_id SMALLINT;
        BEGIN
            -- Obtener ciclo y universidad del material mandado
            SELECT
                m.cycle_id, m.university_id, m.headquarte_id, m.headquarters_classroom_id
                INTO v_cycle_id, v_university_id, v_headquarters_id, v_headquarters_classroom_id
            FROM material m WHERE id = p_material_id LIMIT 1;

            -- Obtener week y type_material_id
            SELECT
                week, type_material_id
                INTO v_week, v_type_material_id
            FROM detail_week_type_mat WHERE id = p_week_type_material_id LIMIT 1;

            IF p_fl_exam IS FALSE THEN
                FOR v_data_question IN SELECT * FROM jsonb_array_elements(p_questions) LOOP
                    SELECT qhc.id INTO v_question_history_id FROM question_history_cycle qhc
                    WHERE qhc.question_id = (v_data_question->>'question_id')::BIGINT
                    AND qhc.cycle_id = v_cycle_id
                    AND qhc.university_id = v_university_id
                    AND qhc.headquarters_id = v_headquarters_id
                    AND qhc.fl_status = true
                    LIMIT 1;

                    IF v_question_history_id IS NULL THEN
                        INSERT INTO question_history_cycle(question_id, cycle_id, university_id, headquarters_id, created_by, created_at)
                        VALUES ((v_data_question->>'question_id')::BIGINT, v_cycle_id, v_university_id, v_headquarters_id, p_created_by, now())
                        RETURNING id INTO v_question_history_id;
                    END IF;

                    INSERT INTO material_ballot_question (
                        week_type_material_id,
                        material_id,
                        week,
                        type_material_id,
                        course_id,
                        topic_id,
                        subtopic_id,
                        level_id,
                        type,
                        question_id,
                        question_history_id,
                        position,
                        state,
                        created_by,
                        created_at
                    )
                    VALUES (
                        (v_data_question->>'week_type_material_id')::BIGINT,
                        p_material_id,
                        v_week,
                        v_type_material_id,
                        (v_data_question->>'course_id')::SMALLINT,
                        (v_data_question->>'topic_id')::SMALLINT,
                        (v_data_question->>'subtopic_id')::SMALLINT,
                        (v_data_question->>'level_id')::BIGINT,
                        (v_data_question->>'type')::VARCHAR,
                        (v_data_question->>'question_id')::BIGINT,
                        v_question_history_id,
                        (v_data_question->>'order')::BIGINT,
                        'GENERATED',
                        p_created_by,
                        NOW()
                    )
                    ON CONFLICT (week_type_material_id, (COALESCE(question_id, 0)), (COALESCE(parent_question_id, 0)))
                    WHERE fl_status = TRUE AND deleted_at IS NULL AND (question_id IS NOT NULL OR parent_question_id IS NOT NULL)
                    DO UPDATE SET
                        course_id = EXCLUDED.course_id,
                        topic_id = EXCLUDED.topic_id,
                        subtopic_id = EXCLUDED.subtopic_id,
                        level_id = EXCLUDED.level_id,
                        type = EXCLUDED.type,
                        question_history_id = EXCLUDED.question_history_id,
                        position = EXCLUDED.position,
                        state = EXCLUDED.state,
                        updated_by = EXCLUDED.created_by,
                        updated_at = NOW();
                END LOOP;
            ELSE
                FOR v_exam_area_value IN SELECT * FROM jsonb_array_elements(p_areas) LOOP
                    SELECT meaw.id INTO v_material_exam_area_week
                    FROM material_exam_area_week meaw
                    WHERE meaw.week_type_material_id = p_week_type_material_id
                    AND meaw.area_id = v_exam_area_value AND meaw.fl_status = true LIMIT 1;

                    IF v_material_exam_area_week IS NULL THEN
                        INSERT INTO material_exam_area_week (week_type_material_id, area_id, created_by, created_at)
                        VALUES (p_week_type_material_id, v_exam_area_value, p_created_by, NOW())
                        RETURNING id INTO v_material_exam_area_week;
                    END IF;

                    FOR v_data_question IN
                        SELECT q.* FROM jsonb_array_elements(p_questions) AS q WHERE q->>'exam_area_id' = v_exam_area_value::TEXT
                    LOOP
                        SELECT qhc.id INTO v_question_history_id FROM question_history_cycle qhc
                        WHERE qhc.question_id = (v_data_question->>'question_id')::BIGINT
                        AND qhc.cycle_id = v_cycle_id
                        AND qhc.university_id = v_university_id
                        AND qhc.headquarters_id = v_headquarters_id
                        AND qhc.fl_status = true
                        LIMIT 1;

                        IF v_question_history_id IS NULL THEN
                            INSERT INTO question_history_cycle(question_id, cycle_id, university_id, headquarters_id, created_by, created_at)
                            VALUES ((v_data_question->>'question_id')::BIGINT, v_cycle_id, v_university_id, v_headquarters_id, p_created_by, now())
                            RETURNING id INTO v_question_history_id;
                        END IF;

                        INSERT INTO material_exam_question (
                            material_exam_area_week_id,
                            course_id,
                            topic_id,
                            subtopic_id,
                            level_id,
                            question_id,
                            question_history_id,
                            type,
                            created_by,
                            created_at
                        )
                        VALUES (
                            v_material_exam_area_week,
                            (v_data_question->>'course_id')::SMALLINT,
                            (v_data_question->>'topic_id')::SMALLINT,
                            (v_data_question->>'subtopic_id')::SMALLINT,
                            (v_data_question->>'level_id')::BIGINT,
                            (v_data_question->>'question_id')::BIGINT,
                            v_question_history_id,
                            (v_data_question->>'type')::VARCHAR,
                            p_created_by,
                            NOW()
                        );
                    END LOOP;
                END LOOP;
            END IF;
        END;
        $$;


ALTER FUNCTION materials.fn_store_question_material(p_fl_exam boolean, p_questions jsonb, p_material_id bigint, p_week_type_material_id smallint, p_areas jsonb, p_created_by bigint) OWNER TO postgres;

--
