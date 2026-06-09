-- Function: materials.fn_store_text_material(boolean, jsonb, bigint, smallint, bigint)

--

CREATE FUNCTION materials.fn_store_text_material(p_fl_exam boolean, p_text jsonb, p_material_id bigint, p_week_type_material_id smallint, p_created_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
	DECLARE
            v_data_question JSONB;
            v_question_history_id BIGINT;
            v_cycle_id BIGINT;
            v_university_id SMALLINT;
            v_headquarters_id BIGINT;
            v_headquarters_classroom_id BIGINT;
            v_material_exam_area_week BIGINT;
            v_week SMALLINT;
            v_type_material_id SMALLINT;
	BEGIN
			-- Obtener ciclo y universidad del material mandado
            SELECT
                m.cycle_id, m.university_id, m.headquarte_id, m.headquarters_classroom_id
                INTO v_cycle_id, v_university_id, v_headquarters_id, v_headquarters_classroom_id
            FROM material m WHERE id = p_material_id LIMIT 1;

            -- Obtener week y type_material_id para la nueva estructura
            SELECT
                week, type_material_id
                INTO v_week, v_type_material_id
            FROM detail_week_type_mat WHERE id = p_week_type_material_id LIMIT 1;

			 FOR v_data_question IN SELECT * FROM jsonb_array_elements(p_text) LOOP
                    SELECT qhc.id INTO v_question_history_id FROM question_history_cycle qhc
                    WHERE qhc.parent_question_id = (v_data_question->>'parent_id')::BIGINT
                    AND qhc.cycle_id = v_cycle_id
                    AND qhc.university_id = v_university_id
                    AND qhc.headquarters_id = v_headquarters_id
                    AND qhc.fl_status = true
                    LIMIT 1;

                    IF v_question_history_id IS NULL THEN
                        INSERT INTO question_history_cycle(
							parent_question_id, cycle_id,
							university_id,
 							headquarters_id,
                            subquestion,
							created_by,
 							created_at
						)
                        VALUES (
							(v_data_question->>'parent_id')::BIGINT,
 							v_cycle_id, v_university_id,
 							v_headquarters_id,
                            (v_data_question->>'selected_subquestions')::JSONB,
 							p_created_by,
 							now()
						)
                        RETURNING id INTO v_question_history_id;
                    END IF;

                    WITH inserted_mbq AS (
                        INSERT INTO material_ballot_question (
                            week_type_material_id,
                            material_id,
                            week,
                            type_material_id,
                            course_id,
                            level_id,
                            parent_question_id,
                            question_history_id,
                            type_text_id,
                            type_text_subcategory_id,
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
                            (v_data_question->>'level_id')::BIGINT,
                            (v_data_question->>'parent_id')::BIGINT,
                            v_question_history_id,
                            (v_data_question->>'category_id')::BIGINT,
                            (v_data_question->>'subcategory_id')::BIGINT,
                            'GENERATED',
                            p_created_by,
                            NOW()
                        )
                        ON CONFLICT (week_type_material_id, (COALESCE(question_id, 0)), (COALESCE(parent_question_id, 0)))
                        WHERE fl_status = TRUE AND deleted_at IS NULL AND (question_id IS NOT NULL OR parent_question_id IS NOT NULL)
                        DO UPDATE SET
                            course_id = EXCLUDED.course_id,
                            level_id = EXCLUDED.level_id,
                            question_history_id = EXCLUDED.question_history_id,
                            type_text_id = EXCLUDED.type_text_id,
                            type_text_subcategory_id = EXCLUDED.type_text_subcategory_id,
                            state = EXCLUDED.state,
                            updated_by = EXCLUDED.created_by,
                            updated_at = NOW()
                        RETURNING id
                    ),
                    deleted_subquestions AS (
                        UPDATE material_ballot_subquestions
                        SET fl_status = FALSE, deleted_at = NOW()
                        WHERE material_ballot_question_id IN (SELECT id FROM inserted_mbq)
                          AND fl_status = TRUE
                    )
                    INSERT INTO materials.material_ballot_subquestions (material_ballot_question_id, question_id, position, state, topic_id, course_id, subtopic_id)
                    SELECT
                        mbq.id,
                        (elem->>'question_id')::BIGINT,
                        row_number() OVER(PARTITION BY mbq.id ORDER BY (elem->>'position')::INT2 NULLS LAST)::INT2,
                        CASE WHEN (elem->>'question_id') IS NOT NULL THEN 'GENERATED'::varchar ELSE 'MISSING'::varchar END,
                        (elem->>'topic_id')::SMALLINT,
                        (elem->>'course_id')::SMALLINT,
                        (elem->>'subtopic_id')::SMALLINT
                    FROM inserted_mbq mbq
                    CROSS JOIN LATERAL jsonb_array_elements(
                        CASE WHEN jsonb_typeof((v_data_question->>'selected_subquestions')::jsonb) = 'array'
                        THEN (v_data_question->>'selected_subquestions')::jsonb
                        ELSE '[]'::jsonb END
                    ) AS elem
                    WHERE (v_data_question->>'selected_subquestions') IS NOT NULL;
                END LOOP;

	END;
$$;


ALTER FUNCTION materials.fn_store_text_material(p_fl_exam boolean, p_text jsonb, p_material_id bigint, p_week_type_material_id smallint, p_created_by bigint) OWNER TO postgres;

--
