-- Function: materials.fn_save_text_material_exam(bigint, bigint, bigint, bigint, jsonb, bigint)

--

CREATE FUNCTION materials.fn_save_text_material_exam(p_material_id bigint, p_parent_question_id bigint, p_level_id bigint, p_material_exam_parent_question_id bigint, p_subquestions jsonb, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
        /*
            Creación de función en base de datos
            Función para agregar textos en examen de un area dada

        ---------------------------------------------------------------------
        ------------------------ HISTORIAL DE CAMBIOS------------------------
        ---------------------------------------------------------------------

            Versión: 1.2
            Fecha: 2025-11-04
            Autor: Anderson Vallejo
            Descripción:
                Se guarda la pregunta en base al nuevo historico
                
        */
        UPDATE material_exam_parent_question
            SET
                parent_question_id = p_parent_question_id,
                current_level = p_level_id,
                subquestion = p_subquestions,
                updated_by = p_updated_by,
                updated_at = NOW()
        WHERE id = p_material_exam_parent_question_id;

        EXECUTE 'REFRESH MATERIALIZED VIEW odiseo.vm_material_exam_parent_question_with_subquestions';

        WITH current_exam_area_week AS (
            SELECT
                material_exam_area_week_id
            FROM material_exam_parent_question
            WHERE id = p_material_exam_parent_question_id
            LIMIT 1
        )
        INSERT INTO question_history_usage_exam_parent_question( material_exam_area_week_id, course_id, parent_question_id, question_id, automatic, created_at, created_by )
        SELECT material_exam_area_week_id, course_id, parent_question_id, question_id, FALSE, NOW(), p_updated_by
          FROM vm_material_exam_parent_question_with_subquestions
        WHERE 1 = 1
          AND material_exam_area_week_id IN ( SELECT material_exam_area_week_id FROM current_exam_area_week )
          AND parent_question_id = p_parent_question_id;
    END;
$$;


ALTER FUNCTION materials.fn_save_text_material_exam(p_material_id bigint, p_parent_question_id bigint, p_level_id bigint, p_material_exam_parent_question_id bigint, p_subquestions jsonb, p_updated_by bigint) OWNER TO postgres;

--
