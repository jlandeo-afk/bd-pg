-- Function: odiseo.fn_insert_or_update_distribution_levels_exam(bigint, bigint, jsonb, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_insert_or_update_distribution_levels_exam(p_cycle_id bigint, p_type_material_id bigint, p_exam_materials jsonb, p_user bigint, p_company_id bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_exam_material JSONB;
            v_exam_area JSONB;
            v_exam_material_config_id BIGINT;
            v_exam_material_config_area_course_id BIGINT;
            v_amount_type_d INTEGER;
			vp_amount_type_d INTEGER;
            v_level JSONB;
            v_exam_material_config_area_course_level_id BIGINT;
        BEGIN
            -- Buscar configuración de material de examen existente
            SELECT
                emc.id INTO v_exam_material_config_id
            FROM exam_material_configurations emc
            WHERE emc.cycle_id = p_cycle_id
                AND emc.type_material_id = p_type_material_id
                AND emc.fl_status = TRUE
                AND emc.company_id = p_company_id
            LIMIT 1;

            -- Si no encuentra insertar nueva configuración de material de examen
            IF v_exam_material_config_id IS NULL THEN
                INSERT INTO exam_material_configurations (
                    type_material_id,
                    cycle_id,
                    company_id,
                    created_by,
                    created_at
                )
                VALUES (
                    p_type_material_id,
                    p_cycle_id,
                    p_company_id,
                    p_user,
                    NOW()
                )
                RETURNING id INTO v_exam_material_config_id;
            END IF;

            -- Iterar los cursos de distribución de niveles
            FOR v_exam_material IN SELECT * FROM jsonb_array_elements(p_exam_materials) LOOP
                -- Iterar sobre las áreas del examen
                FOR v_exam_area IN SELECT * FROM jsonb_array_elements(v_exam_material->'exam_area') LOOP
					vp_amount_type_d := (v_exam_area->>'amount_type_d')::INT;

                    -- Buscar configuración de área y curso existente
                    SELECT
                        emcac.id, emcac.amount_type_d INTO v_exam_material_config_area_course_id, v_amount_type_d
                    FROM exam_material_config_area_courses emcac
                    WHERE emcac.exam_material_config_id = v_exam_material_config_id
                        AND emcac.course_id = (v_exam_material->'course_id')::BIGINT
                        AND emcac.exam_area_id = (v_exam_area->>'exam_area_id')::BIGINT
                        AND emcac.fl_status IS TRUE
                    LIMIT 1;
                    
                    IF (v_exam_material->'apply_text')::BOOL IS TRUE THEN
                        FOR v_level IN SELECT * FROM jsonb_array_elements(v_exam_area->'levels') LOOP
                            INSERT INTO type_text_exam_material_configuration (
                                exam_material_config_id,
                                course_id,
                                area_id,
                                type_text_level_id,
                                text_amount,
                                created_at,
                                created_by
                            )
                            VALUES (
                                v_exam_material_config_id,
                                (v_exam_material->'course_id')::BIGINT,
                                (v_exam_area->>'exam_area_id')::BIGINT,
                                (v_level->'id')::SMALLINT,
                                (v_level->'amount_question')::SMALLINT,
                                NOW(),
                                p_user
                            )
                            ON CONFLICT (exam_material_config_id, course_id, area_id, type_text_level_id)
                            DO UPDATE SET
                                text_amount = (v_level->'amount_question')::SMALLINT,
                                updated_at = NOW(),
                                updated_by = p_user;
                        END LOOP;
                    ELSE
                        -- Si no existe insertar nueva configuración de área y curso
                        IF v_exam_material_config_area_course_id IS NULL THEN
                            INSERT INTO exam_material_config_area_courses (
                                exam_material_config_id,
                                course_id,
                                exam_area_id,
                                amount_type_d,
                                created_by,
                                created_at
                            )
                            VALUES (
                                v_exam_material_config_id,
                                (v_exam_material->'course_id')::BIGINT,
                                (v_exam_area->>'exam_area_id')::BIGINT,
                                vp_amount_type_d,
                                p_user,
                                NOW()
                            )
                            RETURNING id INTO v_exam_material_config_area_course_id;
                        ELSE
                            IF v_amount_type_d IS DISTINCT FROM vp_amount_type_d THEN
                                UPDATE exam_material_config_area_courses
                                SET
                                    amount_type_d = vp_amount_type_d,
                                    updated_by = p_user,
                                    updated_at = NOW()
                                WHERE id = v_exam_material_config_area_course_id;
                            END IF;
                        END IF;
    
                        -- Procesar niveles del JSONB
                        FOR v_level IN SELECT * FROM jsonb_array_elements(v_exam_area->'levels') LOOP
                            -- Buscar configuración de nivel existente
                            SELECT
                                emcacl.id INTO v_exam_material_config_area_course_level_id
                            FROM exam_material_config_area_course_levels emcacl
                            WHERE emcacl.exam_material_config_area_course_id = v_exam_material_config_area_course_id
                                AND emcacl.level_id = (v_level->'id')::BIGINT
                                AND emcacl.fl_status = TRUE
                            LIMIT 1;
    
                            -- Insertar nueva configuración de nivel si tiene preguntas
                            IF v_exam_material_config_area_course_level_id IS NULL THEN
                                IF COALESCE((v_level->'amount_question')::INTEGER, 0) > 0 THEN
                                    INSERT INTO exam_material_config_area_course_levels (
                                        exam_material_config_area_course_id,
                                        level_id,
                                        amount_question,
                                        created_by,
                                        created_at
                                    )
                                    VALUES (
                                        v_exam_material_config_area_course_id,
                                        (v_level->'id')::BIGINT,
                                        (v_level->'amount_question')::INTEGER,
                                        p_user,
                                        NOW()
                                    );
                                END IF;
                            ELSE
                                -- Actualizar configuración de nivel existente
                                UPDATE exam_material_config_area_course_levels
                                SET
                                    amount_question = (v_level->'amount_question')::INTEGER,
                                    updated_by = p_user,
                                    updated_at = NOW()
                                WHERE id = v_exam_material_config_area_course_level_id
                                    AND fl_status = TRUE;
    
                                IF COALESCE((v_level->'amount_question')::INTEGER, 0) = 0 THEN
                                    UPDATE exam_material_config_area_course_levels
                                    SET deleted_at = NOW(), deleted_by = p_user, fl_status = false where id = v_exam_material_config_area_course_level_id;
                                END IF;
                            END IF;
                        END LOOP;
                    END IF;
                END LOOP;
            END LOOP;

            RETURN;
        END;
        $$;


ALTER FUNCTION odiseo.fn_insert_or_update_distribution_levels_exam(p_cycle_id bigint, p_type_material_id bigint, p_exam_materials jsonb, p_user bigint, p_company_id bigint) OWNER TO postgres;

--
