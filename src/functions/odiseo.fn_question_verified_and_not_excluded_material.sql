-- Function: odiseo.fn_question_verified_and_not_excluded_material(bigint, boolean)

--

CREATE FUNCTION odiseo.fn_question_verified_and_not_excluded_material(p_material_id bigint, p_fl_validate_code boolean) RETURNS TABLE(id bigint, code character varying, course_id smallint, topic_id smallint, level_id smallint, level smallint, type character varying, status character varying, subtopic_id integer, frequent_subtopic boolean, cycle_id integer, week smallint, type_material_id smallint, history jsonb)
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    RETURN QUERY
                    WITH tbl_material AS (
                        SELECT
                            m.university_id,
                            m.company_id
                        FROM material m
                        WHERE m.id = p_material_id
                    ), tbl_questions_ballot_material AS (
                        SELECT DISTINCT mbq.question_id FROM material m
                        INNER JOIN detail_week_type_mat wt ON m.id = wt.material_id AND wt.fl_status = true
                        INNER JOIN material_ballot_question mbq ON wt.id = mbq.week_type_material_id AND mbq.fl_status = true
                        WHERE m.id = p_material_id
                    ), tbl_questions_exam AS (
                        SELECT DISTINCT meq.question_id FROM material_exam_question meq
                        INNER JOIN material_exam_area_week meaw ON meq.material_exam_area_week_id = meaw.id AND meaw.fl_status = true
                        INNER JOIN detail_week_type_mat wt ON meaw.week_type_material_id = wt.id
                        WHERE wt.material_id = p_material_id
                        AND wt.fl_status = true
                        AND meaw.fl_status = true
                        AND meq.fl_status = true
                    ), max_start_per_question AS (
                        SELECT
                            qh.question_id,
                            MAX(c.start_date) AS max_start_date
                        FROM question_history_cycle qh
                        INNER JOIN cycle c ON qh.cycle_id = c.id
                        WHERE qh.fl_status = true
                            AND qh.university_id IN (SELECT tm.university_id FROM tbl_material tm)
                            AND c.company_id IN (SELECT tm.company_id FROM tbl_material tm)
                        GROUP BY qh.question_id
                    ), tbl_questions_history AS (
                        SELECT DISTINCT
                            qh.question_id,
                            qh.cycle_id,
                            c.description,
                            c.start_date,
                            c.end_date
                        FROM question_history_cycle qh
                        INNER JOIN cycle c ON qh.cycle_id = c.id
                        INNER JOIN max_start_per_question mx ON qh.question_id = mx.question_id
                        WHERE qh.fl_status = true
                            AND qh.university_id IN (SELECT tm.university_id FROM tbl_material tm)
                            AND c.start_date BETWEEN mx.max_start_date - INTERVAL '21 days' AND mx.max_start_date
                            AND c.company_id IN (SELECT tm.company_id FROM tbl_material tm)
                    ), tbl_questions AS (
                        SELECT
                            q.id,
                            q.code,
                            q.course_id,
                            q.topic_id,
                            q.level_id,
                            l.name::SMALLINT AS level,
                            q.type,
                            q.status,
                            qs.subtopic_id,
                            COALESCE(fus.is_frequent, false) AS frequent_subtopic,
                            qt.cycle_id,
                            qt.week_id AS week,
                            qt.type_material_id,
                            COALESCE(
                                JSON_AGG(
                                    JSONB_BUILD_OBJECT(
                                        'cycle_id', qh.cycle_id,
                                        'description', qh.description,
                                        'start_date', qh.start_date,
                                        'end_date', qh.end_date
                                    )
                                    ORDER BY qh.start_date DESC
                                ) FILTER (WHERE qh.cycle_id IS NOT NULL)::JSONB, '[]'::JSONB
                            ) AS history
                        FROM question q
                        LEFT JOIN question_subtopic qs ON qs.question_id = q.id AND qs.fl_status = true
                        LEFT JOIN question_temporary qt ON qt.question_id = q.id AND qt.fl_status = true
                        LEFT JOIN level l ON l.id = q.level_id
                        LEFT JOIN tbl_questions_history qh ON q.id = qh.question_id
                        LEFT JOIN frequent_university_subtopic fus ON fus.university_id IN (SELECT tm.university_id FROM tbl_material tm) AND fus.subtopic_id = qs.subtopic_id AND fus.fl_status = true
                        WHERE q.status IN ('VERI', 'APRB')
                        AND q.fl_status = true
                        AND l.fl_status = true
                        AND q.parent_id IS NULL
                        AND NOT EXISTS (
                            SELECT 1 FROM (
                                SELECT question_id FROM tbl_questions_ballot_material
                                UNION ALL
                                SELECT question_id FROM tbl_questions_exam
                            ) gpm
                            WHERE gpm.question_id = q.id
                        )
                        AND NOT EXISTS (
                            SELECT 1
                                FROM question_excluded_material qem
                                WHERE qem.question_id = q.id
                                AND qem.material_id = p_material_id
                                AND qem.deleted_at IS NULL
                        )
                        AND ( -- Filtra si es examen o tienen la validación en true deberia de no usar los codigos que empiezan con 'D'
                            -- Se quito la validación por codigo, ahora no toma en cuenta el codigo o que empiezan con 'D'
                            q.number_question IS NULL
                            OR q.number_question NOT LIKE 'D%'
                        )
                        GROUP BY
                            q.id,
                            q.code,
                            q.course_id,
                            q.topic_id,
                            q.level_id,
                            l.name,
                            q.type,
                            q.status,
                            qs.subtopic_id,
                            fus.is_frequent,
                            qt.cycle_id,
                            qt.week_id,
                            qt.type_material_id
                    )
                    SELECT tq.* FROM tbl_questions tq
                    ORDER BY tq.id DESC, tq.topic_id ASC, tq.subtopic_id ASC;
                END;
                $$;


ALTER FUNCTION odiseo.fn_question_verified_and_not_excluded_material(p_material_id bigint, p_fl_validate_code boolean) OWNER TO postgres;

--
