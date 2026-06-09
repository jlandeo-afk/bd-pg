-- Function: questions.fn_get_history_generated_questions(integer, integer, bigint, character varying, character varying)

--

CREATE FUNCTION questions.fn_get_history_generated_questions(p_perpage integer, p_npage integer, p_question_id bigint, p_type_question character varying, p_shared_status character varying) RETURNS TABLE(cycle character varying, year integer, material character varying, exam_area character varying, created_at timestamp without time zone, week integer, status boolean, automatic boolean, histories jsonb, total bigint)
    LANGUAGE plpgsql
    AS $$
                DECLARE
                    C_MORE_RECENT_USAGE_ATTEMPT SMALLINT DEFAULT 1;
                    offset_val INTEGER;
                BEGIN
                    offset_val := p_perpage * (p_npage - 1);
                    RETURN QUERY
                    WITH text_history_exam AS (
                        SELECT
                            qhh.material_exam_area_week_id,
                            qhh.parent_question_id,
                            c.description AS cycle_description,
                            tm.description AS type_material_name,
                            ea.id AS exam_area_id,
                            ea.short_description AS exam_area_short_description,
                            ea.description AS exam_area,
                            dwtm.week AS week,
                            qhh.automatic AS automatic,
                            qhh.created_at,
                            CAST(EXTRACT(YEAR FROM qhh.created_at) AS INTEGER) AS year,
                            qhh.updated_at IS NULL AS fl_status
                        FROM question_history_usage_exam_parent_question qhh
                            JOIN material_exam_area_week meak ON meak.id = qhh.material_exam_area_week_id
                            JOIN exam_area ea ON ea.id = meak.area_id
                            JOIN detail_week_type_mat dwtm ON meak.week_type_material_id = dwtm.id
                            JOIN type_material tm ON tm.id = dwtm.type_material_id
                            JOIN material m ON m.id = dwtm.material_id
                            JOIN cycle c ON c.id = m.cycle_id
                            WHERE 1 = 1
                            AND (
                                ( p_type_question = 'T' AND parent_question_id = p_question_id ) OR
                                ( p_type_question = 'S' AND question_id = p_question_id )
                            )
                    ), get_last_attempt_to_used AS (
                        SELECT
                            the.cycle_description,
                            the.year AS year,
                            the.type_material_name,
                            the.exam_area_short_description,
                            the.exam_area_id,
                            the.exam_area,
                            the.week,
                            the.created_at,
                            the.fl_status,
                            the.automatic,
                            ROW_NUMBER() OVER (
                                PARTITION BY
                                    the.cycle_description,
                                    the.type_material_name,
                                    the.year,
                                    the.exam_area_id,
                                    the.week
                                ORDER BY the.created_at DESC
                            ) AS absolute_version
                        FROM text_history_exam the
                    ), exam_text_history AS (
                        SELECT
                            guu.cycle_description AS cycle,
                            MAX(guu.year) AS year,
                            MIN(guu.type_material_name) AS material,
                            STRING_AGG(DISTINCT guu.exam_area_short_description, '-') AS exam_area,
                            MAX(guu.created_at) AS created_at,
                            MAX(guu.week) AS week,
                            TRUE AS status,
                            TRUE AS automatic,
                            JSONB_AGG(
                                JSONB_BUILD_OBJECT(
                                    'exam_area', guu.exam_area,
                                    'created_at', guu.created_at,
                                    'fl_status', guu.fl_status,
                                    'automatic', guu.automatic,
                                    'area_id', guu.exam_area_id
                                )
                                ORDER BY guu.created_at
                            ) AS histories
                        FROM get_last_attempt_to_used guu
                        WHERE guu.absolute_version = 1
                        GROUP BY guu.cycle_description
                    ), latest_material_ballot AS (
                        SELECT
                            mbq.created_at,
                            mbq.fl_status,
                            mbq.question_history_id,
                            mbq.week_type_material_id,
                            ROW_NUMBER() OVER (PARTITION BY mbq.question_id, mbq.week_type_material_id ORDER BY mbq.created_at DESC) AS rn
                        FROM material_ballot_question mbq
                        LEFT JOIN question_subtopic qs ON qs.question_id = mbq.question_id
                        LEFT JOIN question_shares qsh ON qsh.subtopic_id = mbq.subtopic_id AND qsh.deleted_at IS NULL
                        LEFT JOIN LATERAL jsonb_array_elements(mbq.subquestion) AS subq_elem ON TRUE
                        WHERE CASE 
                                WHEN p_type_question = 'T' THEN mbq.parent_question_id = p_question_id
                                ELSE mbq.question_id = p_question_id 
                                OR (subq_elem->>'question_id')::int = p_question_id
                            END
                        AND (
                            CASE
                                WHEN p_shared_status = 'shared' THEN
                                    qsh.subtopic_id = mbq.subtopic_id

                                ELSE
                                    qs.subtopic_id = mbq.subtopic_id
                            END
                        )
                    ), cte_material_ballot_question AS (
                        SELECT
                            lmb.created_at,
                            lmb.fl_status,
                            lmb.question_history_id,
                            lmb.week_type_material_id
                        FROM latest_material_ballot lmb
                        WHERE rn = 1
                        ORDER BY week_type_material_id
                    ), latest_material_exam AS (
                        SELECT
                            meq.created_at,
                            meq.fl_status,
                            meq.question_history_id,
                            meq.material_exam_area_week_id,
                            meaw.area_id,
                            ea.description,
                            ea.short_description,
                            meaw.week_type_material_id,
                            ROW_NUMBER() OVER (PARTITION BY meq.question_id, meq.material_exam_area_week_id ORDER BY meq.created_at DESC) AS rn
                        FROM material_exam_question meq
                        JOIN material_exam_area_week meaw ON meq.material_exam_area_week_id = meaw.id
                        JOIN exam_area ea ON meaw.area_id = ea.id
                        WHERE meq.question_id = p_question_id
                    ), cte_material_exam_question AS (
                        SELECT
                            lme.created_at,
                            lme.fl_status,
                            lme.question_history_id,
                            lme.material_exam_area_week_id,
                            lme.area_id,
                            lme.description,
                            lme.short_description,
                            lme.week_type_material_id
                        FROM latest_material_exam lme
                        WHERE rn = 1
                        ORDER BY material_exam_area_week_id
                    ), group_material_exam_question AS (
                        SELECT
                        MAX(lme.created_at) AS created_at,
                        BOOL_OR(lme.fl_status) AS fl_status,
                        MAX(lme.question_history_id) AS question_history_id,
                        lme.week_type_material_id,
                        STRING_AGG(lme.short_description, '-') AS combined_areas
                        FROM latest_material_exam lme
                        WHERE lme.rn = 1
                        GROUP BY lme.week_type_material_id
                        ORDER BY lme.week_type_material_id
                    ), cte_history_question AS (
                        SELECT
                            c.description cycle,
                            COALESCE(CAST(EXTRACT(YEAR FROM mbq.created_at) AS INTEGER), CAST(EXTRACT(YEAR FROM meq.created_at) AS INTEGER)) as year,
                            (CASE
                                WHEN dwtm.parent_type_material_id is NOT NULL
                                    THEN CONCAT(tm3.description, '(', tm.description, ')')
                                ELSE COALESCE(tm.description, tm2.description)
                            END)::VARCHAR material,
                            (CASE
                                WHEN meq.combined_areas IS NOT NULL
                                    THEN meq.combined_areas
                                ELSE null
                            END)::VARCHAR AS exam_area,
                            COALESCE(mbq.created_at, meq.created_at) created_at,
                            COALESCE(dwtm.week, dwtm2.week)::integer week,
                            COALESCE(mbq.fl_status, meq.fl_status) status,
                            qhc.automatic,
                            COALESCE(
                                (SELECT jsonb_agg(row_to_json(h))
                                FROM (
                                    SELECT cmeq.created_at, cmeq.fl_status, cmeq.question_history_id, cmeq.area_id, cmeq.description AS exam_area, qhc2.automatic
                                    FROM cte_material_exam_question cmeq
                                    JOIN question_history_cycle qhc2 ON cmeq.question_history_id = qhc2.id
                                    WHERE cmeq.week_type_material_id =  meq.week_type_material_id
                                    ORDER BY cmeq.created_at DESC, cmeq.area_id ASC
                                ) AS h
                            ), '[]'::JSONB) AS histories
                        FROM question_history_cycle qhc
                        LEFT JOIN LATERAL jsonb_array_elements(qhc.subquestion) AS subq_elem ON
                        ( (subq_elem->>'question_id')::int = p_question_id OR 'T' != 'T' )
                        JOIN cycle c ON c.id = qhc.cycle_id
                        LEFT JOIN cte_material_ballot_question mbq ON mbq.question_history_id = qhc.id
                        LEFT JOIN group_material_exam_question meq on meq.question_history_id = qhc.id
                        LEFT JOIN detail_week_type_mat dwtm ON dwtm.id = mbq.week_type_material_id
                        LEFT JOIN detail_week_type_mat dwtm2 on dwtm2.id = meq.week_type_material_id
                        LEFT JOIN type_material tm ON tm.id = dwtm.type_material_id
                        LEFT JOIN type_material tm2 ON tm2.id = dwtm2.type_material_id
                        LEFT JOIN type_material tm3 ON tm3.id = dwtm.parent_type_material_id
                        WHERE 
                        CASE 
                            WHEN p_type_question = 'T' THEN qhc.parent_question_id = p_question_id
                            ELSE qhc.question_id = p_question_id OR (subq_elem->>'question_id')::int = p_question_id
                        END
                        AND (mbq.question_history_id IS NOT NULL OR meq.question_history_id IS NOT NULL)
                    ), cte_ballot_and_exam_test_history AS (
                        SELECT * FROM cte_history_question
                        UNION ALL
                        SELECT * FROM exam_text_history 
                    )
                    SELECT chq.*, COUNT(*) OVER() AS total
                    FROM cte_ballot_and_exam_test_history chq
                    ORDER BY chq.created_at DESC
                    LIMIT p_perpage
                    OFFSET offset_val;
                END;
                $$;


ALTER FUNCTION questions.fn_get_history_generated_questions(p_perpage integer, p_npage integer, p_question_id bigint, p_type_question character varying, p_shared_status character varying) OWNER TO postgres;

--
