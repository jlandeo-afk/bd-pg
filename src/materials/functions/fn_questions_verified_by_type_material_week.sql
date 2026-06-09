-- Function: questions.fn_questions_verified_by_type_material_week(bigint, smallint, smallint, smallint)

--

CREATE FUNCTION questions.fn_questions_verified_by_type_material_week(p_material_id bigint, p_type_material_id smallint, p_week smallint, p_area_id smallint) RETURNS TABLE(id bigint, code character varying, course_id smallint, course text, topic_id smallint, topic text, level_id smallint, level smallint, type character varying, status character varying, subtopic_id integer, subtopic text, frequent_subtopic boolean, cycle_id integer, week smallint, type_material_id smallint, history jsonb)
    LANGUAGE plpgsql
    AS $$
                    DECLARE
                        v_fl_exam BOOLEAN;
                    BEGIN
                        IF p_area_id IS NULL THEN
                            v_fl_exam := FALSE;
                        ELSE
                            v_fl_exam := TRUE;
                        END IF;

                        RETURN QUERY
                        WITH tbl_material AS ( -- Se traen los datos del material
                            SELECT
                                m.cycle_id, m.university_id
                            FROM material m
                            LEFT JOIN cycle c ON m.cycle_id = c.id
                            WHERE m.id = p_material_id
                        ), tbl_type_material AS ( -- Se traen los datos del tipo de material
                            SELECT
                                tm.id, tmt.fl_exam, tmt.type_exam_id, tm.type_material_template_id, tm.cycle_id
                            FROM type_material tm
                            INNER JOIN type_material_template tmt ON tm.type_material_template_id = tmt.id
                            WHERE tm.id = p_type_material_id
                        ), children_type_material AS ( -- Se lista los hijos del tipo material si es que los tiene
                            SELECT DISTINCT
                                tm.id,
                                tm.fl_exam
                            FROM type_material_bound tmb
                            INNER JOIN type_material tm
                            ON tmb.type_material_template_extra_id = tm.type_material_template_id
                            WHERE 1 = 1
                            AND tmb.fl_status = true
                            AND tmb.type_material_template_id IN (SELECT type_material_template_id FROM tbl_type_material)
                            AND tm.cycle_id IN (SELECT tm2.cycle_id FROM tbl_material tm2)
                        ), has_children AS ( -- Verifica si existen hijos del tipo material
                            SELECT COUNT(*) > 0 AS has_data FROM children_type_material
                        ), type_material_chosen AS ( -- Se selecciona el tipo material si tiene hijos o no
                            SELECT tmc.*
                            FROM (
                                SELECT ctm.id, ctm.fl_exam FROM children_type_material ctm
                                WHERE (SELECT has_data FROM has_children)
                                UNION ALL
                                SELECT ctm.id, ctm.fl_exam FROM tbl_type_material ctm
                                WHERE NOT (SELECT has_data FROM has_children)
                            ) tmc
                            WHERE tmc.fl_exam = FALSE
                        ), weeks AS ( -- Se seleccionan las semanas del tipo material
                            SELECT generate_series(1, p_week) AS week
                        ), week_chosen AS ( -- Se aplica validacion a usar las semanas
                            SELECT
                                ws.week,
                                ttm.fl_exam,
                                ttm.type_exam_id,
                                CASE
                                    WHEN ttm.fl_exam IS FALSE AND ws.week = p_week THEN TRUE
                                    WHEN ttm.fl_exam IS TRUE AND ttm.type_exam_id = 3 THEN TRUE
                                    WHEN ttm.fl_exam IS TRUE AND ttm.type_exam_id <> 4 AND ws.week = p_week THEN TRUE
                                    ELSE FALSE
                                END AS week_value
                            FROM weeks ws
                            LEFT JOIN tbl_type_material ttm ON 1 = 1
                        ), tbl_syllabus AS ( -- Se listar los subtemas del syllabus
                            SELECT DISTINCT
                                sds.subtopic_id
                            FROM syllabus_subtopic_type_material stm
                            INNER JOIN syllabus_detail_subtopic sds ON stm.syllabus_detail_subtopic_id = sds.id AND sds.fl_status = true
                            INNER JOIN syllabus_topic_week stw ON sds.syllabus_topic_week_id = stw.id AND stw.fl_status = true
                            INNER JOIN syllabus_topic st ON stw.syllabus_topic_id = st.id AND st.fl_status = true
                            INNER JOIN syllabus s ON st.syllabus_id = s.id
                            INNER JOIN course co ON s.course_id = co.id
                            INNER JOIN topic top ON st.topic_id = top.id
                            INNER JOIN subtopic su ON sds.subtopic_id = su.id
                            WHERE stm.fl_status = true
                            AND s.fl_status = true
                            AND s.university_id IN (SELECT tm.university_id FROM tbl_material tm)
                            AND s.cycle_id IN (SELECT tm.cycle_id FROM tbl_material tm)
                            AND (
                                NOT EXISTS (SELECT wc.week FROM week_chosen wc WHERE wc.week_value = TRUE)
                                OR stw.week IN (SELECT wc.week FROM week_chosen wc WHERE wc.week_value = TRUE)
                            )
                            AND stm.questions_amount > 0
                            ORDER BY sds.subtopic_id ASC
                        ), tbl_questions_verified_filter AS ( -- Se listan las preguntas verificadas a usar
                            SELECT
                                fqvm.id,
                                fqvm.code,
                                fqvm.course_id,
                                CONCAT(c.code, '-', c.name) AS course,
                                fqvm.topic_id,
                                CONCAT(t.code, '-', t.name) AS topic,
                                fqvm.level_id,
                                fqvm.level,
                                fqvm.type,
                                fqvm.status,
                                fqvm.subtopic_id,
                                CONCAT(s.code, '-', s.name) AS subtopic,
                                fqvm.frequent_subtopic,
                                fqvm.cycle_id,
                                fqvm.week,
                                fqvm.type_material_id,
                                fqvm.history
                            FROM fn_question_verified_material(p_material_id, v_fl_exam) fqvm
                            INNER JOIN course c ON fqvm.course_id = c.id
                            INNER JOIN topic t ON fqvm.topic_id = t.id
                            INNER JOIN subtopic s ON fqvm.subtopic_id = s.id
                            WHERE fqvm.subtopic_id IN (SELECT tb.subtopic_id FROM tbl_syllabus tb)
                        ), tbl_questions_area AS (
                            SELECT DISTINCT
                                meq.question_id
                            FROM material_exam_question meq
                            INNER JOIN material_exam_area_week meaw ON meq.material_exam_area_week_id = meaw.id AND meaw.fl_status = true
                            INNER JOIN detail_week_type_mat dwtm ON meaw.week_type_material_id = dwtm.id AND dwtm.fl_status = true
                            WHERE dwtm.material_id = p_material_id
                                AND dwtm.week = p_week
                                AND dwtm.type_material_id = p_type_material_id
                                AND meq.fl_status = true
                                AND meaw.area_id = p_area_id
                                AND meq.question_id IS NOT NULL
                        ), tbl_questions_area_repeat AS ( -- Se listan las preguntas repetidas en otras areas
                            SELECT DISTINCT
                                meq.question_id
                            FROM material_exam_question meq
                            INNER JOIN material_exam_area_week meaw ON meq.material_exam_area_week_id = meaw.id AND meaw.fl_status = true
                            INNER JOIN detail_week_type_mat dwtm ON meaw.week_type_material_id = dwtm.id AND dwtm.fl_status = true
                            WHERE dwtm.material_id = p_material_id
                                AND dwtm.week = p_week
                                AND dwtm.type_material_id = p_type_material_id
                                AND meq.fl_status = true
                                AND (p_area_id IS NULL OR meaw.area_id <> p_area_id)
                                AND meq.question_id NOT IN (
                                    SELECT * FROM tbl_questions_area
                                )
                        ), tbl_questions_areas AS ( -- Se listan las preguntas de las areas seleccionadas
                            SELECT
                                q.id,
                                q.code,
                                q.course_id,
                                CONCAT(c.code, '-', c.name) AS course,
                                q.topic_id,
                                CONCAT(t.code, '-', t.name) AS topic,
                                q.level_id,
                                l.name::SMALLINT AS level,
                                q.type,
                                q.status,
                                qs.subtopic_id,
                                CONCAT(s.code, '-', s.name) AS subtopic,
                                COALESCE(fus.is_frequent, false) AS frequent_subtopic,
                                qt.cycle_id,
                                qt.week_id AS week,
                                qt.type_material_id,
                                '[]'::JSONB AS history
                            FROM question q
                            INNER JOIN course c ON q.course_id = c.id
                            INNER JOIN topic t ON q.topic_id = t.id
                            LEFT JOIN question_subtopic qs ON qs.question_id = q.id AND qs.fl_status = true
                            LEFT JOIN question_temporary qt ON qt.question_id = q.id AND qt.fl_status = true
                            LEFT JOIN subtopic s ON qs.subtopic_id = s.id
                            LEFT JOIN level l ON l.id = q.level_id
                            LEFT JOIN frequent_university_subtopic fus ON fus.university_id = 1 AND fus.subtopic_id = qs.subtopic_id AND fus.fl_status = true
                            WHERE 1= 1
                                AND q.id IN (SELECT * FROM tbl_questions_area_repeat)
                                AND q.status IN ('VERI', 'APRB')
                                AND q.fl_status = true
                                AND l.fl_status = true
                                AND ( -- Filtra si es examen o tienen la validación en true deberia de no usar los codigos que empiezan con 'D'
                                    -- Se quito la validación por codigo, ahora no toma en cuenta el codigo o que empiezan con 'D'
                                    q.number_question IS NULL
                                    OR q.number_question NOT LIKE 'D%'
                                )
                            ORDER BY q.id ASC
                        ), tbl_questions AS ( -- Se unen las preguntas verificadas y las de las areas
                            SELECT * FROM tbl_questions_verified_filter
                            UNION ALL
                            SELECT * FROM tbl_questions_areas
                        )
                        SELECT tq.*
                        FROM tbl_questions as tq
                        ORDER BY tq.course_id ASC, tq.topic ASC, tq.subtopic ASC, tq.id ASC;
                    END;
                    $$;


ALTER FUNCTION questions.fn_questions_verified_by_type_material_week(p_material_id bigint, p_type_material_id smallint, p_week smallint, p_area_id smallint) OWNER TO postgres;

--
