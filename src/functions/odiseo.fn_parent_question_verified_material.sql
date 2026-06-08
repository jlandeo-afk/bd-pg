-- Function: odiseo.fn_parent_question_verified_material(bigint, character varying)

--

CREATE FUNCTION odiseo.fn_parent_question_verified_material(p_material_id bigint, p_type_question character varying) RETURNS TABLE(subquestion jsonb, parent_id bigint, category_id bigint, category character varying, subcategory_id bigint, subcategory character varying, level_id bigint, course_id smallint, history jsonb, code character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH tbl_material AS ( -- Obtener ciclo y universidad del material mandado
        SELECT
            m.university_id
        FROM material m
        WHERE m.id = p_material_id
    ), tbl_questions_ballot_material AS ( -- Se lista las preguntas de la tabla de balotarios
        SELECT DISTINCT mbq.parent_question_id FROM material m
        INNER JOIN detail_week_type_mat wt ON m.id = wt.material_id AND wt.fl_status = true
        INNER JOIN material_ballot_question mbq ON wt.id = mbq.week_type_material_id AND mbq.fl_status = true
        WHERE m.id = p_material_id
    ), max_start_per_question AS ( -- Se lista la fecha de inicio más reciente para cada pregunta
        SELECT
            qh.parent_question_id,
            MAX(c.start_date) AS max_start_date
        FROM question_history_cycle qh
        INNER JOIN cycle c ON qh.cycle_id = c.id
        WHERE qh.fl_status = true
        AND qh.university_id = (SELECT tm.university_id FROM tbl_material tm)
        GROUP BY qh.parent_question_id
    ), tbl_questions_history AS ( -- Se trae le historial de cada pregunta
        SELECT DISTINCT
            qh.parent_question_id,
            qh.cycle_id,
            c.description,
            c.start_date,
            c.end_date
        FROM question_history_cycle qh
        INNER JOIN cycle c ON qh.cycle_id = c.id
        INNER JOIN max_start_per_question mx ON qh.parent_question_id = mx.parent_question_id
        WHERE qh.fl_status = true
        AND qh.university_id = (SELECT tm.university_id FROM tbl_material tm)
        -- AND c.start_date BETWEEN mx.max_start_date - INTERVAL '21 days' AND mx.max_start_date
    ), 	cte_question_verified AS (
        SELECT
            pq.id AS parent_id,
            q.id question_id,
            ROW_NUMBER () OVER (
                PARTITION BY
                    q.parent_id,
                    CASE
                        WHEN q.status = 'APRB' THEN 'VERI'
                        ELSE q.status
                    END
            ) AS total_veri,
            pq.type_text_id,
            pq.type_text_subcategory_id,
            pq.level_id,
            pq.course_id,
            pq.code,
            tt.name category,
            tts.name subcategory
        FROM parent_question pq
        JOIN question q ON q.parent_id = pq.id
        JOIN type_text tt ON tt.id = pq.type_text_id
        JOIN type_text_subcategories tts ON tts.id = pq.type_text_subcategory_id
        WHERE q.status IN ('VERI', 'APRB')
        AND pq.status NOT IN ('ARCH', 'DUPL')
        ORDER BY pq.id
    ), cte_validate_min_verified AS (
    SELECT
        cqv.parent_id,
        cqv.type_text_id category_id,
        cqv.type_text_subcategory_id subcategory_id,
        cqv.level_id,
        cqv.course_id,
        cqv.code,
        cqv.category,
        cqv.subcategory
    FROM cte_question_verified cqv
    WHERE cqv.total_veri >= 2
    AND cqv.type_text_id IS NOT NULL
    AND cqv.type_text_subcategory_id IS NOT NULL
    GROUP BY
    cqv.parent_id,
    cqv.type_text_id,
    cqv.type_text_subcategory_id,
    cqv.level_id,
    cqv.course_id,
    cqv.code,
    cqv.category,
    cqv.subcategory
    ), subtopics_agg AS (
        SELECT
            qs.question_id,
            JSONB_AGG(JSONB_BUILD_OBJECT('id', qs.subtopic_id)) AS subtopics_json
        FROM question_subtopic qs
        WHERE qs.fl_status = true
        GROUP BY qs.question_id
    ), history_agg AS (
        SELECT
            qh.parent_question_id,
            JSONB_AGG(
                JSONB_BUILD_OBJECT(
                    'cycle_id', qh.cycle_id,
                'description', qh.description,
                'start_date', qh.start_date,
                'end_date', qh.end_date
                )
                ORDER BY qh.start_date DESC
            ) AS history_json
        FROM tbl_questions_history qh
        WHERE qh.cycle_id IS NOT NULL
        GROUP BY qh.parent_question_id
    )
    SELECT
        JSONB_AGG(
            JSONB_BUILD_OBJECT(
                'code', q.code,
                'question_id', q.id,
                'topic_id', q.topic_id,
                'code_topic', t.code,
                'course_id', q.course_id,
                'level_id', q.level_id,
                'subtopics', COALESCE(sa.subtopics_json, '[]'::jsonb)
            )
            ORDER BY q.course_id, t.code
        ) AS subquestion,
        cvmv.parent_id,
        cvmv.category_id,
        cvmv.category,
        cvmv.subcategory_id,
        cvmv.subcategory,
        cvmv.level_id,
        cvmv.course_id,
        COALESCE(ha.history_json, '[]'::jsonb) AS history,
        cvmv.code
    FROM cte_validate_min_verified cvmv
    JOIN question q ON q.parent_id = cvmv.parent_id
    JOIN topic t ON q.topic_id = t.id
    LEFT JOIN subtopics_agg sa ON q.id = sa.question_id
    LEFT JOIN history_agg ha ON q.parent_id = ha.parent_question_id
    WHERE q.status IN ('VERI', 'APRB')
    AND NOT EXISTS (
        SELECT 1
        FROM tbl_questions_ballot_material gpm
        WHERE
        CASE
            WHEN p_type_question = 'T' THEN gpm.parent_question_id = q.parent_id
            ELSE FALSE
        END
    )
    GROUP BY
        cvmv.parent_id,
        cvmv.category_id,
        cvmv.subcategory_id,
        cvmv.level_id,
        cvmv.course_id,
        cvmv.code,
        cvmv.category,
        cvmv.subcategory,
        ha.history_json;

    END;
    $$;


ALTER FUNCTION odiseo.fn_parent_question_verified_material(p_material_id bigint, p_type_question character varying) OWNER TO postgres;

--
