-- Function: odiseo.fn_get_question_by_subtopic(bigint)

--

CREATE FUNCTION odiseo.fn_get_question_by_subtopic(p_subtopic_id bigint) RETURNS TABLE(id bigint, subtopics jsonb)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_question_ids BIGINT[] := '{}'; -- Inicializar como un arreglo vacío
        BEGIN
            -- Obtener IDs de las preguntas asociadas al subtema
            SELECT ARRAY (
                SELECT qs.question_id
                FROM question_subtopic qs
                WHERE qs.subtopic_id = p_subtopic_id AND qs.fl_status = TRUE
            ) INTO v_question_ids;

            -- Manejar el caso donde no haya resultados
            IF v_question_ids IS NULL OR cardinality(v_question_ids) = 0 THEN
                RETURN QUERY SELECT NULL::BIGINT, '[]'::JSONB; -- Especificar el tipo explícitamente
                RETURN;
            END IF;

            -- Retornar las preguntas y sus subtemas en formato JSONB
            RETURN QUERY
            SELECT
                q.id,
                jsonb_agg(
                    jsonb_build_object(
                        'id', s.id,
                        'code', s.code,
                        'name', s.name
                    )
                ) AS subtopics
            FROM
                question q
            LEFT JOIN question_subtopic qs
                ON q.id = qs.question_id
            LEFT JOIN subtopic s
                ON qs.subtopic_id = s.id
            WHERE
                q.id = ANY (v_question_ids)
            AND
				qs.fl_status = true
            GROUP BY
                q.id;
            END;
        $$;


ALTER FUNCTION odiseo.fn_get_question_by_subtopic(p_subtopic_id bigint) OWNER TO postgres;

--
