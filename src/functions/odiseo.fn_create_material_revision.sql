-- Function: odiseo.fn_create_material_revision(bigint, smallint, smallint, smallint, bigint)

--

CREATE FUNCTION odiseo.fn_create_material_revision(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint, p_created_by bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_revision_id  bigint;
    v_root_type_id smallint;
    v_final_start  smallint;
    v_final_end    smallint;
    v_course_id    smallint;
    v_detail_id    bigint;
    v_resolved_courses smallint[];
    v_fl_revision  boolean;
    v_delivery_date    timestamp(0);
BEGIN
    -- 0. Resolución del tipo raíz y validación de soporte para revisión
    -- -------------------------------------------------------------------------
    SELECT 
        COALESCE(tm.parent_id, tm.id),
        tmt.fl_revision
    INTO v_root_type_id, v_fl_revision
    FROM type_material tm
    JOIN type_material_template tmt ON tmt.id = tm.type_material_template_id
    WHERE tm.id = p_type_material_id;

    -- Si la plantilla del material no tiene activa la revisión, no se crea nada.
    IF NOT COALESCE(v_fl_revision, false) THEN
        RETURN NULL;
    END IF;

    -- -------------------------------------------------------------------------
    -- 1. Resolución del rango real según periodicidad
    -- -------------------------------------------------------------------------
    -- Si p_start_week y p_end_week son iguales, buscamos si hay una agrupación (ej. 1-2)
    IF p_start_week = p_end_week THEN
        SELECT 
            tmp.start_week,
            (tmp.start_week + COALESCE(tmp.quantity_week, 1) - 1)
        INTO v_final_start, v_final_end
        FROM type_material_periodicity tmp
        WHERE tmp.type_material_id = v_root_type_id
          AND p_start_week BETWEEN tmp.start_week AND (tmp.start_week + COALESCE(tmp.quantity_week, 1) - 1)
          AND tmp.fl_status = true
        LIMIT 1;
        
        v_final_start := COALESCE(v_final_start, p_start_week);
        v_final_end   := COALESCE(v_final_end, p_end_week);
    ELSE
        v_final_start := p_start_week;
        v_final_end   := p_end_week;
    END IF;

    -- -------------------------------------------------------------------------
    -- 2. Idempotencia: Buscar revisión activa existente
    -- -------------------------------------------------------------------------
    SELECT id INTO v_revision_id
    FROM material_revisions
    WHERE material_id      = p_material_id
      AND type_material_id = v_root_type_id
      AND start_week       = v_final_start
      AND end_week         = v_final_end
      AND deleted_at       IS NULL
      AND status NOT IN ('verified', 'material_delivered')
    LIMIT 1;

    IF v_revision_id IS NOT NULL THEN
        PERFORM fn_sync_material_revision_status(v_revision_id, p_created_by);
        RETURN v_revision_id;
    END IF;

    -- -------------------------------------------------------------------------
    -- 3. Validaciones y resolución de parámetros
    -- -------------------------------------------------------------------------

    -- Resolver y filtrar cursos: Solo se incluyen cursos que tengan registros en el balotario para este material/tipo/rango
    SELECT array_agg(DISTINCT mdbq.course_id)::smallint[]
    INTO v_resolved_courses
    FROM material_ballot_question mdbq
    INNER JOIN detail_week_type_mat dwtm ON mdbq.week_type_material_id = dwtm.id
    WHERE mdbq.material_id = p_material_id
      AND mdbq.week BETWEEN v_final_start AND v_final_end
      AND mdbq.fl_status = true
      AND (dwtm.type_material_id = v_root_type_id OR dwtm.parent_type_material_id = v_root_type_id);


    -- -------------------------------------------------------------------------
    -- 3.1 Resolviendo fecha de entrega
    -- -------------------------------------------------------------------------
    SELECT 
        mppb.created_at + interval '1 week'
    INTO v_delivery_date
    FROM material_per_period mpp
    JOIN material_per_period_ballot mppb ON mppb.material_per_period_id = mpp.id
    WHERE mpp.material_id = p_material_id
      AND mpp.type_material_id = p_type_material_id
      AND mppb.deleted_at IS NULL
      AND mppb.start_week = p_start_week
      AND mppb.end_week = p_end_week
    LIMIT 1;

    -- -------------------------------------------------------------------------
    -- 4. Cabecera
    -- -------------------------------------------------------------------------
    INSERT INTO material_revisions (
        material_id,
        type_material_id,
        start_week,
        end_week,
        delivery_date,
        status,
        created_at,
        updated_at,
        created_by
    ) VALUES (
        p_material_id,
        v_root_type_id,
        v_final_start,
        v_final_end,
        v_delivery_date,
        'generating',
        NOW(),
        NOW(),
        p_created_by
    )
    RETURNING id INTO v_revision_id;

    -- -------------------------------------------------------------------------
    -- 4.1 Historial
    -- -------------------------------------------------------------------------
    INSERT INTO material_revision_histories (
        material_revision_id,
        new_status,
        changed_at,
        changed_by
    ) VALUES (
        v_revision_id,
        'generating',
        NOW(),
        p_created_by
    );

    -- -------------------------------------------------------------------------
    -- 5. Cursos
    -- -------------------------------------------------------------------------
    IF v_resolved_courses IS NOT NULL THEN
        FOREACH v_course_id IN ARRAY v_resolved_courses
        LOOP
            INSERT INTO material_revision_courses (
                material_revision_id,
                course_id,
                status,
                created_at,
                created_by
            ) VALUES (
                v_revision_id,
                v_course_id,
                'pending_verification',
                NOW(),
                p_created_by
            )
            ON CONFLICT (material_revision_id, course_id) DO NOTHING;
        END LOOP;
    END IF;

    -- -------------------------------------------------------------------------
    -- 6. Items del pivote
    -- -------------------------------------------------------------------------
    FOR v_detail_id IN
        SELECT id
        FROM detail_week_type_mat
        WHERE material_id = p_material_id
          AND (type_material_id = v_root_type_id OR parent_type_material_id = v_root_type_id)
          AND week BETWEEN v_final_start AND v_final_end
          AND deleted_at IS NULL
          AND fl_status  = true
        ORDER BY week, parent_type_material_id NULLS FIRST, id
    LOOP
        INSERT INTO material_revision_items (
            material_revision_id,
            detail_week_type_mat_id,
            created_at,
            created_by
        ) VALUES (
            v_revision_id,
            v_detail_id,
            NOW(),
            p_created_by
        )
        ON CONFLICT (material_revision_id, detail_week_type_mat_id) DO NOTHING;
    END LOOP;

    -- 7. Sincronizar estado (automático por completitud de preguntas)
    PERFORM fn_sync_material_revision_status(v_revision_id, p_created_by);

    RETURN v_revision_id;
END;
$$;


ALTER FUNCTION odiseo.fn_create_material_revision(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint, p_created_by bigint) OWNER TO postgres;

--
