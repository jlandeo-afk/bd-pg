-- Function: materials.fn_create_type_material_course(smallint, jsonb, bigint)

--

CREATE FUNCTION materials.fn_create_type_material_course(p_type_material_id smallint, p_data_courses jsonb, p_created_by bigint) RETURNS smallint
    LANGUAGE plpgsql
    AS $$
			DECLARE
                v_type_matertial_course JSONB;
                v_type_material_course BIGINT;
                v_amount_question INT;
            BEGIN
                FOR v_type_matertial_course IN SELECT jsonb_array_elements(p_data_courses) LOOP
                    UPDATE materials.type_material_course SET amount_question = (v_type_matertial_course->>'amount_question')::INT, updated_by = p_created_by, updated_at = now()
                    WHERE course_id = (v_type_matertial_course->>'course_id')::SMALLINT AND type_material_id = p_type_material_id AND fl_status = true
                    RETURNING id INTO v_type_material_course;
                END LOOP;

                SELECT SUM(amount_question) INTO v_amount_question FROM materials.type_material_course WHERE type_material_id = p_type_material_id AND fl_status = true;

                IF v_amount_question <> 0 THEN
                    UPDATE materials.type_material SET amount_question = v_amount_question, updated_by = p_created_by, updated_at = now()
                    WHERE id = p_type_material_id;
                END IF;

                RETURN p_type_material_id;

            END;
            $$;


ALTER FUNCTION materials.fn_create_type_material_course(p_type_material_id smallint, p_data_courses jsonb, p_created_by bigint) OWNER TO postgres;

--
