-- Function: odiseo.fn_create_material(bigint, smallint, smallint, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_create_material(p_cycle_id bigint, p_university_id smallint, p_headquearters_id smallint, p_created_by bigint, p_company_id bigint) RETURNS TABLE(material_id bigint, v_validated integer)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_validate BIGINT;
            v_material_id BIGINT;
            v_headquarters_classroom_id BIGINT;
        BEGIN
            SELECT id INTO v_headquarters_classroom_id FROM headquarters_classroom
            WHERE headquarters_id = p_headquearters_id AND classroom_id = 1 AND fl_status = true LIMIT 1;

            IF v_headquarters_classroom_id IS NOT NULL THEN
                SELECT id INTO v_validate FROM material
                WHERE cycle_id = p_cycle_id
                AND university_id = p_university_id
                AND headquarte_id = p_headquearters_id
                AND headquarters_classroom_id = v_headquarters_classroom_id
                AND fl_status = true LIMIT 1;

                IF v_validate IS NULL THEN
                    -- Creación del material
                    INSERT INTO material (cycle_id, university_id, headquarte_id, headquarters_classroom_id, created_by, created_at, company_id)
                    VALUES (p_cycle_id, p_university_id, p_headquearters_id, v_headquarters_classroom_id, p_created_by, now(), p_company_id)
                    RETURNING id INTO v_material_id;

                    RETURN QUERY SELECT v_material_id, 0::INT;
                ELSE
                    RETURN QUERY SELECT 0::BIGINT, 1::INT;
                END IF;
            ELSE
                RETURN QUERY SELECT 0::BIGINT, 2::INT;
            END IF;
        END;
        $$;


ALTER FUNCTION odiseo.fn_create_material(p_cycle_id bigint, p_university_id smallint, p_headquearters_id smallint, p_created_by bigint, p_company_id bigint) OWNER TO postgres;

--
