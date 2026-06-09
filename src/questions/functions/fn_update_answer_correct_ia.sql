-- Function: questions.fn_update_answer_correct_ia(bigint, bigint, boolean, bigint)

--

CREATE FUNCTION questions.fn_update_answer_correct_ia(p_question_ia_id bigint, p_answer_id bigint, p_fl_text boolean, p_updated_by bigint) RETURNS TABLE(question_ia_id bigint)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            WITH get_alternative_correct AS ( -- Trae la data de la alternativa correcta
                SELECT
                    aqia.description
                FROM alternative_questions_ia aqia
                WHERE aqia.id = p_answer_id
                    AND aqia.question_ia_id = p_question_ia_id
            ), update_alternative AS ( -- Editar la alternativa correcta
                UPDATE question_teacher_ia qtia
                SET
                    answer_id = p_answer_id,
                    answer_description = CASE
                        WHEN p_fl_text IS TRUE THEN (SELECT gac.description FROM get_alternative_correct gac)
                        ELSE qtia.description
                    END,
                    updated_by = p_updated_by,
                    updated_at = NOW()
                WHERE qtia.id = p_question_ia_id
                RETURNING qtia.id AS question_ia_id
            )
            SELECT ua.question_ia_id FROM update_alternative ua;
        END;
        $$;


ALTER FUNCTION questions.fn_update_answer_correct_ia(p_question_ia_id bigint, p_answer_id bigint, p_fl_text boolean, p_updated_by bigint) OWNER TO postgres;

--
