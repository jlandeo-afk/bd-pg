-- Function: materials.fn_get_ballot_questions_per_period(integer, integer, character varying, integer, integer, integer, integer, integer, integer, integer, boolean, smallint, smallint, smallint, smallint, character varying, integer, character varying, boolean, bigint)

--

CREATE FUNCTION materials.fn_get_ballot_questions_per_period(p_perpage integer, p_npage integer, p_search character varying, p_type_material_id integer, p_material_id integer, p_start_week integer, p_end_week integer, p_course_id integer, p_topic_id integer, p_subtopic_id integer, p_show_missing_questions boolean, p_university_id smallint, p_option_id smallint, p_modality_id smallint, p_version smallint, p_year character varying, p_week integer, p_question_status character varying, p_has_permission_generar_por_cursos_asignados boolean, p_employee_id bigint) RETURNS TABLE(question_id bigint, material_distribution_id bigint, type_material character varying, level_searched_id bigint, columns smallint, level_used_id bigint, level_id bigint, course_id bigint, topic_id bigint, subtopic_id bigint, code character varying, type character varying, expected_type character varying, config_alternative_id bigint, random boolean, valid_question boolean, status character varying, fl_is_manual boolean, added_in_completion boolean, removed_in_completion boolean, updated_at timestamp without time zone, subquestion json, type_question text, category character varying, category_id bigint, subcategory character varying, subcategory_id bigint, week smallint, type_material_id smallint, course_position smallint, absolute_position smallint, "position" smallint, origin_question jsonb, completed_subquestion boolean, level_to_be_found smallint, level smallint, course_code character varying, topic_code character varying, subtopic_code character varying, course character varying, topic character varying, subtopic character varying, course_correlative bigint, correlativo text, total bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    offset_val integer;
    DECLARE C_MORE_RECENT_VERSION smallint DEFAULT 1;
BEGIN
    offset_val := p_perpage * (p_npage - 1);
    RETURN QUERY WITH prepare_type_material_ids AS (
        SELECT
            CASE WHEN EXISTS (
                SELECT 1
                FROM type_material tm
                WHERE tm.parent_id = p_type_material_id
            ) THEN ARRAY (
                SELECT tm.id
                FROM type_material tm
                WHERE tm.parent_id = p_type_material_id
            )
            ELSE ARRAY[p_type_material_id]
            END AS ids
    ),
    type_material_ids AS (
        SELECT UNNEST(ids) FROM prepare_type_material_ids
    ),
    template_type_material AS (
        SELECT tmt.id AS id
        FROM type_material tm
        JOIN type_material_template tmt ON tmt.id = tm.type_material_template_id
        WHERE 1 = 1
        AND tm.type_material_template_id IS NOT NULL
        AND tm.id = p_type_material_id
    ),
    courses_ordering AS (
        SELECT
            ttmco.course_id,
            ttmco.position AS course_position,
            ttmco.university_id
        FROM template_type_material_courses_order ttmco
        WHERE 1 = 1
        AND ttmco.deleted_by IS NULL
        AND ttmco.template_type_material_id IN (
            SELECT id FROM template_type_material
        )
    ),
    type_material_valid_weeks AS (
        SELECT tdt.week
        FROM type_material_detail_template tdt
        WHERE 1 = 1
        AND tdt.type_material_id = p_type_material_id
        AND tdt.fl_status IS TRUE
    ),
    detail_week_type_mat_ids AS (
        SELECT
            dtm.id,
            dtm.type_material_id,
            dtm.week
        FROM detail_week_type_mat dtm
        WHERE dtm.material_id = p_material_id
        AND dtm.type_material_id IN (SELECT * FROM type_material_ids)
        AND dtm.week BETWEEN p_start_week AND p_end_week
        AND (p_week IS NULL OR dtm.week = p_week)
        AND dtm.week IN (SELECT * FROM type_material_valid_weeks)
        AND dtm.fl_status IS TRUE
    ),
    questions_with_distributions AS (
        SELECT
            COALESCE(q.id, mbq.id * -1) AS question_id,
            mbq.id AS material_distribution_id,
            tm.description AS type_material,
            mbq.level_id AS level_searched_id,
            q.columns AS columns,
            mbq.usage_level_id AS level_used_id,
            COALESCE(mbq.usage_level_id, mbq.level_id) AS level_id,
            mbq.course_id::bigint AS course_id,
            mbq.topic_id::bigint AS topic_id,
            mbq.subtopic_id::bigint AS subtopic_id,
            COALESCE(qsh.code, q.code, pq.code) AS code,
            COALESCE(q.type, mbq.type) AS type,
            COALESCE(mbq.type, CASE WHEN mbq.parent_question_id IS NOT NULL THEN 'T'::varchar ELSE 'D'::varchar END) AS expected_type,
            q.config_alternative_id,
            mbq.random AS random,
            COALESCE(q.id, pq.id) IS NOT NULL AS valid_question,
            q.status AS status,
            COALESCE(mbq.fl_is_manual, FALSE) AS fl_is_manual,
            mbq.added_in_completion AS added_in_completion,
            mbq.removed_in_completion AS removed_in_completion,
            COALESCE(mbq.updated_at, mbq.created_at) AS updated_at,
            (
                SELECT
                    JSON_AGG(JSON_BUILD_OBJECT(
                        'material_ballot_subquestion_id', sub.id,
                        'topic', COALESCE(t_sub.name, t_expected.name),
                        'subtopic', COALESCE(st_sub.name, st_expected.name),
                        'question_id', q_sub.id,
                        'columns', q_sub.columns,
                        'code', q_sub.code,
                        'course', COALESCE(c_sub.name, c_expected.name),
                        'topic_code', COALESCE(t_sub.code, t_expected.code),
                        'subtopic_code', COALESCE(st_sub.code, st_expected.code),
                        'course_code', COALESCE(c_sub.code, c_expected.code),
                        'description_question', q_sub.description,
                        'valid_question', q_sub.id IS NOT NULL,
                        'config_alternative_id', q_sub.config_alternative_id,
                        'origin_question', qn_sub.question_origin,
                        'course_id', COALESCE(q_sub.course_id, sub.course_id),
                        'topic_id', COALESCE(q_sub.topic_id, sub.topic_id),
                        'subtopic_id', COALESCE(q_sub.subtopic_id, sub.subtopic_id),
                        'type_question', 'S',
                        'parent_code', pq.code,
                        'category', tt.name,
                        'subcategory', tts.name,
                        'category_id', tt.id,
                        'subcategory_id', tts.id,
                        'parent_level', l.name,
                        'parent_question_id', pq.id,
                        'type_material_id', dwtmi.type_material_id,
                        'removed_in_completion', FALSE,
                        'added_in_completion', sub.added_in_completion,
                        'updated_at', sub.created_at,
                        'fl_is_manual', sub.fl_is_manual,
                        'level_id', l.id,
                        'material_distribution_id', mbq.id,
                        'correlativo', UPPER(LEFT (tm.description, 4)),
                        'status', sub.state
                    ) ORDER BY sub.position)
                FROM material_ballot_subquestions sub
                LEFT JOIN question q_sub ON sub.question_id = q_sub.id
                LEFT JOIN topic AS t_sub ON q_sub.topic_id = t_sub.id
                LEFT JOIN subtopic AS st_sub ON q_sub.subtopic_id = st_sub.id
                LEFT JOIN course c_sub ON q_sub.course_id = c_sub.id
                LEFT JOIN topic t_expected ON sub.topic_id = t_expected.id
                LEFT JOIN subtopic st_expected ON sub.subtopic_id = st_expected.id
                LEFT JOIN course c_expected ON sub.course_id = c_expected.id
                LEFT JOIN v_all_question_origins_by_university qn_sub ON q_sub.id = qn_sub.question_id
                    AND qn_sub.university_id = m.university_id
                WHERE sub.material_ballot_question_id = mbq.id
                  AND sub.fl_status = TRUE
            ) AS subquestion,
            CASE WHEN mbq.type_text_id IS NULL THEN 'P' ELSE 'T' END AS type_question,
            tt.name AS category,
            tt.id AS category_id,
            tts.name AS subcategory,
            tts.id AS subcategory_id,
            dwtmi.week,
            mbq.type_material_id,
            ccor.course_position AS course_position,
            mbq.absolute_position AS absolute_position,
            mbq.position AS "position",
            qn.question_origin,
            COALESCE(mbq.completed_subquestion, FALSE) AS completed_subquestion
        FROM material_ballot_question mbq
        JOIN detail_week_type_mat_ids dwtmi ON mbq.week_type_material_id = dwtmi.id
        JOIN detail_week_type_mat dwtm ON mbq.week_type_material_id = dwtm.id
        JOIN material m ON m.id = dwtm.material_id
        LEFT JOIN question q ON q.id = mbq.question_id
        -- Combinación: Se rescata el LATERAL JOIN de question_shares
        LEFT JOIN LATERAL (
            SELECT qs.code
            FROM question_shares qs
            WHERE qs.question_id = q.id
            AND qs.course_id = mbq.course_id
            AND qs.topic_id = mbq.topic_id
            AND qs.subtopic_id = mbq.subtopic_id
            AND qs.deleted_at IS NULL
            ORDER BY qs.updated_at DESC NULLS LAST
            LIMIT 1
        ) qsh ON TRUE
        LEFT JOIN parent_question pq ON pq.id = mbq.parent_question_id AND pq.fl_status IS TRUE
        LEFT JOIN type_material tm ON tm.id = mbq.type_material_id
        LEFT JOIN courses_ordering ccor ON ccor.course_id = mbq.course_id AND ccor.university_id IS NULL
        LEFT JOIN type_text tt ON tt.id = mbq.type_text_id
        LEFT JOIN type_text_subcategories tts ON tts.id = mbq.type_text_subcategory_id
        LEFT JOIN level l ON l.id = mbq.level_id
        LEFT JOIN v_all_question_origins_by_university qn ON q.id = qn.question_id AND qn.university_id = m.university_id
        WHERE 1 = 1
        AND mbq.fl_status IS TRUE
        AND (p_question_status IS NULL OR q.status = p_question_status)
        AND (p_university_id IS NULL OR EXISTS (
            SELECT 1 FROM JSONB_ARRAY_ELEMENTS(qn.question_origin) AS origin
            WHERE origin ->> 'type' = 'university' AND (origin ->> 'id')::smallint = p_university_id
        ))
        AND (p_option_id IS NULL OR EXISTS (
            SELECT 1 FROM JSONB_ARRAY_ELEMENTS(qn.question_origin) AS origin
            WHERE origin ->> 'type' = 'option' AND (origin ->> 'id')::smallint = p_option_id
        ))
        AND (p_modality_id IS NULL OR EXISTS (
            SELECT 1 FROM JSONB_ARRAY_ELEMENTS(qn.question_origin) AS origin
            WHERE origin ->> 'type' = 'modality' AND (origin ->> 'id')::smallint = p_modality_id
        ))
        AND (p_version IS NULL OR EXISTS (
            SELECT 1 FROM JSONB_ARRAY_ELEMENTS(qn.question_origin) AS origin
            WHERE origin ->> 'type' = 'version' AND origin ->> 'name' = fn_number_to_roman(p_version)
        ))
        AND (p_year IS NULL OR EXISTS (
            SELECT 1 FROM JSONB_ARRAY_ELEMENTS(qn.question_origin) AS origin
            WHERE origin ->> 'type' = 'year' AND origin ->> 'name' = p_year
        ))
    ),
    questions_with_distributions_with_additional_data AS (
        SELECT
            qwd.*,
            COALESCE(NULLIF(l2.name, ''), l2.description)::smallint AS level_to_be_found,
            COALESCE(NULLIF(l.name, ''), l.description)::smallint AS "level",
            c.code AS course_code,
            t.code AS topic_code,
            s.code AS subtopic_code,
            c.name AS course,
            t.name AS topic,
            s.name AS subtopic,
            CASE WHEN qwd.valid_question THEN
                SUM(CASE WHEN qwd.valid_question IS TRUE THEN 1 ELSE 0 END) OVER (
                    PARTITION BY qwd.week, qwd.type_material_id, qwd.course_position 
                    ORDER BY (qwd.question_id IS NULL), qwd.type_material_id, qwd.course_position, qwd.absolute_position, t.code, qwd."position" 
                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                )
            ELSE NULL END AS course_correlative
        FROM questions_with_distributions qwd
        LEFT JOIN topic t ON t.id = qwd.topic_id
        LEFT JOIN subtopic s ON s.id = qwd.subtopic_id
        LEFT JOIN level l ON l.id = qwd.level_id
        LEFT JOIN level l2 ON l2.id = qwd.level_searched_id
        LEFT JOIN course c ON c.id = qwd.course_id
        WHERE 1 = 1
        AND (
            NOT COALESCE(p_has_permission_generar_por_cursos_asignados, FALSE)
            OR EXISTS (
                SELECT 1
                FROM employee_course ec
                WHERE ec.course_id = qwd.course_id
                AND ec.teacher_id = p_employee_id
                AND ec.fl_status IS TRUE
            )
        )
        AND (p_course_id IS NULL OR qwd.course_id = p_course_id)
        AND (p_topic_id IS NULL OR qwd.topic_id = p_topic_id)
        AND (p_subtopic_id IS NULL OR qwd.subtopic_id = p_subtopic_id)
        AND (p_show_missing_questions IS NULL OR p_show_missing_questions IS FALSE OR qwd.valid_question IS FALSE)
        AND (p_search IS NULL OR qwd.code ILIKE '%' || p_search || '%')
    )
    SELECT
        qwdw.*,
        CASE WHEN qwdw.course_correlative IS NULL THEN
            UPPER(LEFT(qwdw.type_material, 4))
        ELSE
            UPPER(LEFT(qwdw.type_material, 4)) || '-' || COALESCE(qwdw.course_correlative::text, '')
        END AS correlativo,
        COUNT(*) OVER () AS total
    FROM questions_with_distributions_with_additional_data qwdw
    WHERE 1 = 1
    AND (p_topic_id IS NULL OR qwdw.topic_id = p_topic_id)
    AND (p_subtopic_id IS NULL OR qwdw.subtopic_id = p_subtopic_id)
    AND (p_show_missing_questions IS NULL OR p_show_missing_questions IS FALSE OR qwdw.valid_question IS FALSE)
    AND (p_search IS NULL OR qwdw.code ILIKE '%' || p_search || '%')
    ORDER BY
        qwdw.week,
        qwdw.course_position,
        LEFT(qwdw.type_material, 1),
        qwdw.course_position,
        qwdw.absolute_position ASC,
        qwdw.topic_code,
        qwdw."position",
        qwdw.subtopic_code,
        qwdw.level
    LIMIT p_perpage OFFSET offset_val;
END;
$$;


ALTER FUNCTION materials.fn_get_ballot_questions_per_period(p_perpage integer, p_npage integer, p_search character varying, p_type_material_id integer, p_material_id integer, p_start_week integer, p_end_week integer, p_course_id integer, p_topic_id integer, p_subtopic_id integer, p_show_missing_questions boolean, p_university_id smallint, p_option_id smallint, p_modality_id smallint, p_version smallint, p_year character varying, p_week integer, p_question_status character varying, p_has_permission_generar_por_cursos_asignados boolean, p_employee_id bigint) OWNER TO postgres;

--
