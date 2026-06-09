-- Function: materials.fn_remove_text_material_exam(bigint, bigint)

--

CREATE FUNCTION materials.fn_remove_text_material_exam(p_material_exam_parent_question_id bigint, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    /*
        Creación de función en base de datos
        Función para remover textos en examen de un area dada

        ------------------------------------------------------------------------------------
        -- HISTORIAL DE CAMBIOS
        ------------------------------------------------------------------------------------

        Versión: 1.1
        Fecha: 2025-11-03
        Autor: Anderson Vallejo
        Descripción:
            Remover el texto seleccionado y sus subpreguntas en una de
            las filas de la tabla material_exam_parent_question
            
    */
        WITH exam_parent_question AS (
            SELECT
                material_exam_area_week_id,
                parent_question_id,
                question_history_id,
                COALESCE(
                    (
                        SELECT JSONB_AGG(
                            (
                                SELECT JSONB_OBJECT_AGG(k, NULL)
                                FROM JSONB_OBJECT_KEYS(elem) AS k
                            )
                        )
                        FROM JSONB_ARRAY_ELEMENTS(subquestion) AS elem
                    ),
                    '[]'::JSONB
                ) AS empty_subquestion
            FROM material_exam_parent_question
            WHERE id = p_material_exam_parent_question_id
            LIMIT 1
        ), deactive_question_history_in_text_exam AS (
            UPDATE question_history_usage_exam_parent_question
               SET
                  updated_at = NOW(),
                  updated_by = p_updated_by
            WHERE 1 = 1
              AND updated_at IS NULL
              AND material_exam_area_week_id IN ( SELECT material_exam_area_week_id FROM exam_parent_question )
              AND parent_question_id IN ( SELECT parent_question_id FROM exam_parent_question )
        )
        UPDATE material_exam_parent_question
            SET
                parent_question_id = NULL,
                position = NULL,
                random = NULL,
                subquestion = ( SELECT empty_subquestion FROM exam_parent_question ),
                question_history_id = NULL,
                updated_at = NOW(),
                updated_by = p_updated_by
        WHERE id = p_material_exam_parent_question_id;
    END;
$$;


ALTER FUNCTION materials.fn_remove_text_material_exam(p_material_exam_parent_question_id bigint, p_updated_by bigint) OWNER TO postgres;

--
