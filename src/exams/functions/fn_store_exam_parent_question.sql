-- Function: exams.fn_store_exam_parent_question(bigint, jsonb, bigint)

--

CREATE FUNCTION exams.fn_store_exam_parent_question(p_week_type_material_id bigint, p_parent_questions jsonb, p_created_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
        DROP TABLE IF EXISTS temp_cycle_and_university_in_material;
        CREATE TEMP TABLE temp_cycle_and_university_in_material (
            cycle_id BIGINT,
            university_id BIGINT,
            headquarte_id BIGINT
        ) ON COMMIT DROP;
        WITH get_material_id AS (
            SELECT
                dtw.material_id
            FROM detail_week_type_mat dtw
            WHERE dtw.id = p_week_type_material_id
            GROUP BY dtw.material_id
        ), cycle_and_university_in_material AS (
            SELECT
                m.cycle_id,
                m.university_id,
                m.headquarte_id
            FROM material m
            WHERE m.id IN (SELECT material_id FROM get_material_id)
        )
        INSERT INTO temp_cycle_and_university_in_material
        SELECT * FROM cycle_and_university_in_material;
        
        DROP TABLE IF EXISTS temp_parent_questions;
        CREATE TEMP TABLE temp_parent_questions (
            area_id SMALLINT,
            course_id SMALLINT,
            parent_question_id INTEGER,
            absolute_position SMALLINT,
            expected_level SMALLINT,
            current_level SMALLINT,
            random BOOLEAN,
            subquestions JSONB,
            created_by BIGINT,
            created_at TIMESTAMP
        ) ON COMMIT DROP;
        WITH parent_questions AS (
            SELECT
                (e->>'area_id')::SMALLINT AS area_id,
                (e->>'course_id')::SMALLINT AS course_id,
                (e->>'parent_question_id')::INT AS parent_question_id,
                (e->>'position')::SMALLINT AS absolute_position, 
                (e->>'level')::INT AS expected_level,
                CASE
                    WHEN (e->>'parent_question_id')::INT IS NULL THEN NULL
                    ELSE (e->>'level')::INT
                END AS current_level,
                (e->>'random')::BOOLEAN AS random,
                (e->>'subquestions')::JSONB AS subquestions,
                p_created_by AS created_by,
                NOW() AS created_at
            FROM JSONB_ARRAY_ELEMENTS(p_parent_questions) AS e
        ) 
        INSERT INTO temp_parent_questions
        SELECT * FROM parent_questions;
    
        DROP TABLE IF EXISTS temp_register_material_exam_area_weeks;
        CREATE TEMP TABLE temp_register_material_exam_area_weeks (
            id BIGINT,
            area_id SMALLINT,
            created_by BIGINT,
            created_at TIMESTAMP
        ) ON COMMIT DROP;
        WITH register_material_exam_area_week AS (
            INSERT INTO material_exam_area_week AS meaw( week_type_material_id, area_id, created_by, created_at )
            SELECT p_week_type_material_id, area_id, p_created_by, NOW() FROM temp_parent_questions GROUP BY area_id
            ON CONFLICT ON CONSTRAINT uq_week_ty_mat_id_area_id
            DO UPDATE
                SET
                    week_type_material_id = EXCLUDED.week_type_material_id,
                    area_id = EXCLUDED.area_id
            RETURNING meaw.id, meaw.area_id
        )
        INSERT INTO temp_register_material_exam_area_weeks
        SELECT * FROM register_material_exam_area_week;

        DROP TABLE IF EXISTS temp_subquestions_extracted;
        CREATE TEMP TABLE temp_subquestions_extracted (
            question_id BIGINT
        ) ON COMMIT DROP;
        WITH subquestions_to_extract AS (
            SELECT
                JSONB_ARRAY_ELEMENTS(pss.subquestions) AS subquestion
            FROM temp_parent_questions pss
            WHERE pss.parent_question_id IS NOT NULL
        ), subquestions_extracted AS (
            SELECT
                (pet.subquestion->>'question_id')::INTEGER AS question_id
            FROM subquestions_to_extract pet
            WHERE (pet.subquestion->>'question_id')::INTEGER IS NOT NULL
        )
        INSERT INTO temp_subquestions_extracted
        SELECT * FROM subquestions_extracted;

        UPDATE material_exam_parent_question epq
           SET question_history_id = NULL
        WHERE 1 = 1
          AND epq.id IN  ( SELECT rg.id FROM temp_register_material_exam_area_weeks rg )
          AND question_history_id IS NOT NULL;

        DROP TABLE IF EXISTS temp_insert_parent_questions;
        CREATE TEMP TABLE temp_insert_parent_questions (
            id BIGINT
        ) ON COMMIT DROP;
        WITH insert_parent_questions AS (
            INSERT INTO
                material_exam_parent_question AS mepq
                (
                    material_exam_area_week_id,
                    course_id,
                    parent_question_id,
                    position,
                    expected_level,
                    current_level, 
                    random, 
                    subquestion,
                    created_by,
                    created_at
                )
            SELECT
                ta.id,
                pmh.course_id,
                pmh.parent_question_id,
                pmh.absolute_position, 
                pmh.expected_level,
                pmh.current_level,
                pmh.random, 
                pmh.subquestions,
                p_created_by,
                NOW()
            FROM temp_parent_questions pmh
            JOIN temp_register_material_exam_area_weeks ta ON ta.area_id = pmh.area_id
            ON CONFLICT ON CONSTRAINT uq_parent_question_in_area
            DO UPDATE
                SET
                    material_exam_area_week_id = EXCLUDED.material_exam_area_week_id,
                    course_id = EXCLUDED.course_id,
                    parent_question_id = EXCLUDED.parent_question_id,
                    position = EXCLUDED.position, 
                    random = EXCLUDED.random,
                    expected_level = EXCLUDED.expected_level,
                    current_level = EXCLUDED.current_level,
                    subquestion = EXCLUDED.subquestion,
                    created_by = p_created_by,
                    created_at = NOW(),
                    updated_by = NULL,
                    updated_at = NULL,
                    deleted_by = NULL,
                    deleted_at = NULL
            RETURNING mepq.id
        )
        INSERT INTO temp_insert_parent_questions
        SELECT id FROM insert_parent_questions;

        /* Desactivar las fila de material_exam_parent_question que ya no se usaran */
        UPDATE material_exam_parent_question mn
            SET
                parent_question_id = NULL,
                subquestion = NULL,
                question_history_id = NULL,
                deleted_at = NOW(),
                deleted_by = p_created_by
        WHERE 1 = 1
          AND material_exam_area_week_id IN ( SELECT rk.id FROM temp_register_material_exam_area_weeks rk )
          AND mn.id NOT IN (SELECT iqs.id FROM temp_insert_parent_questions iqs);

        /* Borrar historico */
        UPDATE question_history_usage_exam_parent_question
            SET
                updated_at = NOW(),
                updated_by = p_created_by
        WHERE 1 = 1
          AND material_exam_area_week_id IN ( SELECT rk.id FROM temp_register_material_exam_area_weeks rk )
          AND updated_at IS NULL;

        EXECUTE 'REFRESH MATERIALIZED VIEW odiseo.vm_material_exam_parent_question_with_subquestions';

        /* Crear historico */
        INSERT INTO question_history_usage_exam_parent_question( material_exam_area_week_id, course_id, parent_question_id, question_id, created_at, created_by )
        SELECT material_exam_area_week_id, course_id, parent_question_id, question_id, NOW(), p_created_by
        FROM vm_material_exam_parent_question_with_subquestions
        WHERE 1 = 1
          AND material_exam_area_week_id IN ( SELECT rm.id FROM temp_register_material_exam_area_weeks rm );
    END;
$$;


ALTER FUNCTION exams.fn_store_exam_parent_question(p_week_type_material_id bigint, p_parent_questions jsonb, p_created_by bigint) OWNER TO postgres;

--
