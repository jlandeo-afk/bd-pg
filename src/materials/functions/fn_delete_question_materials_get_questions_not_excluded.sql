-- Function: questions.fn_delete_question_materials_get_questions_not_excluded(bigint, smallint, jsonb, bigint, boolean)

--

CREATE FUNCTION questions.fn_delete_question_materials_get_questions_not_excluded(p_material_id bigint, p_week smallint, p_type_material_ids jsonb, p_deleted_by bigint, p_fl_validate_code boolean) RETURNS TABLE(id bigint, code character varying, course_id smallint, topic_id smallint, level_id smallint, level smallint, type character varying, status character varying, subtopic_id integer, frequent_subtopic boolean, cycle_id integer, week smallint, type_material_id smallint, history jsonb)
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_cycle_id BIGINT;
                v_week_type_material_id BIGINT;
                v_material_exam_question RECORD;
                v_material_ballot_question RECORD;
                v_type_material RECORD;
                v_updated_week_ids BIGINT[];
                v_updated_history_ids BIGINT[];
                meaw BIGINT;
                v_count_questions_ballot int;
                v_count_questions_exam int;
                v_count_total int;
            BEGIN
                -- Obtener ciclo del material
                SELECT m.cycle_id INTO v_cycle_id FROM material m WHERE m.id = p_material_id LIMIT 1;

                -- Se recorre los tipos de materiales
                FOR v_type_material IN
                    SELECT tm.id, tm.fl_exam
                    FROM type_material tm
                    WHERE tm.id = ANY(SELECT (jsonb_array_elements_text(p_type_material_ids)::SMALLINT))
                LOOP
                    --Se limpia las rutas de los materiales generados, se obtiene el id de la semana de material
                    UPDATE detail_week_type_mat detm
                        SET url_solution = null,
                        url_without_solution = null,
                        fl_process_status = 1,
                        fl_process_status_without = 1,
                        fl_process_class_mat = 1,
                        url_zip_class_mat = null,
                        url_quality = null,
                        url_without_quality = null,
                        fl_process_quality = 1,
                        fl_process_without_quality = 1,
                        updated_by = p_deleted_by,
                        updated_at = now()
                    WHERE detm.material_id = p_material_id
                        AND detm.week = p_week
                        AND detm.type_material_id = v_type_material.id
                        AND detm.fl_status = true
                    RETURNING detm.id INTO v_week_type_material_id;

                    IF v_week_type_material_id IS NOT NULL THEN
                        -- Se valida si es examen el material
                        IF v_type_material.fl_exam IS TRUE THEN

                            -- Se limpia las rutas de los examenes generados con sus areas
                            WITH updated_meaw AS (
                                UPDATE material_exam_area_week meaw
                                SET url_solution = null,
                                    url_without_solution = null,
                                    fl_process_status = 1,
                                    fl_process_status_without = 1,
                                    url_quality = null,
                                    url_without_quality = null,
                                    fl_process_quality = 1,
                                    fl_process_without_quality = 1,
                                    data_missing_course_config = null,
                                    missing_config_message = null,
                                    number_pages = null,
                                    updated_by = p_deleted_by,
                                    updated_at = now()
                                WHERE meaw.week_type_material_id = v_week_type_material_id
                                AND meaw.fl_status = true
                                RETURNING meaw.id
                            )
                            SELECT array_agg(updated_meaw.id) FROM updated_meaw INTO v_updated_week_ids;

                            -- Elimina las preguntas de los examenes
                            WITH updated_meq AS (
                                UPDATE material_exam_question meq
                                SET fl_status = false,
                                    deleted_by = p_deleted_by,
                                    deleted_at = now()
                                WHERE meq.material_exam_area_week_id = ANY(v_updated_week_ids)
                                RETURNING meq.question_history_id
                            )
                            SELECT array_agg(DISTINCT updated_meq.question_history_id) FROM updated_meq INTO v_updated_history_ids;
                        ELSE
                            -- Elimina las preguntas de los balotarios
                            WITH updated_mbq AS (
                                UPDATE material_ballot_question mbq
                                SET fl_status = false,
                                    deleted_by = p_deleted_by,
                                    deleted_at = now()
                                WHERE mbq.week_type_material_id = v_week_type_material_id
                                    AND mbq.fl_status = true
                                RETURNING mbq.question_history_id
                            )
                            SELECT array_agg(DISTINCT updated_mbq.question_history_id) FROM updated_mbq INTO v_updated_history_ids;
                        END IF;

                        -- Elimina el historial siempre y cuando no haya mas data en balotario y examen
                        UPDATE question_history_cycle qhc
                        SET fl_status = false,
                            deleted_by = p_deleted_by,
                            deleted_at = now()
                        WHERE qhc.id = ANY(v_updated_history_ids)
                        AND NOT EXISTS (
                            SELECT 1 FROM material_ballot_question mbq
                            WHERE mbq.question_history_id = qhc.id AND mbq.fl_status = true
                        )
                        AND NOT EXISTS (
                            SELECT 1 FROM material_exam_question meq
                            WHERE meq.question_history_id = qhc.id AND meq.fl_status = true
                        )
                        AND qhc.fl_status = true;
                    END IF;
                END LOOP;

                RETURN QUERY
                SELECT
                    qnew.id,
                    qnew.code,
                    qnew.course_id,
                    qnew.topic_id,
                    qnew.level_id,
                    qnew.level,
                    qnew.type,
                    qnew.status,
                    qnew.subtopic_id,
                    qnew.frequent_subtopic,
                    qnew.cycle_id,
                    qnew.week,
                    qnew.type_material_id,
                    qnew.history
                FROM fn_list_questions_verified_and_not_excluded(p_material_id) qnew;
            END;
            $$;


ALTER FUNCTION questions.fn_delete_question_materials_get_questions_not_excluded(p_material_id bigint, p_week smallint, p_type_material_ids jsonb, p_deleted_by bigint, p_fl_validate_code boolean) OWNER TO postgres;

--
