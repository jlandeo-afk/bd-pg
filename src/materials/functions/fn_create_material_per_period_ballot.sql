-- Function: materials.fn_create_material_per_period_ballot(bigint, smallint, smallint, smallint, boolean, smallint, smallint, bigint)

--

CREATE FUNCTION materials.fn_create_material_per_period_ballot(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint, p_fl_config_type boolean, p_lower_level_limit smallint, p_upper_level_limit smallint, p_created_by bigint) RETURNS TABLE(id bigint, material_per_period_ballot_id bigint, week smallint, cycle_id bigint, start_date date, type_material_id smallint, type_material character varying, parent_type_material_id smallint, fl_exam boolean, has_questions boolean, exists_per_period boolean, courses jsonb, courses_for_text jsonb, university_id smallint, headquarte_id smallint)
    LANGUAGE plpgsql
    AS $$
                    DECLARE
                        v_ids_children INT[];
                        v_exists BOOLEAN = TRUE;
                        v_material_per_period_id BIGINT;
                        v_material_per_period_ballot_id BIGINT;
                        v_week SMALLINT;
                        v_son_tm_id SMALLINT;
                        v_parent_tm_id SMALLINT;
                        v_detail_week_type_mat_id BIGINT;
                        v_details_id bigint[] := '{}';
                        v_period_has_missing_questions BOOLEAN := FALSE;
                        v_period_has_missing_courses BOOLEAN := FALSE;
                        v_period_has_missing_text BOOLEAN := FALSE;
                        v_week_has_missing_questions BOOLEAN := FALSE;
                        v_week_has_missing_courses BOOLEAN := FALSE;
                        v_week_has_missing_text BOOLEAN := FALSE;
                    BEGIN
                        -- Obtener todos los IDs de los hijos en un array
                        SELECT CASE
                            WHEN EXISTS (SELECT 1 FROM type_material tm WHERE tm.parent_id = p_type_material_id AND tm.fl_status = true)
                            THEN ARRAY(SELECT tm.id FROM type_material tm WHERE tm.parent_id = p_type_material_id AND tm.fl_status = true)
                            ELSE ARRAY[p_type_material_id]
                        END INTO v_ids_children;

                        -- Obtener el id del material por period
                        SELECT
                            mpp.id INTO v_material_per_period_id
                        FROM material_per_period mpp
                        WHERE 1 = 1
                        AND mpp.material_id = p_material_id
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

                        -- Verificar si hay registro de periodo en el material
                        SELECT
                            mppb.id INTO v_material_per_period_ballot_id
                        FROM material_per_period_ballot mppb
                        WHERE 1 = 1
                        AND mppb.material_per_period_id = v_material_per_period_id
                        AND mppb.start_week = p_start_week
                        AND mppb.end_week = p_end_week
                        AND mppb.deleted_by IS NULL
                        LIMIT 1;

                        -- Si ya existe se retorna sin agregar nada
                        IF v_material_per_period_ballot_id IS NOT NULL THEN
                            RETURN QUERY
                            SELECT
                                NULL::BIGINT,
                                NULL::BIGINT,
                                NULL::SMALLINT,
                                NULL::BIGINT,
                                NULL::DATE,
                                NULL::SMALLINT,
                                NULL::VARCHAR,
                                NULL::SMALLINT,
                                NULL::BOOLEAN,
                                NULL::BOOLEAN,
                                v_exists AS exists_per_period,
                                '[]'::JSONB,
                                '[]'::JSONB,
                                NULL::SMALLINT,
                                NULL::SMALLINT
                            ;
                        ELSE
                            v_exists := FALSE;

                            WITH remove_overlapping_periods_in_ballot AS ( -- Se elimina los periodos del tipo material que estén dentro del rango para evitar duplicados
                                UPDATE material_per_period_ballot mppb
                                SET
                                    deleted_by = p_created_by,
                                    deleted_at = NOW()
                                WHERE 1 = 1
                                AND mppb.material_per_period_id = v_material_per_period_id
                                AND ( mppb.start_week BETWEEN p_start_week AND p_end_week OR mppb.end_week BETWEEN p_start_week AND p_end_week )
                                AND NOT ( mppb.start_week = p_start_week AND mppb.end_week = p_end_week )
                                RETURNING mppb.id AS material_period_id
                            ), remove_material_per_period_ballot_url AS ( -- Se remueven las urls asociadas
                                UPDATE material_per_period_ballot_url mbppbu
                                    SET
                                        deleted_by = p_created_by,
                                        deleted_at = NOW()
                                WHERE mbppbu.material_per_period_ballot_id IN ( SELECT rmv.material_period_id FROM remove_overlapping_periods_in_ballot rmv )
                                RETURNING mbppbu.id
                            ) UPDATE material_per_period_ballot_class class_urls -- Se remueven las urls de los cursos individuales del material de clases
                                SET
                                    deleted_by = p_created_by,
                                    deleted_at = NOW()
                            WHERE class_urls.material_per_period_ballot_url_id IN (SELECT cls.id FROM remove_material_per_period_ballot_url cls);

                            -- Se inserta material por periodo
                            INSERT INTO material_per_period_ballot AS mppx (
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
                                p_fl_config_type,
                                p_lower_level_limit,
                                p_upper_level_limit,
                                p_created_by,
                                NOW()
                            ) RETURNING mppx.id INTO v_material_per_period_ballot_id;

                            FOR v_week, v_son_tm_id, v_parent_tm_id IN
                                SELECT
                                    tmdt.week,
                                    ttm.id AS son_type_material_id,
                                    ttm.parent_id AS parent_type_material_id
                                FROM type_material_detail_template tmdt
                                LEFT JOIN (
                                    SELECT * FROM type_material tm
                                    WHERE tm.id IN (SELECT unnest(v_ids_children) AS type_material_id)
                                ) ttm ON 1 = 1
                                WHERE 1 = 1
                                AND tmdt.type_material_id = p_type_material_id
                                AND tmdt.week BETWEEN p_start_week AND p_end_week
                                AND tmdt.fl_status = true
                                ORDER BY tmdt.week ASC, ttm.id ASC
                            LOOP
                                WITH insert_new_detail_week_type AS ( -- Insertar o actualizar uno desactivado
                                    INSERT INTO detail_week_type_mat AS dwtm(
                                        material_id,
                                        week,
                                        type_material_id,
                                        parent_type_material_id,
                                        fl_config_type,
                                        limit_lower_question,
                                        limit_upper_question,
                                        created_by,
                                        created_at
                                    )
                                    VALUES(
                                        p_material_id,
                                        v_week,
                                        v_son_tm_id,
                                        v_parent_tm_id,
                                        p_fl_config_type,
                                        p_lower_level_limit,
                                        p_upper_level_limit,
                                        p_created_by,
                                        NOW()
                                    )
                                    ON CONFLICT ON CONSTRAINT ux_detail_week_type_mat
                                    DO UPDATE
                                        SET
                                            parent_type_material_id = EXCLUDED.parent_type_material_id,
                                            fl_config_type = EXCLUDED.fl_config_type,
                                            limit_lower_question = EXCLUDED.limit_lower_question,
                                            limit_upper_question = EXCLUDED.limit_upper_question,
                                            updated_by = p_created_by,
                                            updated_at = NOW(),
                                            fl_status = TRUE,
                                            deleted_by = NULL,
                                            deleted_at = NULL
                                    RETURNING dwtm.id, dwtm.data_incomplete_questions, dwtm.data_missing_course_config, dwtm.data_missing_text
                                ) SELECT -- Se ingresa data que corresponde a la semana en cuestión
                                    iwt.id,
                                    iwt.data_incomplete_questions IS NOT NULL,
                                    iwt.data_missing_course_config IS NOT NULL,
                                    iwt.data_missing_text IS NOT NULL
                                INTO
                                    v_detail_week_type_mat_id,
                                    v_week_has_missing_questions,
                                    v_week_has_missing_courses,
                                    v_week_has_missing_text
                                FROM insert_new_detail_week_type AS iwt
                                LIMIT 1;

                                v_period_has_missing_questions := v_period_has_missing_questions OR v_week_has_missing_questions;
                                v_period_has_missing_courses := v_period_has_missing_courses OR v_week_has_missing_courses;
                                v_period_has_missing_text := v_period_has_missing_text OR v_week_has_missing_text;

                                v_details_id := ARRAY_APPEND(v_details_id, v_detail_week_type_mat_id);
                            END LOOP;

                            -- Se actualiza los campos de faltantes si es que los hay
                            UPDATE material_per_period_ballot mb
                            SET
                                fl_missing_questions = v_period_has_missing_questions,
                                fl_missing_courses = v_period_has_missing_courses,
                                fl_missing_text = v_period_has_missing_text
                            WHERE mb.id = v_material_per_period_ballot_id;

                            RETURN QUERY
                            WITH get_courses_generic AS (
                                SELECT DISTINCT
                                    tmc.course_id,
                                    tmc.type_material_id
                                FROM type_material_course tmc
                                WHERE tmc.type_material_id IN (SELECT unnest(v_ids_children) AS type_material_id)
                                    AND tmc.is_generic = true
                                    AND tmc.fl_status = true
                                    AND tmc.amount_question > 0
                            ), get_courses_text_generic AS (
                                SELECT DISTINCT
                                    tmc.course_id,
                                    tmc.type_material_id
                                FROM type_material_course tmc
                                WHERE tmc.type_material_id IN (SELECT unnest(v_ids_children) AS type_material_id)
                                    AND tmc.is_generic_text = true
                                    AND tmc.amount_text > 0
                                    AND tmc.fl_status = true
                            ), get_courses_not_generic AS (
                                SELECT DISTINCT
                                    tmc.course_id,
                                    tm.id AS type_material_id
                                FROM materials.type_material tm
                                JOIN materials.type_material_detail_template tmdt ON tmdt.type_material_id = tm.id
                                    AND tmdt.fl_status = true
                                JOIN materials.type_material_course tmc ON tmc.type_material_id = tm.id
                                LEFT JOIN materials.type_material_detail_courses tmdc ON tmdc.type_material_course_id = tmc.id
                                    AND tmdc.type_material_detail_template_id = tmdt.id
                                WHERE tm.id IN (SELECT unnest(v_ids_children) AS type_material_id)
                                    AND tmc.is_generic = false
                                    AND tmdt.week BETWEEN p_start_week AND p_end_week
                                    AND tmdc.amount_question > 0
                            ), get_courses_text_not_generic AS (
                                SELECT DISTINCT
                                    tmc.course_id,
                                    tm.id AS type_material_id
                                FROM materials.type_material tm
                                JOIN materials.type_material_detail_template tmdt ON tmdt.type_material_id = tm.id
                                    AND tmdt.fl_status = true
                                JOIN materials.type_material_course tmc ON tmc.type_material_id = tm.id
                                LEFT JOIN materials.type_material_detail_course_texts tmdct ON tmdct.type_material_course_id = tmc.id
                                    AND tmdct.type_material_detail_template_id = tmdt.id
                                WHERE tm.id IN (SELECT unnest(v_ids_children) AS type_material_id)
                                    AND tmc.is_generic_text = false
                                    AND tmdt.week BETWEEN p_start_week AND p_end_week
                                    AND tmdct.amount_text > 0
                            ), get_courses AS (
                                SELECT
                                    gcg.course_id,
                                    gcg.type_material_id
                                FROM get_courses_generic gcg
                                UNION ALL
                                SELECT
                                    gcng.course_id,
                                    gcng.type_material_id
                                FROM get_courses_not_generic gcng
                            ), get_courses_text AS (
                                SELECT
                                    gcg.course_id,
                                    gcg.type_material_id
                                FROM get_courses_text_generic gcg
                                UNION ALL
                                SELECT
                                    gcng.course_id,
                                    gcng.type_material_id
                                FROM get_courses_text_not_generic gcng
                            )
                            SELECT
                                dwtm.id,
                                v_material_per_period_ballot_id,
                                dwtm.week,
                                m.cycle_id,
                                c.start_date,
                                dwtm.type_material_id,
                                tm.description AS type_material,
                                dwtm.parent_type_material_id,
                                tm.fl_exam,
                                CASE
                                    WHEN mbqg.total > 0 THEN TRUE
                                    ELSE FALSE
                                END AS has_questions,
                                v_exists AS exists_per_period,
                                COALESCE((
                                    SELECT jsonb_agg(gc.course_id ORDER BY gc.course_id ASC)
                                    FROM get_courses gc
                                    WHERE gc.type_material_id = dwtm.type_material_id
                                ), '[]'::JSONB) AS courses,
                                COALESCE((
                                    SELECT jsonb_agg(gc.course_id ORDER BY gc.course_id ASC)
                                    FROM get_courses_text gc
                                    WHERE gc.type_material_id = dwtm.type_material_id
                                ), '[]'::JSONB) AS courses_for_text,
                                m.university_id,
                                m.headquarte_id
                            FROM detail_week_type_mat dwtm
                            INNER JOIN material m ON dwtm.material_id = m.id
                            INNER JOIN type_material tm ON dwtm.type_material_id = tm.id
                            LEFT JOIN cycle c ON m.cycle_id = c.id
                            LEFT JOIN (
                                SELECT
                                    mbq.week_type_material_id, COUNT(mbq.*) AS total
                                FROM material_ballot_question mbq
                                WHERE mbq.fl_status = true
                                  AND (mbq.question_id IS NOT NULL OR mbq.parent_question_id IS NOT NULL)
                                GROUP BY week_type_material_id
                            ) mbqg ON mbqg.week_type_material_id = dwtm.id
                            WHERE dwtm.id = ANY (v_details_id)
                            ORDER BY
                                dwtm.week ASC,
                                LEFT(tm.description, 1);
                        END IF;
                    END;
                    $$;


ALTER FUNCTION materials.fn_create_material_per_period_ballot(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint, p_fl_config_type boolean, p_lower_level_limit smallint, p_upper_level_limit smallint, p_created_by bigint) OWNER TO postgres;

--
