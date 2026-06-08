-- Function: odiseo.fn_get_ballot_questions(integer, integer, character varying, integer, integer, integer, integer, integer, integer, boolean, smallint, smallint, smallint, smallint, character varying)

--

CREATE FUNCTION odiseo.fn_get_ballot_questions(p_perpage integer, p_npage integer, p_search character varying, p_type_material_id integer, p_material_id integer, p_week integer, p_course_id integer, p_topic_id integer, p_subtopic_id integer, p_show_missing_questions boolean, p_university_id smallint, p_option_id smallint, p_modality_id smallint, p_version smallint, p_year character varying) RETURNS TABLE(question_id bigint, material_distribution_id bigint, type_material_id smallint, type_material character varying, level_searched_id bigint, columns smallint, level_used_id bigint, level_id bigint, course_id bigint, topic_id bigint, subtopic_id bigint, "position" smallint, code character varying, type character varying, config_alternative_id bigint, random boolean, valid_question boolean, course_position smallint, absolute_position smallint, status character varying, fl_is_manual boolean, added_in_completion boolean, removed_in_completion boolean, updated_at timestamp without time zone, subquestion json, type_question text, category_id bigint, category character varying, subcategory_id bigint, subcategory character varying, origin_question jsonb, level_to_be_found smallint, level smallint, course_code character varying, topic_code character varying, subtopic_code character varying, course character varying, topic character varying, subtopic character varying, course_correlative bigint, correlativo text, total bigint)
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_week_type_material JSONB;
                offset_val INTEGER;
                C_MORE_RECENT_VERSION SMALLINT DEFAULT 1;
            BEGIN
                offset_val := p_perpage * (p_npage - 1);

                SELECT JSONB_AGG(dwtm.id) INTO v_week_type_material
                FROM detail_week_type_mat dwtm
                WHERE 1 = 1
                    AND dwtm.material_id = p_material_id
                    AND dwtm.parent_type_material_id = p_type_material_id
                    AND dwtm.week = p_week
                    AND dwtm.fl_status IS TRUE;

                IF v_week_type_material IS NULL THEN
                    SELECT JSONB_AGG(dwtm.id) INTO v_week_type_material
                    FROM detail_week_type_mat dwtm
                    WHERE 1 = 1
                        AND dwtm.material_id = p_material_id
                        AND dwtm.type_material_id = p_type_material_id
                        AND dwtm.week = p_week
                        AND dwtm.fl_status IS TRUE;
                END IF;

                RETURN QUERY
                WITH template_type_material_from_parent AS (
                    SELECT
                        tmt.id AS id,
                        m.university_id
                    FROM detail_week_type_mat dtt
                    JOIN material m ON m.id = dtt.material_id
                    JOIN type_material tm ON tm.id = dtt.parent_type_material_id
                    JOIN type_material_template tmt ON tmt.id = tm.type_material_template_id
                    WHERE 1 = 1
                    AND dtt.parent_type_material_id = p_type_material_id
                    AND dtt.fl_status IS TRUE
                    AND dtt.week = p_week
                    LIMIT 1
                ), template_type_material_if_is_not_parent AS (
                    SELECT
                        tmtt.id AS id
                    FROM type_material tmm
                    JOIN type_material_template tmtt ON tmtt.id = tmm.type_material_template_id
                    WHERE 1 = 1
                    AND tmm.type_material_template_id IS NOT NULL
                    AND tmm.id = p_type_material_id
                ), courses_ordering AS (
                    SELECT
                        cor.course_id,
                        cor.position AS course_position,
                        cor.university_id
                    FROM template_type_material_courses_order cor
                    WHERE 1 = 1
                    AND deleted_at IS NULL
                        AND CASE WHEN
                            ( SELECT COUNT(*) template_type_material_from_parent ) > 0
                            THEN cor.template_type_material_id IN (SELECT id FROM template_type_material_from_parent )
                            ELSE cor.template_type_material_id IN (SELECT id FROM template_type_material_if_is_not_parent )
                        END
                        AND (
                            (
                                (SELECT ttmfp.university_id FROM template_type_material_from_parent ttmfp LIMIT 1) = 16
                                AND cor.university_id = 16 -- UNHEVAL
                            )
                            OR
                            (
                                (SELECT ttmfp.university_id FROM template_type_material_from_parent ttmfp LIMIT 1) <> 16
                                AND cor.university_id IS NULL
                            )
                        )
                ), questions_origin AS (
                    SELECT
                        oq.question_id,
                        oq.year,
                        oq.version,
                        oq.modality_id,
                        oq.option_id,
                        oq.university_id,
                        u.slug AS university_name,
                        o.name AS option_name,
                        m.name AS modality_name,
                        ROW_NUMBER() OVER ( PARTITION BY oq.question_id ORDER BY oq.year DESC, oq."version" DESC, oq.created_at DESC ) AS absolute_version
                    FROM origin_question oq
                    JOIN question ssq ON ssq.status IN ('VERI', 'APRB') AND ssq.id = oq.question_id AND oq.fl_status IS TRUE
                    LEFT JOIN origin_university u ON u.id = oq.university_id
                    LEFT JOIN option o ON o.id = oq.option_id
                    LEFT JOIN modality m ON m.id = oq.modality_id
                ), more_recent_questions_origin AS (
                    SELECT
                        qon.question_id,
                        (
                            JSONB_AGG(
                                JSONB_BUILD_ARRAY(
                                    JSONB_BUILD_OBJECT('name', qon.university_name, 'type', 'university', 'id', qon.university_id ),
                                    JSONB_BUILD_OBJECT('name', qon.option_name, 'type', 'option', 'id', qon.option_id ),
                                    JSONB_BUILD_OBJECT('name', qon.modality_name, 'type', 'modality', 'id', qon.modality_id ),
                                    JSONB_BUILD_OBJECT('name', fn_number_to_roman(qon.version), 'type', 'version', 'id', NULL ),
                                    JSONB_BUILD_OBJECT('name', qon.year, 'type', 'year', 'id', NULL )
                                )
                            )->0
                        ) AS question_origin
                    FROM questions_origin qon
                    WHERE qon.absolute_version = C_MORE_RECENT_VERSION
                    GROUP BY qon.question_id
                ), material_question_distribution AS (
                    SELECT
                        COALESCE(mbq.question_id, mbq.id * -1) AS question_id,
                        mbq.id AS material_distribution_id,
                        mbq.type_material_id,
                        tm.description AS type_material,
                        mbq.level_id AS level_searched_id,
                        q.columns AS columns,
                        mbq.usage_level_id AS level_used_id,
                        COALESCE(mbq.usage_level_id, mbq.level_id) AS level_id,
                        mbq.course_id::BIGINT AS course_id,
                        mbq.topic_id::BIGINT AS topic_id,
                        mbq.subtopic_id::BIGINT AS subtopic_id,
                        mbq.position AS "position",
                        COALESCE(q.code, pq.code) AS code,
                        COALESCE(q.type, mbq.type) AS type,
                        q.config_alternative_id,
                        mbq.random AS random,
                        (mbq.question_id IS NOT NULL OR mbq.parent_question_id IS NOT NULL) AS valid_question,
                        ccor.course_position AS course_position,
                        mbq.absolute_position AS absolute_position,
                        q.status AS status,
                        COALESCE(mbq.fl_is_manual, FALSE) AS fl_is_manual,
                        mbq.added_in_completion AS added_in_completion,
                        mbq.removed_in_completion AS removed_in_completion,
                        COALESCE(mbq.updated_at, mbq.created_at) AS updated_at,
                        (
                            SELECT
                                json_agg(
                                    jsonb_build_object(
                                        'id', mbs.id,
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
                                        'course_id', COALESCE(q_sub.course_id, mbs.course_id),
                                        'topic_id', COALESCE(q_sub.topic_id, mbs.topic_id),
                                        'subtopic_id', COALESCE(q_sub.subtopic_id, mbs.subtopic_id),
                                        'type_question', 'S',
                                        'status', mbs.state
                                    ) ORDER BY mbs.position ASC
                                )
                            FROM material_ballot_subquestions mbs
                            LEFT JOIN question q_sub ON q_sub.id = mbs.question_id
                            LEFT JOIN more_recent_questions_origin qn_sub ON qn_sub.question_id = q_sub.id
                            LEFT JOIN course c_sub ON c_sub.id = q_sub.course_id
                            LEFT JOIN topic t_sub ON t_sub.id = q_sub.topic_id
                            LEFT JOIN subtopic st_sub ON st_sub.id = q_sub.subtopic_id
                            LEFT JOIN course c_expected ON c_expected.id = mbs.course_id
                            LEFT JOIN topic t_expected ON t_expected.id = mbs.topic_id
                            LEFT JOIN subtopic st_expected ON st_expected.id = mbs.subtopic_id
                            WHERE mbs.material_ballot_question_id = mbq.id
                              AND mbs.fl_status IS TRUE
                              AND mbs.deleted_at IS NULL
                        )::json AS subquestion,
                        CASE WHEN mbq.type_text_id IS NULL THEN 'P' ELSE 'T' END AS type_question,
                        mbq.type_text_id AS category_id,
                        tt.name AS category,
                        mbq.type_text_subcategory_id AS subcategory_id,
                        tts.name AS subcategory,
                        qn.question_origin
                    FROM material_ballot_question mbq
                    LEFT JOIN question q ON q.id = mbq.question_id AND q.fl_status IS TRUE
                    LEFT JOIN more_recent_questions_origin qn ON qn.question_id = q.id
                    LEFT JOIN parent_question pq ON pq.id = mbq.parent_question_id AND pq.fl_status IS TRUE
                    INNER JOIN detail_week_type_mat dwt ON dwt.id = mbq.week_type_material_id
                    INNER JOIN type_material tm ON tm.id = dwt.type_material_id
                    LEFT JOIN courses_ordering ccor ON ccor.course_id = mbq.course_id
                    LEFT JOIN type_text tt ON tt.id = mbq.type_text_id
                    LEFT JOIN type_text_subcategories tts ON tts.id = mbq.type_text_subcategory_id
                    WHERE mbq.fl_status IS TRUE
                    AND mbq.deleted_at IS NULL
                    AND mbq.week_type_material_id IN ( SELECT value::int FROM JSONB_ARRAY_ELEMENTS_TEXT(v_week_type_material) )
                    AND mbq.week = p_week
                    AND mbq.material_id = p_material_id
                    AND ( p_university_id IS NULL OR EXISTS (
                        SELECT 1
                        FROM JSONB_ARRAY_ELEMENTS(qn.question_origin) AS origin
                        WHERE 1 = 1
                        AND origin->>'type' = 'university'
                        AND (origin->>'id')::SMALLINT = p_university_id
                    ))
                    AND ( p_option_id IS NULL OR EXISTS (
                        SELECT 1
                        FROM JSONB_ARRAY_ELEMENTS(qn.question_origin) AS origin
                        WHERE 1 = 1
                        AND origin->>'type' = 'option'
                        AND (origin->>'id')::SMALLINT = p_option_id
                    ))
                    AND ( p_modality_id IS NULL OR EXISTS (
                        SELECT 1
                        FROM JSONB_ARRAY_ELEMENTS(qn.question_origin) AS origin
                        WHERE 1 = 1
                        AND origin->>'type' = 'modality'
                        AND (origin->>'id')::SMALLINT = p_modality_id
                    ))
                    AND ( p_version IS NULL OR EXISTS (
                        SELECT 1
                        FROM JSONB_ARRAY_ELEMENTS(qn.question_origin) AS origin
                        WHERE 1 = 1
                        AND origin->>'type' = 'version'
                        AND origin->>'name' = fn_number_to_roman(p_version)
                    ))
                    AND ( p_year IS NULL OR EXISTS (
                        SELECT 1
                        FROM JSONB_ARRAY_ELEMENTS(qn.question_origin) AS origin
                        WHERE 1 = 1
                        AND origin->>'type' = 'year'
                        AND origin->>'name' = p_year
                    ))
                ), material_questions_plus_correlatives AS (
                    SELECT
                        mqd.*,
                        l2.name::SMALLINT AS level_to_be_found,
                        l.name::SMALLINT AS "level",
                        c.code AS course_code,
                        t.code AS topic_code,
                        s.code AS subtopic_code,
                        c.name AS course,
                        t.name AS topic,
                        s.name AS subtopic,
                        CASE
                            WHEN mqd.valid_question THEN
                            SUM(
                                CASE
                                WHEN mqd.valid_question IS TRUE THEN 1
                                ELSE 0
                                END
                            ) OVER (
                            PARTITION BY
                                mqd.type_material_id,
                                mqd.course_position
                            ORDER BY
                                (mqd.question_id IS NULL),
                                mqd.type_material_id,
                                mqd.course_position,
                                mqd.absolute_position,
                                t.code,
                                mqd."position"
                                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                            )
                        ELSE NULL
                        END AS course_correlative
                    FROM material_question_distribution mqd
                    LEFT JOIN level l ON l.id = mqd.level_id
                    LEFT JOIN level l2 ON l2.id = mqd.level_searched_id
                    LEFT JOIN course c ON c.id = mqd.course_id
                    LEFT JOIN topic t ON t.id = mqd.topic_id
                    LEFT JOIN subtopic s ON s.id = mqd.subtopic_id
                    WHERE ( p_course_id IS NULL OR mqd.course_id = p_course_id )
                    ORDER BY
                        mqd.course_position,
                        LEFT(mqd.type_material, 1),
                        mqd.absolute_position ASC,
                        t.code,
                        mqd."position",
                        s.code,
                        l.name
                )
                SELECT
                    mmqp.question_id,
                    mmqp.material_distribution_id,
                    mmqp.type_material_id,
                    mmqp.type_material,
                    mmqp.level_searched_id,
                    mmqp.columns,
                    mmqp.level_used_id,
                    mmqp.level_id,
                    mmqp.course_id,
                    mmqp.topic_id,
                    mmqp.subtopic_id,
                    mmqp.position,
                    mmqp.code,
                    mmqp.type,
                    mmqp.config_alternative_id,
                    mmqp.random,
                    mmqp.valid_question,
                    mmqp.course_position,
                    mmqp.absolute_position,
                    mmqp.status,
                    mmqp.fl_is_manual,
                    mmqp.added_in_completion,
                    mmqp.removed_in_completion,
                    mmqp.updated_at,
                    mmqp.subquestion,
                    mmqp.type_question,
                    mmqp.category_id,
                    mmqp.category,
                    mmqp.subcategory_id,
                    mmqp.subcategory,
                    mmqp.origin_question,
                    mmqp.level_to_be_found,
                    mmqp.level,
                    mmqp.course_code,
                    mmqp.topic_code,
                    mmqp.subtopic_code,
                    mmqp.course,
                    mmqp.topic,
                    mmqp.subtopic,
                    mmqp.course_correlative,
                    CASE
                    WHEN mmqp.course_correlative IS NULL THEN UPPER(LEFT( mmqp.type_material, 4 ))
                    ELSE UPPER(LEFT( mmqp.type_material, 4 )) || '-' || COALESCE( mmqp.course_correlative::TEXT, '' )
                    END AS correlativo,
                    COUNT(*) OVER () AS total
                FROM material_questions_plus_correlatives mmqp
                WHERE 1 = 1
                    AND ( p_topic_id IS NULL OR mmqp.topic_id = p_topic_id )
                    AND ( p_subtopic_id IS NULL OR mmqp.subtopic_id = p_subtopic_id )
                    AND ( p_show_missing_questions IS NULL OR p_show_missing_questions IS FALSE OR mmqp.valid_question IS FALSE)
                    AND (p_search IS NULL OR mmqp.code ILIKE '%' || p_search || '%')
                LIMIT p_perpage OFFSET offset_val;
                END;
            $$;


ALTER FUNCTION odiseo.fn_get_ballot_questions(p_perpage integer, p_npage integer, p_search character varying, p_type_material_id integer, p_material_id integer, p_week integer, p_course_id integer, p_topic_id integer, p_subtopic_id integer, p_show_missing_questions boolean, p_university_id smallint, p_option_id smallint, p_modality_id smallint, p_version smallint, p_year character varying) OWNER TO postgres;

--
