-- Function: odiseo.fn_validate_history_question(bigint, bigint)

--

CREATE FUNCTION odiseo.fn_validate_history_question(p_material_id bigint, p_question_id bigint) RETURNS TABLE(fl_validate boolean, v_message text)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_cycle_id BIGINT;
            v_cycle_description VARCHAR;
            v_cycle_start_date DATE;
            v_history JSONB;
            v_first_start_date DATE;
            v_last_start_date DATE;
            v_years_diff INTEGER;
            v_within_range BOOLEAN;
        BEGIN
            -- Obtener ciclo y universidad del material
            SELECT
                m.cycle_id, c.start_date
                INTO v_cycle_id, v_cycle_start_date
            FROM material m
            INNER JOIN cycle c ON m.cycle_id = c.id
            WHERE m.id = p_material_id
            LIMIT 1;

            -- Obtener los campos de pregunta
            SELECT
                fqvm.history INTO v_history
            FROM fn_question_verified_material(p_material_id) fqvm
            WHERE fqvm.id = p_question_id
            LIMIT 1;

            -- VALIDAR HISTORIAL
            IF v_history = '[]' THEN
                RETURN QUERY SELECT true, 'Si cumple, no tiene historial';
                RETURN;
            END IF;

            -- Obtener la fecha de inicio del primer historial
            SELECT (elem->>'start_date')::DATE
            INTO v_first_start_date
            FROM jsonb_array_elements(v_history) AS elem
            ORDER BY (elem->>'start_date')::DATE
            LIMIT 1;

            -- Validar si hay una diferencia de al menos 1 año
            SELECT DATE_PART('year', AGE(v_cycle_start_date, v_first_start_date))
            INTO v_years_diff;

            IF v_years_diff >= 1 THEN
                RETURN QUERY SELECT true, 'Si cumple, primera fecha tiene 1 año o más de diferencia';
                RETURN;
            END IF;

            -- Obtener la fecha de inicio del último historial
            SELECT
                (elem->>'start_date')::DATE, c.description
                INTO v_last_start_date, v_cycle_description
            FROM jsonb_array_elements(v_history) AS elem
            JOIN cycle c ON (elem->>'cycle_id')::INT = c.id
            ORDER BY (elem->>'start_date')::DATE DESC
            LIMIT 1;

            -- Calcular el rango de 3 semanas (21 días)
            v_within_range := CASE
                WHEN v_cycle_start_date < v_last_start_date THEN
                    v_cycle_start_date BETWEEN v_last_start_date - INTERVAL '21 days' AND v_last_start_date
                ELSE
                    v_last_start_date BETWEEN v_cycle_start_date - INTERVAL '21 days' AND v_cycle_start_date
            END;

            IF v_within_range THEN
                RETURN QUERY SELECT true, 'Si cumple, está dentro del rango de 21 días';
                RETURN;
            END IF;

            -- Si no cumplió ninguna condición anterior
            RETURN QUERY SELECT false, 'No cumple, esta siendo usado por el ciclo ' || v_cycle_description;
        END;
        $$;


ALTER FUNCTION odiseo.fn_validate_history_question(p_material_id bigint, p_question_id bigint) OWNER TO postgres;

--
