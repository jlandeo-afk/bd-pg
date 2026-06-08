-- Function: odiseo.fn_edit_syllabus(bigint, jsonb, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_edit_syllabus(p_syllabus_id bigint, p_syllabus jsonb, p_company_id bigint, p_updated_by bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_syllabus JSONB;
            v_syllabus_topic_id BIGINT;
            v_weeks JSONB;
            v_syllabus_topic_week_id BIGINT;
            v_subtopics JSONB;
            v_syllabus_detail_subtopic_id BIGINT;
            v_type_materials JSONB;
            v_syllabus_subtopic_type_material BIGINT;
            v_total_type_material_amount INT;
            v_total_questions_amount INT;
        BEGIN
            -- Se eliminan todos los temas del temario que no se mandaron
            UPDATE syllabus_topic
            SET fl_status = false, deleted_by = p_updated_by, deleted_at = now()
            WHERE syllabus_id = p_syllabus_id
            AND company_id = p_company_id
            AND topic_id NOT IN (
                SELECT (jsonb_array_elements(p_syllabus)->>'topic_id')::SMALLINT
            );

            -- Se recorre todos los temas
            FOR v_syllabus IN SELECT jsonb_array_elements(p_syllabus) LOOP
                -- Se busca el tema para ver si existe
                SELECT id INTO v_syllabus_topic_id FROM syllabus_topic
                WHERE syllabus_id = p_syllabus_id AND topic_id = (v_syllabus->>'topic_id')::SMALLINT
                AND company_id = p_company_id
                AND fl_status = true LIMIT 1;

                -- Si no existe se crea
                IF v_syllabus_topic_id IS NULL THEN
                    INSERT INTO syllabus_topic (syllabus_id, topic_id, created_by, created_at , company_id)
                    VALUES (p_syllabus_id, (v_syllabus->>'topic_id')::SMALLINT, p_updated_by, now(), p_company_id)
                    RETURNING id INTO v_syllabus_topic_id;
                END IF;

                -- Se eliminan todos las semanas del temario que no se mandaron
                UPDATE syllabus_topic_week
                SET fl_status = false, deleted_by = p_updated_by, deleted_at = now()
                WHERE syllabus_topic_id = v_syllabus_topic_id
                AND company_id = p_company_id
                AND week NOT IN (
                    SELECT (jsonb_array_elements(v_syllabus->'weeks')->>'week_id')::SMALLINT
                );

                -- Se recorre todos las semanas
                FOR v_weeks IN SELECT jsonb_array_elements(v_syllabus->'weeks') LOOP
                    IF jsonb_typeof(v_weeks->'subtopics') = 'array' AND jsonb_array_length(v_weeks->'subtopics') > 0 THEN
                        -- Se busca la semana de un temario para ver si existe
                        SELECT id INTO v_syllabus_topic_week_id FROM syllabus_topic_week
                        WHERE syllabus_topic_id = v_syllabus_topic_id AND company_id = p_company_id AND week = (v_weeks->>'week_id')::SMALLINT AND fl_status = true LIMIT 1;

                        -- Si no existe se crea
                        IF v_syllabus_topic_week_id IS NULL THEN
                            INSERT INTO syllabus_topic_week (syllabus_topic_id, week, created_by, created_at, company_id)
                            VALUES (v_syllabus_topic_id, (v_weeks->>'week_id')::SMALLINT, p_updated_by, now(), p_company_id)
                            RETURNING id INTO v_syllabus_topic_week_id;
                        END IF;

                        -- Se eliminan todos los subtemas de la semana del temario que no se mandaron
                        UPDATE syllabus_detail_subtopic
                        SET fl_status = false, deleted_by = p_updated_by, deleted_at = now()
                        WHERE syllabus_topic_week_id = v_syllabus_topic_week_id
                        AND company_id = p_company_id
                        AND subtopic_id NOT IN (
                            SELECT (jsonb_array_elements(v_weeks->'subtopics')->>'id')::SMALLINT
                        );

                        FOR v_subtopics IN SELECT jsonb_array_elements(v_weeks->'subtopics') LOOP
                            -- Se busca el subtema de una semana de un temario para ver si existe
                            SELECT id INTO v_syllabus_detail_subtopic_id FROM syllabus_detail_subtopic WHERE syllabus_topic_week_id = v_syllabus_topic_week_id
                            AND company_id = p_company_id
                            AND subtopic_id = (v_subtopics->>'id')::SMALLINT AND fl_status = true LIMIT 1;

                            -- Si no existe se crea
                            IF v_syllabus_detail_subtopic_id IS NULL THEN
                                INSERT INTO syllabus_detail_subtopic (syllabus_topic_week_id, subtopic_id, questions_amount, created_by, created_at, company_id)
                                VALUES (v_syllabus_topic_week_id, (v_subtopics->>'id')::SMALLINT, 0, p_updated_by, now(), p_company_id)
                                RETURNING id INTO v_syllabus_detail_subtopic_id;
                            END IF;

                            -- Se eliminan todos los tipos de material del temario que no se mandaron
                            UPDATE syllabus_subtopic_type_material
                            SET fl_status = false, deleted_by = p_updated_by, deleted_at = now()
                            WHERE syllabus_detail_subtopic_id = v_syllabus_detail_subtopic_id
                            AND company_id = p_company_id
                            AND type_material_id NOT IN (
                                SELECT (elem->>'type_material_id')::SMALLINT
                                FROM jsonb_array_elements(v_subtopics->'questions_amount') AS elem
                            );

                            FOR v_type_materials IN SELECT jsonb_array_elements(v_subtopics->'questions_amount') LOOP
                                -- Se busca el tipo de material de un subtema del temario para ver si existe
                                SELECT id INTO v_syllabus_subtopic_type_material FROM syllabus_subtopic_type_material
                                WHERE syllabus_detail_subtopic_id = v_syllabus_detail_subtopic_id AND company_id = p_company_id AND type_material_id = (v_type_materials->>'type_material_id')::SMALLINT AND fl_status = true LIMIT 1;

                                -- Si no existe se crea
                                IF v_syllabus_subtopic_type_material IS NULL THEN
                                    INSERT INTO syllabus_subtopic_type_material (syllabus_detail_subtopic_id, type_material_id, questions_amount, created_by, created_at, company_id)
                                    VALUES (v_syllabus_detail_subtopic_id, (v_type_materials->>'type_material_id')::SMALLINT, (v_type_materials->>'amount')::SMALLINT, p_updated_by, now(), p_company_id);
                                ELSE
                                    UPDATE syllabus_subtopic_type_material SET questions_amount = (v_type_materials->>'amount')::SMALLINT, updated_by = p_updated_by, updated_at = now()
                                    WHERE id = v_syllabus_subtopic_type_material AND company_id = p_company_id;
                                END IF;
                            END LOOP;

                            SELECT COALESCE(SUM(questions_amount), 0) INTO v_total_type_material_amount FROM syllabus_subtopic_type_material WHERE syllabus_detail_subtopic_id = v_syllabus_detail_subtopic_id AND fl_status = true AND company_id = p_company_id;

                            UPDATE syllabus_detail_subtopic SET questions_amount = v_total_type_material_amount WHERE id = v_syllabus_detail_subtopic_id AND company_id = p_company_id;
                        END LOOP;

                        SELECT COALESCE(SUM(questions_amount), 0) INTO v_total_questions_amount FROM syllabus_detail_subtopic WHERE syllabus_topic_week_id = v_syllabus_topic_week_id AND fl_status = true AND company_id = p_company_id;

                        UPDATE syllabus_topic_week SET total_questions_amount = v_total_questions_amount WHERE id = v_syllabus_topic_week_id AND company_id = p_company_id;
                    ELSE
                        UPDATE syllabus_topic_week SET fl_status = false, deleted_by = p_updated_by, deleted_at = now()
                        WHERE syllabus_topic_id = v_syllabus_topic_id AND week >= (v_weeks->>'week_id')::SMALLINT AND company_id = p_company_id;
                    END IF;
                END LOOP;
            END LOOP;
            RETURN p_syllabus_id;
        END;
        $$;


ALTER FUNCTION odiseo.fn_edit_syllabus(p_syllabus_id bigint, p_syllabus jsonb, p_company_id bigint, p_updated_by bigint) OWNER TO postgres;

--
