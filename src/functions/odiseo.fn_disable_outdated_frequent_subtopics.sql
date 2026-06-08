-- Function: odiseo.fn_disable_outdated_frequent_subtopics()

--

CREATE FUNCTION odiseo.fn_disable_outdated_frequent_subtopics() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
        WITH universities_without_san_marcos AS (
            SELECT *
            FROM origin_question oq
            WHERE oq.university_id <> 1
            AND oq.fl_status = TRUE
        ),
        ranked_questions AS (
            SELECT
                question_id,
                university_id,
                year,
                created_at,
                id,
                -- Ranking para elegir al "ganador"
                ROW_NUMBER() OVER (
                    PARTITION BY question_id
                    ORDER BY 
                        year::integer DESC,  -- Prioridad: Año numérico mayor
                        created_at DESC,     -- Desempate: Creación más reciente
                        id DESC
                ) as rn
            FROM universities_without_san_marcos
        ),
        questions_to_disable AS (
            -- Identifica los pares University-Subtopic que deben desactivarse
            SELECT DISTINCT
                rq.university_id,
                qs.subtopic_id
            FROM ranked_questions rq
            INNER JOIN question_subtopic qs ON rq.question_id = qs.question_id
            WHERE rq.rn = 1 
            AND qs.fl_status = TRUE
            -- Validación de antigüedad (> 10 años)
            AND (EXTRACT(YEAR FROM CURRENT_DATE) - rq.year::integer) > 10
        )
        -- EJECUCIÓN DEL UPDATE
        UPDATE frequent_university_subtopic fus
        SET is_frequent = FALSE
        FROM questions_to_disable qtd
        WHERE 
            fus.university_id = qtd.university_id 
            AND fus.subtopic_id = qtd.subtopic_id;
    END;
    $$;


ALTER FUNCTION odiseo.fn_disable_outdated_frequent_subtopics() OWNER TO postgres;

--
