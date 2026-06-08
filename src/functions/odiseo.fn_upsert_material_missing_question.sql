-- Function: odiseo.fn_upsert_material_missing_question(integer, bigint, jsonb)

--

CREATE FUNCTION odiseo.fn_upsert_material_missing_question(p_week_type_material_id integer, p_user_id bigint, p_course_ids jsonb DEFAULT NULL::jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_material_id bigint;
    v_week smallint;
    v_type_material_id smallint;
    v_date_request timestamp;
    v_course_id integer;
    
    v_active_mmq_id bigint;
    v_has_progress boolean;
    v_has_valid_details boolean;
    v_has_missing boolean; -- Rescatado de testing para la inserción masiva
BEGIN
    -- 1. Context Resolution
    SELECT 
        m.id,
        dwtm.week,
        COALESCE(dwtm.parent_type_material_id, dwtm.type_material_id),
        COALESCE(dwtm.created_at, now())
    INTO 
        v_material_id,
        v_week,
        v_type_material_id,
        v_date_request
    FROM detail_week_type_mat dwtm
    JOIN material m ON dwtm.material_id = m.id
    WHERE dwtm.id = p_week_type_material_id;

    IF v_material_id IS NULL THEN
        RETURN;
    END IF;

    -- 2. Identify Courses to process
    IF p_course_ids IS NULL THEN
        SELECT jsonb_agg(DISTINCT course_id)
        INTO p_course_ids
        -- [REFACTOR] Se usa la nueva tabla
        FROM material_ballot_question
        WHERE material_id = v_material_id
          AND week = v_week
          AND week_type_material_id = p_week_type_material_id
          AND fl_status = true;
    END IF;

    IF p_course_ids IS NULL OR jsonb_array_length(p_course_ids) = 0 THEN
        RETURN;
    END IF;

    -- Iterate over each course (typically 1-10 courses)
    FOR v_course_id IN 
        SELECT (value::text)::integer FROM jsonb_array_elements(p_course_ids)
    LOOP
        -- Find active Parent
        v_active_mmq_id := NULL;
        SELECT id INTO v_active_mmq_id
        FROM material_missing_question
        WHERE material_id = v_material_id
          AND type_material_id = v_type_material_id
          AND week = v_week
          AND course_id = v_course_id
          AND status IN ('pending', 'expired')
          AND deleted_at IS NULL
        LIMIT 1;

        IF v_active_mmq_id IS NOT NULL THEN
            -- Check for progress (assigned or completed)
            SELECT EXISTS (
                SELECT 1 
                FROM material_missing_question_detail
                WHERE material_missing_question_id = v_active_mmq_id
                  AND deleted_at IS NULL
                  AND status IN ('completed', 'assigned')
            ) INTO v_has_progress;

            IF v_has_progress THEN
                -- Rule 1: If there is progress, cancel the whole group (no logical deletes)
                UPDATE material_missing_question
                SET status = 'canceled',
                    updated_by = p_user_id,
                    updated_at = now()
                WHERE id = v_active_mmq_id;

                UPDATE material_missing_question_detail
                SET status = 'canceled',
                    updated_at = now()
                WHERE material_missing_question_id = v_active_mmq_id
                  AND status IN ('pending', 'expired')
                  AND deleted_at IS NULL;
                  
                v_active_mmq_id := NULL;
            ELSE
                -- Rule 2: If no progress, do a logical sweep (decrease/delete orphans)
                UPDATE material_missing_question_detail mmqd
                SET deleted_at = now()
                WHERE mmqd.material_missing_question_id = v_active_mmq_id
                  AND mmqd.status IN ('pending', 'expired')
                  AND mmqd.deleted_at IS NULL
                  AND NOT EXISTS (
                      -- [REFACTOR] Validando sobre la nueva tabla material_ballot_question
                      SELECT 1 FROM material_ballot_question mdbq
                      WHERE mdbq.id = mmqd.material_ballot_question_id
                        AND mdbq.question_id IS NULL
                        AND mdbq.fl_status = true
                        AND mdbq.deleted_at IS NULL
                  );

                -- Rule 3: Check if parent is empty now. If empty, delete logically.
                SELECT EXISTS (
                    SELECT 1 FROM material_missing_question_detail
                    WHERE material_missing_question_id = v_active_mmq_id
                      AND deleted_at IS NULL
                ) INTO v_has_valid_details;
                
                IF NOT v_has_valid_details THEN
                    -- Empty ticket with no progress. Delete it logically.
                    UPDATE material_missing_question
                    SET deleted_at = now(),
                        status = 'canceled',
                        updated_by = p_user_id,
                        updated_at = now()
                    WHERE id = v_active_mmq_id;
                    
                    v_active_mmq_id := NULL;
                ELSE
                    -- Keep it alive
                    UPDATE material_missing_question
                    SET request_date = v_date_request,
                        updated_by = p_user_id,
                        updated_at = now()
                    WHERE id = v_active_mmq_id;
                END IF;
            END IF;
        END IF;

        -- =========================================================================
        -- 3. Handle missing distributions (Optimized: Bulk insertion desde TESTING)
        -- =========================================================================
        IF v_active_mmq_id IS NULL THEN
            -- Check if there are any missing distributions for this course
            SELECT EXISTS (
                SELECT 1 
                FROM material_ballot_question
                WHERE material_id = v_material_id
                  AND week = v_week
                  AND course_id = v_course_id
                  AND fl_status = true
                  AND question_id IS NULL
                  AND type_text_id IS NULL
                  AND deleted_at IS NULL
            ) INTO v_has_missing;

            IF v_has_missing THEN
                INSERT INTO material_missing_question (
                    material_id, type_material_id, week, request_date, course_id, status, created_by, created_at
                ) VALUES (
                    v_material_id, v_type_material_id, v_week, v_date_request, v_course_id, 'pending', p_user_id, now()
                ) RETURNING id INTO v_active_mmq_id;
            END IF;
        END IF;

        -- Bulk insert details that do not exist yet (Sin usar el bucle lento)
        IF v_active_mmq_id IS NOT NULL THEN
            INSERT INTO material_missing_question_detail (
                material_missing_question_id, material_ballot_question_id, status, created_at
            )
            SELECT v_active_mmq_id, mdbq.id, 'pending', now()
            FROM material_ballot_question mdbq
            WHERE mdbq.material_id = v_material_id
              AND mdbq.week = v_week
              AND mdbq.course_id = v_course_id
              AND mdbq.fl_status = true
              AND mdbq.question_id IS NULL
              AND mdbq.type_text_id IS NULL
              AND mdbq.deleted_at IS NULL
              AND NOT EXISTS (
                  SELECT 1 FROM material_missing_question_detail mmqd
                  WHERE mmqd.material_missing_question_id = v_active_mmq_id
                    AND mmqd.material_ballot_question_id = mdbq.id
                    AND mmqd.status IN ('pending', 'expired', 'assigned', 'completed')
                    AND mmqd.deleted_at IS NULL
              );
        END IF;

    END LOOP;
END;
$$;


ALTER FUNCTION odiseo.fn_upsert_material_missing_question(p_week_type_material_id integer, p_user_id bigint, p_course_ids jsonb) OWNER TO postgres;

--
