-- Function: materials.fn_register_material_ballot_per_period(bigint, bigint, smallint, smallint, bigint)

--

CREATE FUNCTION materials.fn_register_material_ballot_per_period(p_material_id bigint, p_type_material_id bigint, p_start_week smallint, p_end_week smallint, p_created_by bigint) RETURNS TABLE(id bigint, type_material character varying)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_material_per_period_id BIGINT;
            v_material_per_period_ballot_id BIGINT;
            v_type_material VARCHAR;
        BEGIN
            -- Traer el nombre del tipo material
            SELECT
                tm.description INTO v_type_material
            FROM type_material tm
            WHERE tm.id = p_type_material_id;

            -- Obtener el id del material por period
            SELECT
                mpp.id INTO v_material_per_period_id
            FROM material_per_period mpp
            WHERE mpp.material_id = p_material_id
                AND mpp.type_material_id = p_type_material_id
                AND mpp.deleted_by IS NULL
            LIMIT 1;

            -- Insertar si no lo encuentra
            IF v_material_per_period_id IS NULL THEN
                INSERT INTO material_per_period AS mpp2 (
                    material_id,
                    type_material_id,
                    created_by,
                    created_at
                )
                VALUES (
                    p_material_id,
                    p_type_material_id,
                    p_created_by,
                    NOW()
                )
                RETURNING mpp2.id INTO v_material_per_period_id;
            END IF;

            -- Se elimina los periodos del tipo material que esten dentro del rango para evitar duplicados
            UPDATE material_per_period_ballot_url mppbu
            SET deleted_by = p_created_by,
                deleted_at = NOW()
            WHERE mppbu.material_per_period_ballot_id IN (
                SELECT mppb.id
                FROM material_per_period_ballot mppb
                WHERE mppb.material_per_period_id = v_material_per_period_id
                AND (
                    mppb.start_week BETWEEN p_start_week AND p_end_week
                    OR mppb.end_week BETWEEN p_start_week AND p_end_week
                )
                AND NOT (mppb.start_week = p_start_week AND mppb.end_week = p_end_week)
            );

            UPDATE material_per_period_ballot mppb2
            SET deleted_by = p_created_by,
                deleted_at = NOW()
            WHERE mppb2.material_per_period_id = v_material_per_period_id
                AND (
                    mppb2.start_week BETWEEN p_start_week AND p_end_week
                    OR mppb2.end_week BETWEEN p_start_week AND p_end_week
                )
                AND NOT (mppb2.start_week = p_start_week AND mppb2.end_week = p_end_week);

            -- Validar si existe
            SELECT
                mppb3.id INTO v_material_per_period_ballot_id
            FROM material_per_period_ballot mppb3
            WHERE mppb3.material_per_period_id = v_material_per_period_id
                AND mppb3.start_week = p_start_week
                AND mppb3.end_week = p_end_week
                AND mppb3.deleted_by IS NULL
            LIMIT 1;

            IF v_material_per_period_ballot_id IS NULL THEN
                INSERT INTO material_per_period_ballot AS mppb4 (
                    material_per_period_id,
                    start_week,
                    end_week,
                    fl_config_type,
                    lower_level_limit,
                    upper_level_limit,
                    created_by,
                    created_at
                )
                VALUES (
                    v_material_per_period_id,
                    p_start_week,
                    p_end_week,
                    true,
                    0,
                    0,
                    p_created_by,
                    NOW()
                )
                RETURNING mppb4.id INTO v_material_per_period_ballot_id;
            END IF;

            RETURN QUERY
            SELECT v_material_per_period_ballot_id, v_type_material;
        END;
        $$;


ALTER FUNCTION materials.fn_register_material_ballot_per_period(p_material_id bigint, p_type_material_id bigint, p_start_week smallint, p_end_week smallint, p_created_by bigint) OWNER TO postgres;

--
