-- Function: materials.fn_update_type_material(smallint, bigint, bigint, character varying, boolean, boolean, smallint, boolean, numeric, character varying, jsonb, jsonb, smallint, smallint, smallint, boolean, boolean)

--

CREATE FUNCTION materials.fn_update_type_material(p_id smallint, p_f_type_material_template_id bigint, p_updated_by bigint, p_ids_area character varying, p_fl_exam boolean, p_fl_class_material boolean, p_thread smallint, p_level_order boolean, p_percentage numeric, p_courses character varying, p_weeks jsonb, p_ids_children jsonb, p_periodicity_id smallint, p_quantity_week smallint, p_start_week smallint, p_group_previous_week boolean, p_group_remaining_week boolean) RETURNS TABLE(v_validate integer, type_material_id smallint)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_validate                       SMALLINT;
            v_type_material_id               SMALLINT;
            v_ids_area_length                INT;
            v_ids_area                       BIGINT[];
            v_amount_question                INT     := 0;
            v_course_item                    JSONB;
            v_course_id                      BIGINT;
            v_course_amount_question         INT;
            v_course_amount_text             INT;
            v_type_material_course_id        INT;
            v_type_material_area_id          INT;
            v_type_material_area_course_id   INT;
            v_new_type_material_course_id    INT;
            v_weeks_from_cycle_template      INT;
            v_weeks                          BIGINT[];
            v_week                           SMALLINT;
            v_area_id                        SMALLINT;
            v_not_exist_week                 BOOLEAN;
            v_week_fl_status                 BOOLEAN;
            v_type_material_template_description VARCHAR;
            v_not_exist_area_ids             INT[];
            v_children_id			  		 BIGINT;
            v_type_material_periodicity      SMALLINT;
            v_type_text_material_type_course INT;
            v_subquestion_item               JSONB;
            v_subquestion_position           SMALLINT;
            v_subquestion_amount             SMALLINT;
        BEGIN

            -- Convertir el JSONB p_weeks en un array de BIGINT
            v_weeks := ARRAY(
                SELECT jsonb_array_elements_text(p_weeks::JSONB)::BIGINT
            );

            -- Convertir el JSONB p_ids_area en un array de BIGINT
            v_ids_area := ARRAY(
                SELECT jsonb_array_elements_text(p_ids_area::JSONB)::BIGINT
            );

            -- Validar si es examen, debe tener una o mas áreas
            IF p_fl_exam THEN
                v_ids_area_length := array_length(v_ids_area, 1);
                IF v_ids_area_length IS NULL OR v_ids_area_length < 1 THEN
                    RETURN QUERY SELECT 0::INT, 0::SMALLINT;
                END IF;
            ELSE
                v_ids_area_length := array_length(v_ids_area, 1);
                IF v_ids_area_length IS NOT NULL AND v_ids_area_length > 0 THEN
                    RETURN QUERY SELECT 0::INT, 0::SMALLINT;
                END IF;
            END IF;
            
            -- Actualizar tipo de material
            UPDATE type_material
            SET description = COALESCE(v_type_material_template_description, description),
                updated_by = p_updated_by,
                updated_at = now(),
                fl_exam = p_fl_exam,
                fl_class_material = COALESCE(p_fl_class_material, fl_class_material),
                percentage = p_percentage,
                thread = p_thread,
                level_order = p_level_order,
                type_material_template_id = p_f_type_material_template_id,
                order_date = CASE
                    WHEN p_level_order IS DISTINCT FROM level_order
                      OR p_thread IS DISTINCT FROM thread
                      OR p_percentage IS DISTINCT FROM percentage
                    THEN NOW()
                    ELSE order_date
                END
            WHERE id = p_id;

            -- Limpiar TYPE MATERIAL DETAIL TEMPLATE si es un examen
            UPDATE type_material_detail_template AS tmdt
            SET fl_status = false,
                updated_by = p_updated_by,
                updated_at = now()
            WHERE tmdt.type_material_id = p_id;

            -- Procesar semanas
            FOR v_week IN
                SELECT unnest(v_weeks)
            LOOP
                IF v_week > 0 THEN
                    -- Actualizar o insertar semanas
                    UPDATE type_material_detail_template AS tmdt
                    SET fl_status = true
                    WHERE 1 = 1
                        AND tmdt.type_material_id = p_id
                        AND tmdt.week = v_week;

                    IF NOT FOUND THEN
                        INSERT INTO type_material_detail_template (type_material_id, week, created_at, created_by)
                        VALUES (p_id, v_week, now(), p_updated_by);
                    END IF;
                END IF;
            END LOOP;

            IF NOT p_fl_exam THEN
                -- Si no es un examen:
                IF p_ids_children IS NULL OR jsonb_array_length(p_ids_children) = 0 THEN
                    -- Limpiar áreas si no es un examen
                    UPDATE type_material_area AS tma
                    SET fl_status = false,
                        deleted_by = p_updated_by,
                        deleted_at = now()
                    WHERE tma.type_material_id = p_id;

                    -- Procesar cursos
                    FOR v_course_item IN
                        SELECT * FROM jsonb_array_elements(p_courses::JSONB)
                    LOOP
                        v_course_id := (v_course_item ->> 'course_id')::BIGINT;
                        v_course_amount_question := (v_course_item ->> 'amount_question')::INT;
                        v_course_amount_text := (v_course_item ->> 'amount_text')::INT;

                        -- Verificar si el curso ya existe
                        SELECT id INTO v_type_material_course_id
                        FROM type_material_course AS tmc
                        WHERE 1 = 1
                            AND tmc.type_material_id = p_id
                            AND tmc.course_id = v_course_id;

                        IF v_type_material_course_id IS NOT NULL THEN
                            -- Actualizar curso existente
                            UPDATE type_material_course
                            SET fl_status = true,
                                updated_by = p_updated_by,
                                updated_at = now(),
                                amount_question = v_course_amount_question,
                                amount_text = v_course_amount_text
                            WHERE id = v_type_material_course_id;

                        ELSE
                            -- Insertar nuevo curso
                            IF ( v_course_amount_question > 0 OR v_course_amount_text > 0 ) THEN
                                INSERT INTO type_material_course (type_material_id, course_id, created_by, created_at, amount_question, amount_text)
                                VALUES (p_id, v_course_id, p_updated_by, now(), v_course_amount_question, v_course_amount_text);
                            END IF;
                        END IF;

                        IF (v_course_item ->>'apply_text')::BOOL IS TRUE THEN
                           WITH insert_or_update_subquestions_in_text AS (
                               INSERT INTO type_text_material_type_course (type_material_id, course_id, subquestion_amount, position, created_by, created_at)
                               SELECT
                                    p_id,
                                    v_course_id,
                                    (subquestion->>'subquestion_amount')::SMALLINT AS subquestion_amount,
                                    (subquestion->>'position')::SMALLINT AS position,
                                    p_updated_by,
                                    NOW()
                               FROM JSONB_ARRAY_ELEMENTS(COALESCE(v_course_item->'subquestions', '[]'::JSONB)) AS subquestion
                               ON CONFLICT ON CONSTRAINT unique_type_material_course_pos
                               DO UPDATE
                                   SET
                                       subquestion_amount = EXCLUDED.subquestion_amount,
                                       updated_at = NOW(),
                                       updated_by = p_updated_by,
                                       deleted_by = NULL,
                                       deleted_at = NULL
                               RETURNING id
                           ) UPDATE type_text_material_type_course AS ty
                           SET
                               deleted_by = p_updated_by,
                               deleted_at = NOW()
                           WHERE 1 = 1
                             AND ty.type_material_id = p_id
                             AND ty.course_id = v_course_id
                             AND ty.id NOT IN (SELECT id FROM insert_or_update_subquestions_in_text);
                        END IF;

                        v_amount_question := v_amount_question + v_course_amount_question + v_course_amount_text;
                    END LOOP;

                    -- Actualizar la cantidad total de preguntas
                    UPDATE type_material AS tm
                    SET amount_question = v_amount_question,
                        updated_by = p_updated_by,
                        updated_at = now()
                    WHERE tm.id = p_id;
                ELSE
                    FOR v_children_id IN
                        SELECT id
                        FROM type_material
                        WHERE 1 = 1
                            AND fl_status = true
                            AND id = ANY(ARRAY(SELECT jsonb_array_elements_text(p_ids_children)::INT))
                    LOOP
                        v_amount_question := 0;

                        -- Procesar cursos
                        FOR v_course_item IN
                            SELECT * FROM jsonb_array_elements(p_courses::JSONB) AS courses
                            WHERE (courses->>'type_material_id')::BIGINT = v_children_id
                        LOOP
                            v_course_id := (v_course_item ->> 'course_id')::BIGINT;
                            v_course_amount_question := (v_course_item ->> 'amount_question')::INT;
                            v_course_amount_text := (v_course_item ->> 'amount_text')::INT;
                            -- Limpiar las semanas del hijo antes de actualizar
                            UPDATE type_material_detail_template AS tmdt
                                SET fl_status = false,
                                    updated_by = p_updated_by,
                                    updated_at = now()
                                WHERE 1 = 1
                                    AND tmdt.type_material_id = v_children_id;

                            -- Verificar si el curso ya existe
                            SELECT id INTO v_type_material_course_id
                            FROM type_material_course AS tmc
                            WHERE tmc.type_material_id = v_children_id
                            AND tmc.course_id = v_course_id;

                            -- Actualizar las semanas del hijo
                            FOR v_week IN
                                SELECT unnest(v_weeks)
                            LOOP
                                IF v_week > 0 THEN
                                    UPDATE type_material_detail_template AS tmdt
                                    SET fl_status = true
                                    WHERE 1 = 1
                                        AND tmdt.type_material_id = v_children_id
                                        AND tmdt.week = v_week;

                                    IF NOT FOUND THEN
                                        INSERT INTO type_material_detail_template (type_material_id, week, created_at, created_by)
                                        VALUES (v_children_id, v_week, now(), p_updated_by);
                                    END IF;
                                END IF;
                            END LOOP;

                            IF v_type_material_course_id IS NOT NULL THEN
                                -- Actualizar curso existente
                                UPDATE type_material_course
                                SET fl_status = true,
                                    updated_by = p_updated_by,
                                    updated_at = now(),
                                    amount_question = v_course_amount_question,
                                    amount_text = v_course_amount_text
                                WHERE id = v_type_material_course_id;
                            ELSE
                                -- Insertar nuevo curso
                                IF (  v_course_amount_question > 0 OR v_course_amount_text > 0 ) THEN
                                    INSERT INTO type_material_course (type_material_id, course_id, created_by, created_at, amount_question, amount_text)
                                    VALUES (p_id, v_course_id, p_updated_by, now(), v_course_amount_question, v_course_amount_text);
                                END IF;
                            END IF;

                            IF (v_course_item ->>'apply_text')::BOOL IS TRUE AND JSONB_ARRAY_LENGTH(COALESCE(v_course_item->'subquestions', '[]'::JSONB)) > 0 THEN
                                WITH insert_or_update_subquestions_in_text AS (
                                    INSERT INTO type_text_material_type_course (type_material_id, course_id, subquestion_amount, position, created_by, created_at)
                                    SELECT 
                                        v_children_id,
                                        v_course_id,
                                        (subquestion->>'subquestion_amount')::SMALLINT AS subquestion_amount,
                                        (subquestion->>'position')::SMALLINT AS position,
                                        p_updated_by,
                                        NOW()
                                    FROM JSONB_ARRAY_ELEMENTS(COALESCE(v_course_item->'subquestions', '[]'::JSONB)) AS subquestion
                                    ON CONFLICT ON CONSTRAINT unique_type_material_course_pos
                                    DO UPDATE
                                        SET
                                            subquestion_amount = EXCLUDED.subquestion_amount,
                                            updated_at = NOW(),
                                            updated_by = p_updated_by,
                                            deleted_by = NULL,
                                            deleted_at = NULL
                                    RETURNING id
                                ) UPDATE type_text_material_type_course AS ty
                                  SET
                                    deleted_by = p_updated_by,
                                    deleted_at = NOW()
                                  WHERE 1 = 1
                                    AND ty.type_material_id = v_children_id
                                    AND ty.course_id = v_course_id
                                    AND ty.id NOT IN (SELECT id FROM insert_or_update_subquestions_in_text); 
                            END IF;

                            v_amount_question := v_amount_question + v_course_amount_question + v_course_amount_text;

                        END LOOP;

                        RAISE NOTICE 'v_amount_question %', v_amount_question;
                        -- Actualizar la cantidad total de preguntas
                        UPDATE type_material AS tm
                        SET amount_question = v_amount_question,
                            updated_by = p_updated_by,
                            updated_at = now(),
                            percentage = p_percentage,
                            thread = p_thread,
                            level_order = p_level_order,
                            order_date = CASE
                                WHEN p_level_order IS DISTINCT FROM level_order
                                OR p_thread IS DISTINCT FROM thread
                                OR p_percentage IS DISTINCT FROM percentage
                                THEN NOW()
                                ELSE order_date
                            END
                        WHERE tm.id = v_children_id;
                    END LOOP;

                    UPDATE type_material
                    SET amount_question = (
                            SELECT COALESCE(SUM(amount_question), 0)
                            FROM type_material
                            WHERE id = ANY (ARRAY(SELECT jsonb_array_elements_text(p_ids_children)::INT)) -- Filtra los hijos usando p_ids_children
                        ),
                        updated_by = p_updated_by,
                        updated_at = now()
                    WHERE id = p_id; -- ID del padre
                END IF;
            ELSE
                -- Si es un examen:

                -- Obtenemos las areas que no se envian en v_ids_area
                SELECT ARRAY(
                    SELECT tma.area_id
                    FROM type_material_area tma
                    WHERE 1 = 1
                    AND tma.fl_status = TRUE
                    AND tma.area_id NOT IN (SELECT unnest(v_ids_area))
                ) INTO v_not_exist_area_ids;

                -- Eliminando los registros q no se encuentran en type_material_area
                UPDATE type_material_area AS tma
                SET fl_status = FALSE,
                    updated_by = p_updated_by,
                    updated_at = now()
                WHERE 1 = 1
                    AND tma.type_material_id = p_id
                    AND tma.area_id  IN (SELECT unnest(v_not_exist_area_ids));

                -- Actualizando los registros de los valores amount de la tabla: exam_material_config_area_course_levels
                WITH configurations_to_update AS (
                    SELECT emcacl2.id AS id
                    FROM exam_material_config_area_course_levels emcacl2
                    LEFT JOIN exam_material_config_area_courses emcac
                        ON emcacl2.exam_material_config_area_course_id = emcac.id
                    LEFT JOIN exam_material_configurations emc
                        ON emc.id = emcac.exam_material_config_id
                    WHERE TRUE
                    AND emc.type_material_id = p_id
                    AND emcacl2.fl_status = TRUE
                    AND emcac.exam_area_id IN (SELECT UNNEST(v_not_exist_area_ids))
                )
                UPDATE exam_material_config_area_course_levels exxl
                    SET amount_question = 0
                FROM configurations_to_update cup
                WHERE cup.id = exxl.id;

                -- Procesar áreas y cursos asociados
                FOR v_area_id IN
                    SELECT unnest(v_ids_area)
                LOOP
                    IF v_area_id > 0 THEN
                        -- Desactivar cursos que ya no están en p_courses
                        WITH current_courses AS (
                            SELECT tmc.id AS course_id
                            FROM type_material_area_courses tmac
                            JOIN type_material_area tma ON tmac.type_material_area_id = tma.id
                            JOIN type_material_course tmc ON tmac.type_material_course_id = tmc.id
                            WHERE 1 = 1
                                AND tma.type_material_id = p_id
                                AND tma.area_id = v_area_id
                        )
                        UPDATE type_material_course
                        SET fl_status = false,
                            updated_by = p_updated_by,
                            updated_at = now()
                        WHERE id IN (
                            SELECT course_id FROM current_courses
                            EXCEPT
                            SELECT (course->>'course_id')::BIGINT
                            FROM jsonb_array_elements(p_courses::JSONB) AS course
                            WHERE (course->>'area_id')::BIGINT = v_area_id
                        );

                        SELECT tma.id
                        INTO v_type_material_area_id
                        FROM type_material_area tma
                        WHERE  1 = 1
                            AND tma.type_material_id = p_id
                            AND tma.area_id = v_area_id;

                        IF v_type_material_area_id IS NULL THEN
                            INSERT INTO type_material_area (type_material_id, area_id, created_at, created_by)
                            VALUES (p_id, v_area_id, now(), p_updated_by)
                            RETURNING id INTO v_type_material_area_id;
                        ELSE
                            UPDATE  type_material_area
                            SET fl_status = TRUE, updated_by = p_updated_by, updated_at = now()
                            WHERE id = v_type_material_area_id ;
                        END IF;

                        -- Procesar cursos asociados a áreas
                        FOR v_course_item IN
                            SELECT *
                            FROM jsonb_array_elements(p_courses::JSONB) AS courses
                            WHERE (courses->>'area_id')::BIGINT = v_area_id
                        LOOP
                            v_course_id := (v_course_item ->> 'course_id')::BIGINT;
                            v_course_amount_question := (v_course_item ->> 'amount_question')::INT;
                            v_course_amount_text := (v_course_item ->> 'amount_text')::INT;

                            -- Verificar si el curso ya existe
                            SELECT tmc.id INTO v_type_material_course_id
                            FROM type_material_area_courses tmac
                            JOIN type_material_area tma ON tmac.type_material_area_id = tma.id
                            JOIN type_material_course tmc ON tmac.type_material_course_id = tmc.id
                            WHERE 1 = 1
                                AND tma.type_material_id = p_id
                                AND tma.area_id = v_area_id
                                AND tmc.course_id = v_course_id
                                AND tmac.fl_status = true;

                            IF v_type_material_course_id IS NOT NULL THEN
                                -- Actualizar curso existente
                                UPDATE type_material_course AS tmc
                                SET fl_status = true,
                                    updated_by = p_updated_by,
                                    updated_at = now(),
                                    amount_question = v_course_amount_question,
                                    amount_text = v_course_amount_text
                                WHERE tmc.id = v_type_material_course_id;

                                SELECT tmac.id
                                INTO v_type_material_area_course_id
                                FROM type_material_area_courses tmac
                                WHERE 1 = 1
                                    AND tmac.type_material_course_id = v_type_material_course_id
                                    AND tmac.type_material_area_id = v_type_material_area_id;

                                IF v_type_material_area_course_id IS NULL THEN
                                    INSERT INTO type_material_area_courses (type_material_course_id, type_material_area_id, created_by, created_at)
                                    VALUES (v_new_type_material_course_id, v_type_material_area_id, p_updated_by, now());
                                ELSE
                                    UPDATE type_material_area_courses
                                    SET fl_status = TRUE
                                    WHERE id = v_type_material_area_course_id;

                                    IF v_course_amount_question = 0 THEN
                                        UPDATE exam_material_config_area_course_levels emcacl
                                        SET amount_question = v_course_amount_question
                                        FROM exam_material_config_area_courses emc
                                        JOIN exam_material_configurations emc2 ON emc2.id = emc.exam_material_config_id
                                        WHERE emcacl.exam_material_config_area_course_id = emc.id
                                            AND emc.course_id = v_course_id
                                            AND emc.exam_area_id = v_area_id
                                            AND emc2.type_material_id = p_id;
                                    END IF;
                                END IF;
                            ELSE
                                -- Insertar nuevo curso y asociarlo al área
                                INSERT INTO type_material_course (type_material_id, course_id, created_by, created_at, amount_question, amount_text)
                                VALUES (p_id, v_course_id, p_updated_by, now(), v_course_amount_question, v_course_amount_text)
                                RETURNING id INTO v_new_type_material_course_id;

                                INSERT INTO type_material_area_courses (type_material_course_id, type_material_area_id, created_by, created_at)
                                VALUES (v_new_type_material_course_id, v_type_material_area_id, p_updated_by, now());
                            END IF;

                            IF (v_course_item ->>'apply_text')::BOOL IS TRUE AND JSONB_ARRAY_LENGTH(COALESCE(v_course_item->'subquestions', '[]'::JSONB)) > 0 THEN
                                WITH insert_or_update_area_subquestions_in_text AS (
                                   INSERT INTO type_text_material_type_course_area (type_material_id, course_id, exam_area_id, subquestion_amount, position, created_by, created_at)
                                   SELECT 
                                        p_id,
                                        v_course_id,
                                        v_area_id,
                                        (subquestion->>'subquestion_amount')::SMALLINT AS subquestion_amount,
                                        (subquestion->>'position')::SMALLINT AS position,
                                        p_updated_by,
                                        NOW()
                                   FROM JSONB_ARRAY_ELEMENTS(COALESCE(v_course_item->'subquestions', '[]'::JSONB)) AS subquestion
                                   ON CONFLICT ON CONSTRAINT unique_type_material_course_are_pos
                                   DO UPDATE
                                       SET
                                           subquestion_amount = EXCLUDED.subquestion_amount,
                                           updated_at = NOW(),
                                           updated_by = p_updated_by,
                                           deleted_by = NULL,
                                           deleted_at = NULL
                                   RETURNING id
                               ) UPDATE type_text_material_type_course_area AS ty
                               SET
                                   deleted_by = p_updated_by,
                                   deleted_at = NOW()
                               WHERE 1 = 1
                                 AND ty.type_material_id = p_id
                                 AND ty.course_id = v_course_id
                                 AND ty.exam_area_id = v_area_id
                                 AND ty.id NOT IN (SELECT id FROM insert_or_update_area_subquestions_in_text);
                            ELSE
                                WITH update_type_text_material_type_course_area AS (
                                    UPDATE type_text_material_type_course_area ttm
                                            SET
                                                deleted_by = p_updated_by,
                                                deleted_at = NOW()
                                        WHERE 1 = 1
                                          AND ttm.type_material_id = p_id
                                          AND ttm.course_id = v_course_id
                                          AND ttm.exam_area_id = v_area_id
                                    RETURNING ttm.id
                                )
                                INSERT INTO type_text_material_type_course_area (type_material_id, course_id, exam_area_id, subquestion_amount, position, created_at, created_by, deleted_at, deleted_by)
                                SELECT p_id, v_course_id, v_area_id, 0, 1, NOW(), p_updated_by, NOW(), p_updated_by WHERE NOT EXISTS ( SELECT 1 FROM update_type_text_material_type_course_area ); -- <--Version 1.3
                            END IF;

                            -- Acumular la cantidad de preguntas
                            v_amount_question := v_amount_question + v_course_amount_question + v_course_amount_text;
                        END LOOP;
                    END IF;
                END LOOP;

                -- Actualizando amount_question
                UPDATE type_material
                SET amount_question = v_amount_question,
                    updated_by = p_updated_by,
                    updated_at = now()
                WHERE id = p_id;
            END IF;

            -- Actualizar configuración de periodicidad y/o crear si no existe

            IF NOT p_fl_exam THEN -- <-- Se condicionó para que no se actualice o se registre periodicidad en el caso que sea examen
                UPDATE type_material_periodicity tmp
                SET periodicity_id = p_periodicity_id,
                    quantity_week = p_quantity_week,
                    start_week = p_start_week,
                    group_previous_week = p_group_previous_week,
                    group_remaining_week = p_group_remaining_week,
                    updated_by = p_updated_by,
                    updated_at = now()
                WHERE tmp.type_material_id = p_id
                    AND tmp.fl_status = true
                RETURNING tmp.id INTO v_type_material_periodicity;

                IF v_type_material_periodicity IS NULL THEN
                    INSERT INTO type_material_periodicity AS tmp (
                        type_material_id,
                        periodicity_id,
                        quantity_week,
                        start_week,
                        group_previous_week,
                        group_remaining_week,
                        created_by,
                        created_at
                    )
                    VALUES (
                        p_id,
                        p_periodicity_id,
                        p_quantity_week,
                        p_start_week,
                        p_group_previous_week,
                        p_group_remaining_week,
                        p_updated_by,
                        now()
                    );
                END IF;
            END IF;

            RETURN QUERY SELECT 1::INT, p_id;
        END;
        $$;


ALTER FUNCTION materials.fn_update_type_material(p_id smallint, p_f_type_material_template_id bigint, p_updated_by bigint, p_ids_area character varying, p_fl_exam boolean, p_fl_class_material boolean, p_thread smallint, p_level_order boolean, p_percentage numeric, p_courses character varying, p_weeks jsonb, p_ids_children jsonb, p_periodicity_id smallint, p_quantity_week smallint, p_start_week smallint, p_group_previous_week boolean, p_group_remaining_week boolean) OWNER TO postgres;

--
