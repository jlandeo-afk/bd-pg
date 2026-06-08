-- Function: odiseo.fn_insert_material_distribution_ballot_parent_questions(bigint, smallint, smallint, bigint, smallint, smallint, smallint, bigint, smallint, bigint, jsonb, bigint, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_insert_material_distribution_ballot_parent_questions(p_material_id bigint, p_week smallint, p_type_material_id smallint, p_week_type_material_id bigint, p_course_id smallint, p_position smallint, p_position_initial smallint, p_level_id bigint, p_usage_level_id smallint, p_parent_question_id bigint, p_subquestion jsonb, p_category_id bigint, p_subcategory_id bigint, p_created_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_material_ballot_question_id BIGINT;
            BEGIN
                INSERT INTO material_ballot_question (
                    material_id,
                    "week",
                    type_material_id,
                    week_type_material_id,
                    course_id,
                    position,
                    position_initial,
                    level_id,
                    usage_level_id,
                    parent_question_id,
                    type_text_id,
                    type_text_subcategory_id,
                    state,
                    created_by,
                    created_at
                )
                VALUES (
                    p_material_id,
                    p_week,
                    p_type_material_id,
                    p_week_type_material_id,
                    p_course_id,
                    p_position,
                    p_position_initial,
                    p_level_id,
                    p_usage_level_id,
                    p_parent_question_id,
                    p_category_id,
                    p_subcategory_id,
                    'GENERATED',
                    p_created_by,
                    NOW()
                )
                ON CONFLICT (week_type_material_id, (COALESCE(question_id, 0)), (COALESCE(parent_question_id, 0)))
                WHERE fl_status = TRUE AND deleted_at IS NULL AND (question_id IS NOT NULL OR parent_question_id IS NOT NULL)
                DO UPDATE SET
                    material_id = EXCLUDED.material_id,
                    "week" = EXCLUDED.week,
                    type_material_id = EXCLUDED.type_material_id,
                    course_id = EXCLUDED.course_id,
                    position = EXCLUDED.position,
                    position_initial = EXCLUDED.position_initial,
                    level_id = EXCLUDED.level_id,
                    usage_level_id = EXCLUDED.usage_level_id,
                    type_text_id = EXCLUDED.type_text_id,
                    type_text_subcategory_id = EXCLUDED.type_text_subcategory_id,
                    state = EXCLUDED.state,
                    updated_by = EXCLUDED.created_by,
                    updated_at = NOW()
                RETURNING id INTO v_material_ballot_question_id;

                -- Inhabilitar subpreguntas anteriores en caso de actualización
                UPDATE material_ballot_subquestions
                SET fl_status = FALSE, deleted_at = NOW()
                WHERE material_ballot_question_id = v_material_ballot_question_id AND fl_status = TRUE;

                -- Insertar nuevas subpreguntas
                IF p_subquestion IS NOT NULL AND jsonb_typeof(p_subquestion) = 'array' THEN
                    INSERT INTO odiseo.material_ballot_subquestions (
                        material_ballot_question_id,
                        question_id,
                        position,
                        state,
                        topic_id,
                        course_id,
                        subtopic_id
                    )
                    SELECT
                        v_material_ballot_question_id,
                        (elem->>'question_id')::BIGINT,
                        row_number() OVER(ORDER BY (elem->>'position')::INT2 NULLS LAST)::INT2,
                        CASE WHEN (elem->>'question_id') IS NOT NULL THEN 'GENERATED'::varchar ELSE 'MISSING'::varchar END,
                        (elem->>'topic_id')::SMALLINT,
                        (elem->>'course_id')::SMALLINT,
                        (elem->>'subtopic_id')::SMALLINT
                    FROM jsonb_array_elements(p_subquestion) AS elem;
                END IF;
            END;
        $$;


ALTER FUNCTION odiseo.fn_insert_material_distribution_ballot_parent_questions(p_material_id bigint, p_week smallint, p_type_material_id smallint, p_week_type_material_id bigint, p_course_id smallint, p_position smallint, p_position_initial smallint, p_level_id bigint, p_usage_level_id smallint, p_parent_question_id bigint, p_subquestion jsonb, p_category_id bigint, p_subcategory_id bigint, p_created_by bigint) OWNER TO postgres;

--
