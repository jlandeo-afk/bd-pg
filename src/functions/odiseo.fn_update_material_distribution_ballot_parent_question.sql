-- Function: odiseo.fn_update_material_distribution_ballot_parent_question(bigint, smallint, smallint, smallint, bigint, jsonb, bigint, bigint, boolean, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_update_material_distribution_ballot_parent_question(p_distribution_id bigint, p_position smallint, p_position_initial smallint, p_category_id smallint, p_subcategory_id bigint, p_subquestion jsonb, p_level_id bigint, p_usage_level_id bigint, p_usage_status boolean, p_updated_by bigint, p_parent_question_id bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                        -- 1. Actualizar la tabla principal
                        UPDATE material_ballot_question
                        SET
                            "position" = p_position,
                            position_initial = p_position_initial,
                            type_text_id = p_category_id,
                            type_text_subcategory_id = p_subcategory_id,
                            level_id = p_level_id,
                            usage_level_id = p_usage_level_id,
                            usage_status = p_usage_status,
                            parent_question_id = p_parent_question_id,
                            updated_by = p_updated_by,
                            updated_at = NOW()
                        WHERE id = p_distribution_id;

                        -- 2. Eliminar lógicamente las subpreguntas anteriores
                        UPDATE material_ballot_subquestions
                        SET fl_status = FALSE, deleted_at = NOW()
                        WHERE material_ballot_question_id = p_distribution_id
                          AND fl_status = TRUE;

                        -- 3. Insertar las nuevas subpreguntas
                        INSERT INTO odiseo.material_ballot_subquestions (material_ballot_question_id, question_id, position, state, topic_id, course_id, subtopic_id)
                        SELECT
                            p_distribution_id,
                            (elem->>'question_id')::BIGINT,
                            row_number() OVER(ORDER BY (elem->>'position')::INT2 NULLS LAST)::INT2,
                            CASE WHEN (elem->>'question_id') IS NOT NULL THEN 'GENERATED'::varchar ELSE 'MISSING'::varchar END,
                            (elem->>'topic_id')::SMALLINT,
                            (elem->>'course_id')::SMALLINT,
                            (elem->>'subtopic_id')::SMALLINT
                        FROM LATERAL jsonb_array_elements(CASE WHEN jsonb_typeof(p_subquestion) = 'array' THEN p_subquestion ELSE '[]'::jsonb END) AS elem;
                    END;
                $$;


ALTER FUNCTION odiseo.fn_update_material_distribution_ballot_parent_question(p_distribution_id bigint, p_position smallint, p_position_initial smallint, p_category_id smallint, p_subcategory_id bigint, p_subquestion jsonb, p_level_id bigint, p_usage_level_id bigint, p_usage_status boolean, p_updated_by bigint, p_parent_question_id bigint) OWNER TO postgres;

--
