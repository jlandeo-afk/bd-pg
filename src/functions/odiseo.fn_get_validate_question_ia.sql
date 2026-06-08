-- Function: odiseo.fn_get_validate_question_ia(bigint)

--

CREATE FUNCTION odiseo.fn_get_validate_question_ia(p_question_ia_id bigint) RETURNS TABLE(id bigint)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            SELECT DISTINCT
                qtia.id
            FROM question_teacher_ia qtia
            INNER JOIN alternative_questions_ia aqia ON qtia.id = aqia.question_ia_id
            WHERE qtia.id = p_question_ia_id
                AND (qtia.description IS NULL AND TRIM(qtia.description) = '<p></p>')
                OR (qtia.theoretical_basis IS NULL OR TRIM(qtia.theoretical_basis) = '<p></p>')
                OR (qtia.argumentation IS NULL OR TRIM(qtia.argumentation) = '<p></p>')
                OR (aqia.description IS NULL OR TRIM(aqia.description) = '<p></p>')
            ;
        END;
        $$;


ALTER FUNCTION odiseo.fn_get_validate_question_ia(p_question_ia_id bigint) OWNER TO postgres;

--
