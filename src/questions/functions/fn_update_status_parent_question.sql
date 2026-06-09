-- Function: questions.fn_update_status_parent_question(jsonb, bigint, bigint)

--

CREATE FUNCTION questions.fn_update_status_parent_question(p_sub_question_ids jsonb, p_question_id bigint, p_user bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
            BEGIN
                -- Actualiza las subpreguntas en la tabla 'question'
                UPDATE questions.question
                SET
                    status = 'ARCH',
                    updated_by = p_user,
                    updated_at = NOW()
                WHERE id = ANY(SELECT jsonb_array_elements_text(p_sub_question_ids)::bigint);

                -- Actualiza la pregunta principal en la tabla 'parent_question'
                UPDATE questions.parent_question
                SET
                    status = 'ARCH', 
                    updated_by = p_user, 
                    updated_at = NOW()
                WHERE id = p_question_id;
            END;
            $$;


ALTER FUNCTION questions.fn_update_status_parent_question(p_sub_question_ids jsonb, p_question_id bigint, p_user bigint) OWNER TO postgres;

--
