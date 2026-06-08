-- Function: odiseo.fn_save_level_syllabus(smallint, bigint, jsonb, jsonb, jsonb, jsonb, jsonb, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_save_level_syllabus(p_university_id smallint, p_cycle_id bigint, p_week_ids jsonb, p_headquarters_ids jsonb, p_course_ids jsonb, p_detail_level_syllabus jsonb, p_detail_level_syllabus_parent jsonb, p_created_by bigint, p_company_id bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_level_syllabus_id BIGINT;
                v_level_syllabus_week_id BIGINT;
                v_headquarter JSONB;
                v_course JSONB;
                v_week_id JSONB;
                v_detail_level_syllabus JSONB;
				v_detail_level_syllabus_parent JSONB;
				v_detail_type_text_syllabus JSONB;
                v_detail_level_syllabus_weeks_id BIGINT;
				v_detail_level_syllabus_weeks_parent_id BIGINT;
            BEGIN
                -- Itera sobre cada sede en el array JSONB de sedes
                FOR v_headquarter IN SELECT * FROM jsonb_array_elements(p_headquarters_ids) LOOP
                    -- Itera sobre cada curso en el array JSONB de cursos
                    FOR v_course IN SELECT * FROM jsonb_array_elements(p_course_ids) LOOP
                        -- Itera sobre cada semana en el array JSONB de semanas
                        FOR v_week_id IN SELECT * FROM jsonb_array_elements(p_week_ids) LOOP                      

							-- Verificar si ya existe un level_syllabus con el university_id, cycle_id, course_id y headquarter_id
                            SELECT ls.id
                            INTO v_level_syllabus_id
                            FROM level_syllabus ls
                            WHERE ls.university_id = p_university_id
                            AND ls.cycle_id = p_cycle_id
                            AND ls.course_id = (v_course::TEXT)::SMALLINT
                            AND ls.headquarter_id = (v_headquarter::TEXT)::SMALLINT
                            AND ls.fl_status = TRUE;

                            -- Si no existe, inserta en level_syllabus y obtiene el id
                            IF v_level_syllabus_id IS NULL THEN
                                INSERT INTO level_syllabus (university_id, cycle_id, course_id, headquarter_id, created_by, created_at, company_id)
                                VALUES (p_university_id, p_cycle_id, (v_course::TEXT)::SMALLINT, (v_headquarter::TEXT)::SMALLINT, p_created_by, now(), p_company_id)
                                RETURNING id INTO v_level_syllabus_id;
                            END IF;

                            -- Verifica si ya existe un level_syllabus_week con el level_syllabus_id y week
                            SELECT lsw.id
                            INTO v_level_syllabus_week_id
                            FROM level_syllabus_weeks lsw
                            WHERE lsw.level_syllabus_id = v_level_syllabus_id
                            AND lsw.week = (v_week_id::TEXT)::SMALLINT
                            AND lsw.fl_status = TRUE
                            AND lsw.deleted_at IS NULL;

                            -- Si no existe, inserta en level_syllabus_weeks y obtiene el id
                            IF v_level_syllabus_week_id IS NULL THEN
                                INSERT INTO level_syllabus_weeks (level_syllabus_id, week, created_by, created_at, company_id)
                                VALUES (v_level_syllabus_id, (v_week_id::TEXT)::SMALLINT, p_created_by, now(), p_company_id)
                                RETURNING id INTO v_level_syllabus_week_id;
                            END IF;

							
                            -- Marcar como eliminados los registros que no están en p_detail_level_syllabus
                            UPDATE detail_level_syllabus_weeks
                            SET fl_status = FALSE,
                                deleted_by = p_created_by,
                                deleted_at = now()
                            WHERE level_syllabus_weeks_id = v_level_syllabus_week_id
                            AND fl_status = TRUE
                            AND (type_material_id, level_id, type_question) NOT IN (
                                SELECT (value->>'type_material_id')::SMALLINT,
                                        (value->>'level_id')::SMALLINT,
                                        value->>'type_question'
                                FROM jsonb_array_elements(p_detail_level_syllabus)
                            );

                            -- Itera sobre el detalle de nivel del syllabus
                            FOR v_detail_level_syllabus IN SELECT * FROM jsonb_array_elements(p_detail_level_syllabus) LOOP
                                -- Verificar si ya existe ese registro de detail_level_syllabus_weeks
                                SELECT dlsw.id
                                INTO v_detail_level_syllabus_weeks_id
                                FROM detail_level_syllabus_weeks dlsw
                                WHERE dlsw.level_syllabus_weeks_id = v_level_syllabus_week_id
                                AND dlsw.type_material_id = (v_detail_level_syllabus->>'type_material_id')::SMALLINT
                                AND dlsw.level_id = (v_detail_level_syllabus->>'level_id')::SMALLINT
                                AND dlsw.type_question = v_detail_level_syllabus->>'type_question'
                                AND dlsw.fl_status = TRUE;

                                -- Si no existe, insertar
                                IF v_detail_level_syllabus_weeks_id IS NULL THEN
                                    IF COALESCE((v_detail_level_syllabus->>'total_questions')::INTEGER, 0) > 0 THEN
                                        INSERT INTO detail_level_syllabus_weeks (
                                            level_syllabus_weeks_id, type_material_id, level_id, type_question, number_questions, created_by, created_at, company_id
                                        )
                                        VALUES (
                                            v_level_syllabus_week_id,
                                            (v_detail_level_syllabus->>'type_material_id')::SMALLINT,
                                            (v_detail_level_syllabus->>'level_id')::SMALLINT,
                                            v_detail_level_syllabus->>'type_question',
                                            (v_detail_level_syllabus->>'total_questions')::INTEGER,
                                            p_created_by,
                                            now(),
											p_company_id
                                        );
                                    END IF;
                                ELSE
                                    -- Si existe, actualizar
                                    UPDATE detail_level_syllabus_weeks
                                    SET number_questions = (v_detail_level_syllabus->>'total_questions')::INTEGER,
                                        updated_by = p_created_by,
                                        updated_at = now()
                                    WHERE id = v_detail_level_syllabus_weeks_id;
                                END IF;
                            END LOOP;


							--	NIVELES PARA LOS TEXTOS						
							UPDATE detail_level_syllabus_weeks_parents
                            SET fl_status = FALSE,
                                deleted_by = p_created_by,
                                deleted_at = now()
                            WHERE level_syllabus_weeks_id = v_level_syllabus_week_id
                            AND fl_status = TRUE
                            AND (level_id, type_material_id) NOT IN (
                                SELECT (value->>'level_id')::SMALLINT,
									   (value->>'type_material_id')::SMALLINT
                                FROM jsonb_array_elements(p_detail_level_syllabus_parent)
                            );

							FOR v_detail_level_syllabus_parent IN SELECT * FROM jsonb_array_elements(p_detail_level_syllabus_parent) LOOP
                                -- Verificar si ya existe ese registro de detail_level_syllabus_weeks
                                 	SELECT dlswp.id
									INTO v_detail_level_syllabus_weeks_parent_id
									FROM detail_level_syllabus_weeks_parents dlswp
									WHERE dlswp.level_syllabus_weeks_id = v_level_syllabus_week_id
									AND dlswp.level_id = (v_detail_level_syllabus_parent->>'level_id')::SMALLINT
									AND dlswp.type_material_id = (v_detail_level_syllabus_parent->>'type_material_id')::SMALLINT
									AND dlswp.fl_status = TRUE;

                                -- Si no existe, insertar
                                IF v_detail_level_syllabus_weeks_parent_id IS NULL THEN
                                    IF COALESCE((v_detail_level_syllabus_parent->>'total_text')::INTEGER, 0) > 0 THEN
										INSERT INTO detail_level_syllabus_weeks_parents (
                                            level_syllabus_weeks_id,
											level_id,
											number_of_passages,
											type_material_id,
											created_by, 
											created_at,
											company_id
                                        )
                                        VALUES (
                                            v_level_syllabus_week_id,
                                            (v_detail_level_syllabus_parent->>'level_id')::SMALLINT,
                                            (v_detail_level_syllabus_parent->>'total_text')::INTEGER,
											(v_detail_level_syllabus_parent->>'type_material_id')::INTEGER,
                                            p_created_by,
                                            now(),
											p_company_id
                                        );
                                    END IF;
                                ELSE
                                    -- Si existe, actualizar
                                    UPDATE detail_level_syllabus_weeks_parents
                                    SET number_of_passages = (v_detail_level_syllabus_parent->>'total_text')::INTEGER,
                                        updated_by = p_created_by,
                                        updated_at = now()
                                    WHERE id = v_detail_level_syllabus_weeks_parent_id;
                                END IF;
                            END LOOP;


                        END LOOP;
                    END LOOP;
                END LOOP;
            END;
        $$;


ALTER FUNCTION odiseo.fn_save_level_syllabus(p_university_id smallint, p_cycle_id bigint, p_week_ids jsonb, p_headquarters_ids jsonb, p_course_ids jsonb, p_detail_level_syllabus jsonb, p_detail_level_syllabus_parent jsonb, p_created_by bigint, p_company_id bigint) OWNER TO postgres;

--
