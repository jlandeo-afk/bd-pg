-- Function: questions.fn_revised_diagrammed_question(integer, integer, character varying, jsonb, integer)

--

CREATE FUNCTION questions.fn_revised_diagrammed_question(p_id_question integer, p_field_diagram_id integer, p_content character varying, p_images jsonb, p_user integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_didi_question_id BIGINT;
                element JSONB;
            BEGIN
                    UPDATE questions.employee_didi_question_field
                    SET value = p_content, updated_by = p_user, updated_at = NOW()
                    WHERE id = p_field_diagram_id;

                    SELECT edq.id
                    INTO v_didi_question_id
                    FROM questions.employee_didi_question edq
                    WHERE edq.question_id = p_id_question
                    AND fl_status = TRUE
                    AND deleted_at IS NULL;

                    FOR element IN SELECT jsonb_array_elements(p_images) LOOP
                        INSERT INTO questions.employee_didi_question_field_image (
                            employee_didi_question_id, code, "extension", image, created_by, created_at
                        )
                        VALUES (
                            v_didi_question_id,
                            element->>'code',
                            element->>'extension',
                            element->>'image',
                            p_user,
                            NOW()
                        );
                    END LOOP;
                END;
            $$;


ALTER FUNCTION questions.fn_revised_diagrammed_question(p_id_question integer, p_field_diagram_id integer, p_content character varying, p_images jsonb, p_user integer) OWNER TO postgres;

--
