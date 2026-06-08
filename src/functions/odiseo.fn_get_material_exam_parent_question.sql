-- Function: odiseo.fn_get_material_exam_parent_question(bigint)

--

CREATE FUNCTION odiseo.fn_get_material_exam_parent_question(p_material_exam_parent_question_id bigint) RETURNS TABLE(subquestions_amount smallint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    /*
        Creación de función en base de datos
        Función para obtener informacion de una fila de
        la tabla material_exam_parent_question

        ------------------------------------------------------------------------------------
        -- HISTORIAL DE CAMBIOS
        ------------------------------------------------------------------------------------

        Versión: 1.0
        Fecha: 2025-10-15
        Autor: Anderson Vallejo
        Descripción:
            Traer la cantidad de subpreguntas de un texto faltante o existente
    */

        RETURN QUERY
        SELECT
            JSONB_ARRAY_LENGTH(subquestion)::SMALLINT AS subquestion_amount
        FROM material_exam_parent_question
        WHERE id = p_material_exam_parent_question_id;
    END;
$$;


ALTER FUNCTION odiseo.fn_get_material_exam_parent_question(p_material_exam_parent_question_id bigint) OWNER TO postgres;

--
