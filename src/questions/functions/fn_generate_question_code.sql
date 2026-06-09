-- Function: questions.fn_generate_question_code(integer, character varying)

--

CREATE FUNCTION questions.fn_generate_question_code(p_course_id integer, p_category character varying) RETURNS TABLE(full_code text, number_str text)
    LANGUAGE plpgsql
    AS $$
    DECLARE
        v_course_code VARCHAR;
        v_new_correlative BIGINT;
        v_formatted_number TEXT;
        v_apply_text BOOLEAN := false;
    BEGIN

        -- Definimos si aplica texto según la categoría
        IF p_category = 'T' THEN
            v_apply_text := true;
        END IF;
        -- Si es 'P' (o 'S'), v_apply_text se mantiene en false

        SELECT code INTO v_course_code 
        FROM course 
        WHERE id = p_course_id;

        -- Bloquea la fila específica del curso Y el tipo de texto, si existe
        PERFORM id 
        FROM question_correlative
        WHERE course_id = p_course_id AND apply_text = v_apply_text
        FOR NO KEY UPDATE; -- Lock a nivel de fila

        UPDATE question_correlative
        SET correlative = correlative + 1
        WHERE course_id = p_course_id AND apply_text = v_apply_text
        RETURNING correlative INTO v_new_correlative;

        IF NOT FOUND THEN
            -- Si no existe, lo insertamos con el valor correspondiente de apply_text
            INSERT INTO question_correlative (course_id, correlative, apply_text)
            VALUES (p_course_id, 1, v_apply_text)
            RETURNING correlative INTO v_new_correlative;
        END IF;

        IF LENGTH(v_new_correlative::TEXT) < 7 THEN
            v_formatted_number := LPAD(v_new_correlative::TEXT, 7, '0');
        ELSE
            v_formatted_number := '0' || v_new_correlative::TEXT;
        END IF;

        full_code := v_course_code || '-' || v_formatted_number;
        number_str := v_formatted_number;
        
        RETURN NEXT;
    END;
    $$;


ALTER FUNCTION questions.fn_generate_question_code(p_course_id integer, p_category character varying) OWNER TO postgres;

--
