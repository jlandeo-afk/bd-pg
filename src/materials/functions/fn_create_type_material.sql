-- Function: materials.fn_create_type_material(jsonb)

--

CREATE FUNCTION materials.fn_create_type_material(p_payload jsonb) RETURNS TABLE(result_id bigint)
    LANGUAGE plpgsql
    AS $$
                    DECLARE
                        v_parent_id     BIGINT;
                        v_child_id      BIGINT;
                        v_area_id       BIGINT;
                        v_code          VARCHAR;
                        v_header        JSONB;
                        
                        v_created_by    BIGINT;
                        v_company_id    BIGINT;
                        v_cycle_id BIGINT;
                        
                        r_child         JSONB;
                        r_area          JSONB;
                        r_course        RECORD;
                        r_sub           RECORD;
                    BEGIN
                        v_header        := p_payload -> 'header';
                        v_created_by    := (v_header->>'created_by')::BIGINT;
                        v_company_id    := (v_header->>'company_id')::BIGINT;
                        v_cycle_id := (v_header->>'cycle_id')::BIGINT;

                        -- Generar Código
                        SELECT LPAD(CAST(COUNT(id) + 1 AS TEXT), 3, '0') INTO v_code FROM type_material WHERE company_id = v_company_id;

                        -- 2. INSERTAR PADRE (RAÍZ)
                        INSERT INTO type_material (
                            code, description, created_by, created_at, cycle_id,
                            fl_exam, type_material_template_id, fl_class_material,
                            thread, level_order, percentage, amount_question, company_id,
                            order_date
                        )
                        SELECT
                            v_code,
                            tmt.name,
                            v_created_by,
                            NOW(),
                            v_cycle_id,
                            (v_header->>'is_exam')::BOOLEAN,
                            (v_header->>'template_id')::BIGINT,
                            (v_header->>'fl_class_material')::BOOLEAN,
                            (v_header->>'thread')::SMALLINT,
                            (v_header->>'level_order')::BOOLEAN,
                            (v_header->>'percentage')::NUMERIC,
                            (v_header->>'amount_question')::INT,
                            v_company_id,
                            NOW()
                        FROM type_material_template tmt
                        WHERE tmt.id = (v_header->>'template_id')::BIGINT
                        RETURNING id INTO v_parent_id;

                        -- 3. INSERTAR SEMANAS
                        IF jsonb_array_length(p_payload -> 'weeks') > 0 THEN
                            INSERT INTO type_material_detail_template (type_material_id, week, created_at, created_by)
                            SELECT v_parent_id, value::INT, NOW(), v_created_by
                            FROM jsonb_array_elements(p_payload -> 'weeks');
                        END IF;

                        -- A. CASO: TIENE HIJOS
                        IF jsonb_array_length(p_payload -> 'children') > 0 THEN
                            FOR r_child IN SELECT * FROM jsonb_array_elements(p_payload -> 'children')
                            LOOP
                                -- Insertar Hijo
                                INSERT INTO type_material (
                                    code, description, created_by, created_at, cycle_id,
                                    fl_exam, type_material_template_id, parent_id, amount_question, company_id,
                                    order_date
                                )
                                SELECT 
                                    v_code,
                                    tmt.name,
                                    v_created_by,
                                    NOW(),
                                    v_cycle_id,
                                    (v_header->>'is_exam')::BOOLEAN,
                                    (r_child->>'template_id')::BIGINT,
                                    v_parent_id, -- Link al padre
                                    (r_child->>'amount_question')::INT,
                                    v_company_id,
                                    NOW()
                                FROM type_material_template tmt
                                WHERE tmt.id = (r_child->>'template_id')::BIGINT
                                RETURNING id INTO v_child_id;

                                -- Insertar Semanas del Hijo
                                IF jsonb_array_length(r_child -> 'weeks') > 0 THEN
                                    INSERT INTO type_material_detail_template (type_material_id, week, created_at, created_by)
                                    SELECT v_child_id, value::INT, NOW(), v_created_by
                                    FROM jsonb_array_elements(r_child -> 'weeks');
                                END IF;

                                -- Insertar Cursos del Hijo
                                INSERT INTO type_material_course (type_material_id, course_id, created_by, created_at, amount_question, amount_text)
                                SELECT 
                                    v_child_id, 
                                    (c->>'course_id')::BIGINT, 
                                    v_created_by, 
                                    NOW(), 
                                    (c->>'amount_question')::INT, 
                                    (c->>'amount_text')::INT
                                FROM jsonb_array_elements(r_child -> 'courses') c;

                                -- Insertar Subpreguntas del Hijo (Texto)
                                INSERT INTO type_text_material_type_course (type_material_id, course_id, subquestion_amount, position, created_by, created_at)
                                SELECT 
                                    v_child_id,
                                    (c->>'course_id')::BIGINT,
                                    (sq->>'subquestion_amount')::SMALLINT,
                                    (sq->>'position')::SMALLINT,
                                    v_created_by,
                                    NOW()
                                FROM jsonb_array_elements(r_child -> 'courses') c
                                CROSS JOIN jsonb_array_elements(c -> 'subquestions') sq;
                            END LOOP;
                        END IF;

                        -- B. CASO: EXAMEN (Areas -> Courses)
                        IF jsonb_array_length(p_payload -> 'exam_areas') > 0 THEN
                            FOR r_area IN SELECT * FROM jsonb_array_elements(p_payload -> 'exam_areas')
                            LOOP
                                -- 1. Insertar Area
                                INSERT INTO type_material_area (type_material_id, area_id, created_by, created_at)
                                VALUES (v_parent_id, (r_area->>'area_id')::BIGINT, v_created_by, NOW())
                                RETURNING id INTO v_area_id;

                                -- 2. Recorrer Cursos del Area
                                FOR r_course IN SELECT * FROM jsonb_to_recordset(r_area -> 'courses') AS x(course_id BIGINT, amount_question INT, amount_text INT, subquestions JSONB)
                                LOOP
                                    DECLARE v_tm_course_id BIGINT;
                                    BEGIN
                                        -- Insertar Curso
                                        INSERT INTO type_material_course (type_material_id, course_id, created_by, created_at, amount_question, amount_text)
                                        VALUES (v_parent_id, r_course.course_id, v_created_by, NOW(), r_course.amount_question, r_course.amount_text)
                                        RETURNING id INTO v_tm_course_id;

                                        -- Relacionar Curso con Area
                                        INSERT INTO type_material_area_courses (type_material_course_id, type_material_area_id, created_by, created_at)
                                        VALUES (v_tm_course_id, v_area_id, v_created_by, NOW());

                                        -- Insertar Subpreguntas (Examen)
                                        IF r_course.subquestions IS NOT NULL THEN
                                            INSERT INTO type_text_material_type_course_area (type_material_id, course_id, exam_area_id, subquestion_amount, position, created_by, created_at)
                                            SELECT 
                                                v_parent_id, 
                                                r_course.course_id, 
                                                (r_area->>'area_id')::BIGINT, 
                                                (sq->>'subquestion_amount')::SMALLINT, 
                                                (sq->>'position')::SMALLINT, 
                                                v_created_by, 
                                                NOW()
                                            FROM jsonb_array_elements(r_course.subquestions) sq;
                                        END IF;
                                    END;
                                END LOOP;
                            END LOOP;
                        END IF;

                        -- C. CASO: MATERIAL ESTÁNDAR (Cursos directos)
                        IF jsonb_array_length(p_payload -> 'courses') > 0 THEN
                            -- Aquí el insert masivo está bien porque no hay jerarquía compleja dependiente de IDs generados
                            WITH raw_courses AS (
                                SELECT * FROM jsonb_to_recordset(p_payload -> 'courses') AS x(
                                    course_id BIGINT, amount_question INT, amount_text INT, subquestions JSONB
                                )
                            )
                            INSERT INTO type_material_course (type_material_id, course_id, created_by, created_at, amount_question, amount_text)
                            SELECT v_parent_id, course_id, v_created_by, NOW(), amount_question, amount_text
                            FROM raw_courses;

                            -- Insertar subpreguntas
                            INSERT INTO type_text_material_type_course (type_material_id, course_id, subquestion_amount, position, created_by, created_at)
                            SELECT 
                                v_parent_id, 
                                (c->>'course_id')::BIGINT, 
                                (sq->>'subquestion_amount')::SMALLINT,
                                (sq->>'position')::SMALLINT, 
                                v_created_by, 
                                NOW()
                            FROM jsonb_array_elements(p_payload -> 'courses') c
                            CROSS JOIN jsonb_array_elements(c->'subquestions') sq;
                        END IF;

                        -- 4. Periodicidad
                        IF (p_payload ->> 'periodicity') IS NOT NULL THEN
                            INSERT INTO type_material_periodicity (
                                type_material_id, periodicity_id, quantity_week, start_week,
                                group_previous_week, group_remaining_week, created_by, company_id,
                                created_at
                            )
                            VALUES (
                                v_parent_id, 
                                (p_payload->'periodicity'->>'id')::INT, 
                                (p_payload->'periodicity'->>'quantity_week')::INT,
                                (p_payload->'periodicity'->>'start_week')::INT,
                                (p_payload->'periodicity'->>'group_previous')::BOOL,
                                (p_payload->'periodicity'->>'group_remaining')::BOOL,
                                v_created_by,
                                v_company_id,
                                NOW()
                            );
                        END IF;

                        RETURN QUERY SELECT v_parent_id;
                    END;
                    $$;


ALTER FUNCTION materials.fn_create_type_material(p_payload jsonb) OWNER TO postgres;

--
