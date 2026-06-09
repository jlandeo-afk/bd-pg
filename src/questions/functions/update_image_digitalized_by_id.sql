-- Function: questions.update_image_digitalized_by_id(bigint, bigint, jsonb)

--

CREATE FUNCTION questions.update_image_digitalized_by_id(p_id bigint, p_created_by bigint, p_image jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
                DECLARE 
                    v_employee_didi_question_id INT;
                    v_image JSONB;
                    v_code TEXT;
                    v_extension TEXT;
                    v_image_data TEXT;
                BEGIN
                    -- Obtener el ID de employee_didi_question
                    SELECT edq.id
                    INTO v_employee_didi_question_id
                    FROM questions.employee_didi_question edq
                    WHERE edq.question_id = p_id;

                    -- Iterar sobre cada elemento en el JSONB array
                    FOR v_image IN SELECT * FROM jsonb_array_elements(p_image)
                    LOOP
                        -- Extraer los valores del JSONB
                        v_code := v_image->>'code';
                        v_extension := v_image->>'extension';
                        v_image_data := v_image->>'image';

                        -- Insertar en employee_didi_question_image
                        INSERT INTO questions.employee_didi_question_image (
                            employee_didi_question_id,
                            code,
                            "extension",
                            image,
                            created_by,
                            created_at
                        ) VALUES (
                            v_employee_didi_question_id,
                            v_code,
                            v_extension,
                            v_image_data,
                            p_created_by,
                            NOW()
                        );
                    END LOOP;
                END;
                $$;


ALTER FUNCTION questions.update_image_digitalized_by_id(p_id bigint, p_created_by bigint, p_image jsonb) OWNER TO postgres;

--
