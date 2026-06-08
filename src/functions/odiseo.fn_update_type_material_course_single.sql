-- Function: odiseo.fn_update_type_material_course_single(bigint, boolean, character, bigint, integer, integer, jsonb, jsonb, bigint)

--

CREATE FUNCTION odiseo.fn_update_type_material_course_single(p_course_id bigint, p_is_generic boolean, p_type_question character, p_material_id bigint, p_amount integer, p_amount_text integer, p_subquestions jsonb, p_weeks_detail jsonb, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_tmc_id           BIGINT; 
                v_tmdt_id          BIGINT; 
                v_detail_id        BIGINT; 
                r_week             JSONB;
                v_active_weeks     INT[] := ARRAY[]::INT[];
            BEGIN
                -- =========================================================================
                -- 1. UPSERT MAESTRO (type_material_course)
                -- =========================================================================
                SELECT id INTO v_tmc_id 
                FROM type_material_course 
                WHERE type_material_id = p_material_id AND course_id = p_course_id;

                IF v_tmc_id IS NULL THEN
                    INSERT INTO type_material_course (
                        type_material_id, course_id, amount_question, amount_text, 
                        is_generic, is_generic_text, fl_status, created_by, created_at
                    ) VALUES (
                        p_material_id, p_course_id, 0, 0, 
                        true, true, true, p_updated_by, NOW()
                    ) RETURNING id INTO v_tmc_id;
                END IF;

                -- Actualizamos la configuración Maestra según el tipo
                IF p_type_question = 'P' THEN
                    UPDATE type_material_course 
                    SET is_generic = p_is_generic,
                        amount_question = CASE WHEN p_is_generic THEN COALESCE(p_amount, 0) ELSE 0 END,
                        fl_status = true, updated_at = NOW(), updated_by = p_updated_by
                    WHERE id = v_tmc_id;
                ELSIF p_type_question = 'T' THEN
                    UPDATE type_material_course 
                    SET is_generic_text = p_is_generic,
                        amount_text = CASE WHEN p_is_generic THEN COALESCE(p_amount_text, 0) ELSE 0 END,
                        fl_status = true, updated_at = NOW(), updated_by = p_updated_by
                    WHERE id = v_tmc_id;
                END IF;

                -- =========================================================================
                -- 2. LÓGICA DE DETALLES
                -- =========================================================================
                
                -- CASO A: ES GENÉRICO
                IF p_is_generic IS TRUE THEN
                    
                    IF p_type_question = 'P' THEN
                        -- Limpiar detalles P
                        UPDATE type_material_detail_courses
                        SET fl_status = false, deleted_at = NOW(), deleted_by = p_updated_by
                        WHERE type_material_course_id = v_tmc_id AND fl_status = true;
                        
                    ELSIF p_type_question = 'T' THEN
                        -- Limpiar detalles T
                        UPDATE type_material_detail_course_texts
                        SET fl_status = false, deleted_at = NOW(), deleted_by = p_updated_by
                        WHERE type_material_course_id = v_tmc_id AND fl_status = true;

                        -- Guardar Subpreguntas MAESTRAS
                        UPDATE type_text_material_type_course 
                        SET deleted_at = NOW(), deleted_by = p_updated_by
                        WHERE type_material_id = p_material_id AND course_id = p_course_id;

                        IF p_subquestions IS NOT NULL AND jsonb_array_length(p_subquestions) > 0 THEN
                            INSERT INTO type_text_material_type_course (
                                type_material_id, course_id, subquestion_amount, position, created_by, created_at
                            )
                            SELECT 
                                p_material_id, p_course_id, 
                                (sq->>'subquestion_amount')::SMALLINT, 
                                (sq->>'position')::SMALLINT, 
                                p_updated_by, NOW()
                            FROM jsonb_array_elements(p_subquestions) sq
                            ON CONFLICT (type_material_id, course_id, position) 
                            DO UPDATE SET 
                                subquestion_amount = EXCLUDED.subquestion_amount, 
                                deleted_at = NULL,
                                updated_at = NOW(), updated_by = p_updated_by;
                        END IF;
                    END IF;

                -- CASO B: ES PERSONALIZADO
                ELSE
                    -- Limpiar subpreguntas maestras si es Tipo Texto
                    IF p_type_question = 'T' THEN
                        UPDATE type_text_material_type_course 
                        SET deleted_at = NOW(), deleted_by = p_updated_by
                        WHERE type_material_id = p_material_id AND course_id = p_course_id;
                    END IF;

                    IF p_weeks_detail IS NOT NULL THEN
                        FOR r_week IN SELECT * FROM jsonb_array_elements(p_weeks_detail)
                        LOOP
                            v_active_weeks := array_append(v_active_weeks, (r_week->>'week')::INT);

                            SELECT id INTO v_tmdt_id 
                            FROM type_material_detail_template 
                            WHERE type_material_id = p_material_id 
                            AND week = (r_week->>'week')::INT 
                            AND fl_status = true LIMIT 1;

                            IF v_tmdt_id IS NULL THEN
                                INSERT INTO type_material_detail_template (
                                    type_material_id, week, created_by, created_at
                                ) VALUES (
                                    p_material_id, (r_week->>'week')::INT, p_updated_by, NOW()
                                ) RETURNING id INTO v_tmdt_id;
                            END IF;

                            IF v_tmdt_id IS NOT NULL THEN
                                
                                -- TIPO PREGUNTA ('P')
                                IF p_type_question = 'P' THEN
                                    UPDATE type_material_detail_courses
                                    SET amount_question = COALESCE((r_week->>'amount')::INT, 0),
                                        fl_status = true, updated_at = NOW(), updated_by = p_updated_by
                                    WHERE type_material_detail_template_id = v_tmdt_id 
                                    AND course_id = p_course_id
                                    RETURNING id INTO v_detail_id;

                                    IF v_detail_id IS NULL THEN
                                        INSERT INTO type_material_detail_courses (
                                            type_material_detail_template_id, type_material_course_id, course_id,
                                            amount_question, fl_status, created_by, created_at
                                        ) VALUES (
                                            v_tmdt_id, v_tmc_id, p_course_id,
                                            COALESCE((r_week->>'amount')::INT, 0),
                                            true, p_updated_by, NOW()
                                        ) RETURNING id INTO v_detail_id;
                                    END IF;

                                -- TIPO TEXTO ('T')
                                ELSIF p_type_question = 'T' THEN
                                    UPDATE type_material_detail_course_texts
                                    SET amount_text = COALESCE((r_week->>'amount_text')::INT, 0),
                                        fl_status = true, updated_at = NOW(), updated_by = p_updated_by
                                    WHERE type_material_detail_template_id = v_tmdt_id 
                                    AND course_id = p_course_id
                                    RETURNING id INTO v_detail_id;

                                    IF v_detail_id IS NULL THEN
                                        INSERT INTO type_material_detail_course_texts (
                                            type_material_detail_template_id, type_material_course_id, course_id,
                                            amount_text, fl_status, created_by, created_at
                                        ) VALUES (
                                            v_tmdt_id, v_tmc_id, p_course_id,
                                            COALESCE((r_week->>'amount_text')::INT, 0),
                                            true, p_updated_by, NOW()
                                        ) RETURNING id INTO v_detail_id;
                                    END IF;

                                    -- SUBPREGUNTAS DE TEXTO (Detalle)
                                    UPDATE type_material_detail_text_subquestions
                                    SET deleted_at = NOW(), deleted_by = p_updated_by
                                    WHERE type_material_detail_course_text_id = v_detail_id;

                                    IF jsonb_array_length(r_week->'subquestions') > 0 THEN
                                        INSERT INTO type_material_detail_text_subquestions (
                                            type_material_detail_course_text_id,
                                            subquestion_amount,
                                            position,
                                            created_by, created_at
                                        )
                                        SELECT 
                                            v_detail_id,
                                            (sq->>'subquestion_amount')::SMALLINT,
                                            (sq->>'position')::SMALLINT,
                                            p_updated_by, NOW()
                                        FROM jsonb_array_elements(r_week->'subquestions') sq;
                                    END IF;
                                END IF;
                            END IF;
                        END LOOP;

                        -- LIMPIEZA FINAL
                        IF p_type_question = 'P' THEN
                            UPDATE type_material_detail_courses tmdc
                            SET fl_status = false, deleted_at = NOW(), deleted_by = p_updated_by
                            FROM type_material_detail_template tmdt
                            WHERE tmdc.type_material_detail_template_id = tmdt.id
                            AND tmdc.type_material_course_id = v_tmc_id
                            AND tmdt.week <> ALL(v_active_weeks)
                            AND tmdc.fl_status = true;
                        ELSIF p_type_question = 'T' THEN
                            UPDATE type_material_detail_course_texts tmdct
                            SET fl_status = false, deleted_at = NOW(), deleted_by = p_updated_by
                            FROM type_material_detail_template tmdt
                            WHERE tmdct.type_material_detail_template_id = tmdt.id
                            AND tmdct.type_material_course_id = v_tmc_id
                            AND tmdt.week <> ALL(v_active_weeks)
                            AND tmdct.fl_status = true;
                        END IF;
                    END IF;
                END IF;
            END;
            $$;


ALTER FUNCTION odiseo.fn_update_type_material_course_single(p_course_id bigint, p_is_generic boolean, p_type_question character, p_material_id bigint, p_amount integer, p_amount_text integer, p_subquestions jsonb, p_weeks_detail jsonb, p_updated_by bigint) OWNER TO postgres;

--
