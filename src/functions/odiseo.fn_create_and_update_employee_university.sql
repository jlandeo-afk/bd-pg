-- Function: odiseo.fn_create_and_update_employee_university(bigint, jsonb, bigint)

--

CREATE FUNCTION odiseo.fn_create_and_update_employee_university(p_employee_id bigint, p_universities_id jsonb, p_created_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_university_id SMALLINT;
            v_validate_university_id BIGINT;
        BEGIN
			-- Eliminar los que no se manda
			UPDATE odiseo.employee_university eud
			SET fl_status = false, deleted_by = p_created_by, deleted_at = NOW()
			WHERE eud.university_id NOT IN (SELECT value::SMALLINT FROM jsonb_array_elements_text(p_universities_id))
			AND eud.employee_id = p_employee_id;

            FOR v_university_id IN
                SELECT * FROM jsonb_array_elements(p_universities_id)
            LOOP
                SELECT eu.id INTO v_validate_university_id
                FROM odiseo.employee_university eu
                WHERE eu.university_id = v_university_id
                AND eu.employee_id = p_employee_id
                AND eu.fl_status IS TRUE LIMIT 1;

                IF v_validate_university_id IS NULL THEN
                    INSERT INTO odiseo.employee_university
                    (university_id, employee_id, created_by, created_at)
                    VALUES (v_university_id, p_employee_id, p_created_by, now());
                END IF;
            END LOOP;
        END;
        $$;


ALTER FUNCTION odiseo.fn_create_and_update_employee_university(p_employee_id bigint, p_universities_id jsonb, p_created_by bigint) OWNER TO postgres;

--
