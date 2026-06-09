-- Function: exams.fn_get_exam_questions(character varying, integer, integer, integer, integer, integer, integer, jsonb, smallint, smallint, smallint, smallint, character varying, boolean)

--

CREATE FUNCTION exams.fn_get_exam_questions(p_search character varying, p_type_material_id integer, p_material_id integer, p_week integer, p_course_id integer, p_topic_id integer, p_subtopic_id integer, p_area_ids jsonb, p_university_id smallint, p_option_id smallint, p_modality_id smallint, p_version smallint, p_year character varying, p_show_missing_ones boolean) RETURNS TABLE(id bigint, material_exam_area_week_id bigint, order_course smallint, course character varying, course_id smallint, topic character varying, topic_id smallint, subtopic character varying, subtopic_id smallint, code character varying, level_to_be_found bigint, level_id bigint, level bigint, columns smallint, question_id bigint, config_alternative_id bigint, type_material_id smallint, type_material character varying, course_code character varying, topic_code character varying, subtopic_code character varying, type character varying, position_question smallint, status character varying, frequent_subtopic boolean, origin_question jsonb, type_question text, exam_area character varying, exam_area_id smallint, fl_is_manual boolean, category character varying, subcategory character varying, subquestion jsonb, correlativo text)
    LANGUAGE plpgsql
    AS $$
                DECLARE v_area_ids SMALLINT[];
                DECLARE v_week_type_material JSONB;
                DECLARE C_MORE_RECENT_VERSION SMALLINT DEFAULT 1;
                BEGIN
                    IF p_area_ids IS NOT NULL THEN
                        v_area_ids := ARRAY(SELECT JSONB_ARRAY_ELEMENTS_TEXT(p_area_ids)::SMALLINT);
                    END IF;

                    SELECT jsonb_agg(meaw.id)
                    INTO v_week_type_material
                    FROM detail_week_type_mat dwtm
                    JOIN material_exam_area_week meaw ON meaw.week_type_material_id = dwtm.id
                    WHERE 1 = 1
                        AND dwtm.material_id = p_material_id
                        AND dwtm.type_material_id = p_type_material_id
                        AND dwtm.week = p_week
                        AND ( p_area_ids IS NULL OR meaw.area_id = ANY(v_area_ids) )
                        AND dwtm.fl_status = true
                        AND meaw.fl_status = true;

                    RETURN QUERY
                    WITH tbl_material AS (
                        SELECT
                            m.id, m.university_id, m.cycle_id
                        FROM material m
                        WHERE m.id = p_material_id
                    ), area_ids AS (
                        SELECT JSONB_ARRAY_ELEMENTS_TEXT(v_week_type_material)::BIGINT AS exam_area_id
                    ), parents_questions_and_subquestions_to_extract AS ( 
                        SELECT
                            mepq.material_exam_area_week_id AS material_exam_area_week_id,
                            mepq.id AS material_exam_parent_question_id,
                            mepq.parent_question_id AS parent_question_id,
                            mepq.expected_level AS expected_level,
                            mepq.current_level AS current_level,
                            mepq.position AS text_position,
                            mepq.course_id AS course_id,
                            JSONB_ARRAY_ELEMENTS(mepq.subquestion) AS subquestion
                        FROM material_exam_parent_question mepq
                        WHERE 1 = 1
                        AND mepq.deleted_at IS NULL
                        AND mepq.material_exam_area_week_id IN ( SELECT xs.exam_area_id FROM area_ids xs )
                        AND ( p_show_missing_ones IS NULL OR p_show_missing_ones IS FALSE OR ( p_show_missing_ones IS TRUE AND mepq.parent_question_id IS NULL ) )
                    ), subquestions_extracted AS (
                        SELECT 
                            pet.material_exam_area_week_id,
                            pet.material_exam_parent_question_id,
                            pet.parent_question_id,
                            pet.expected_level,
                            pet.current_level,
                            pet.text_position, -- <-- Version 1.1
                            pet.course_id,
                            (pet.subquestion->>'question_id')::INTEGER AS question_id,
                            (pet.subquestion->>'topic_id')::INTEGER AS topic_id,
                            (pet.subquestion->>'subtopic_id')::INTEGER AS subtopic_id
                        FROM parents_questions_and_subquestions_to_extract pet
                    ), subquestions_and_parents AS (
                        SELECT
                            se.material_exam_area_week_id AS material_exam_area_week_id,
                            se.material_exam_parent_question_id AS material_exam_parent_question_id,
                            se.parent_question_id,
                            se.expected_level,
                            se.current_level,
                            se.text_position,
                            c.name AS course,
                            se.course_id,
                            c.code AS course_code,
                            pqn.code AS code,
                            tt.name AS category,
                            tts.name AS subcategory,
                            q.code AS question_code,
                            q.id AS question_id,
                            t.name AS topic,
                            t.code AS topic_code,
                            st.name AS subtopic,
                            st.code AS subtopic_code,
                            q.columns AS column_question,
                            q.config_alternative_id AS config_alternative_id,
                            pl.name AS parent_question_level
                        FROM subquestions_extracted se
                        LEFT JOIN parent_question pqn ON pqn.id = se.parent_question_id
                        LEFT JOIN level pl ON pl.id = pqn.level_id
                        LEFT JOIN question q ON q.id = se.question_id
                        LEFT JOIN type_text tt ON tt.id = pqn.type_text_id
                        LEFT JOIN type_text_subcategories tts ON tts.id = pqn.type_text_subcategory_id
                        LEFT JOIN course c ON c.id = se.course_id
                        LEFT JOIN topic t ON t.id = se.topic_id
                        LEFT JOIN subtopic st ON st.id = se.subtopic_id
                        WHERE 1 = 1
                        AND (p_course_id IS NULL OR se.course_id = p_course_id)
                        AND (p_topic_id IS NULL OR se.topic_id = p_topic_id)
                        AND (p_subtopic_id IS NULL OR se.subtopic_id = p_subtopic_id)
                        AND (p_search IS NULL OR pqn.code ILIKE '%' || p_search || '%')
                    ), group_parent_with_its_subquestions AS (
                        SELECT
                            sap.material_exam_area_week_id,
                            sap.material_exam_parent_question_id,
                            sap.parent_question_id,
                            sap.expected_level,
                            sap.current_level,
                            sap.text_position,
                            sap.code,
                            sap.category,
                            sap.subcategory,
                            sap.course,
                            sap.course_code,
                            sap.course_id,
                            sap.parent_question_level AS level,
                            JSONB_AGG(
                                JSONB_BUILD_OBJECT(
                                    'question_id', sap.question_id,
                                    'code', sap.question_code,
                                    'course', sap.course,
                                    'course_code', sap.course_code,
                                    'topic', sap.topic,
                                    'topic_code', sap.topic_code,
                                    'subtopic', sap.subtopic,
                                    'subtopic_code', sap.subtopic_code,
                                    'columns', sap.column_question,
                                    'config_alternative_id', sap.config_alternative_id
                                )
                            ) AS subquestions
                        FROM subquestions_and_parents sap
                        GROUP BY
                            sap.material_exam_parent_question_id,
                            sap.parent_question_id,
                            sap.expected_level,
                            sap.current_level,
                            sap.code,
                            sap.category,
                            sap.subcategory,
                            sap.course,
                            sap.course_code,
                            sap.course_id,
                            sap.parent_question_level,
                            sap.material_exam_area_week_id,
                            sap.text_position
                    ), add_ordering_by_course_in_text AS (
                        SELECT
                            gpw.*,
                            tml.id AS type_material_id,
                            tml.description AS type_material,
                            tor.position AS order_course,
                            mkk.area_id exam_area_id,
                            ea.description AS exam_area
                        FROM group_parent_with_its_subquestions gpw
                        JOIN material_exam_area_week mkk ON gpw.material_exam_area_week_id = mkk.id
                        JOIN detail_week_type_mat mtt ON mtt.id = mkk.week_type_material_id
                        JOIN material m ON m.id = mtt.material_id
                        JOIN type_material tml ON tml.id = COALESCE(mtt.parent_type_material_id, mtt.type_material_id)
                        JOIN template_type_material_courses_order tor ON tor.template_type_material_id = tml.type_material_template_id AND gpw.course_id = tor.course_id
                        JOIN exam_area ea ON ea.id = mkk.area_id
                        WHERE(
                            (m.university_id = 16 AND tor.university_id = m.university_id)
                            OR (m.university_id != 16 AND tor.university_id IS NULL)
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
                        JOIN question ssq ON ssq.id = oq.question_id AND oq.fl_status IS TRUE
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
                    ), tbl_questions AS (
                        SELECT
                            meq.id AS id,
                            course_ordering.position AS order_course,
                            c.name AS course,
                            meq.course_id,
                            t.name AS topic,
                            meq.topic_id,
                            s.name AS subtopic,
                            meq.subtopic_id,
                            COALESCE(qsh.code, q.code) as code,
                            meq.level_id,
                            l.name AS level,
                            q.columns AS column_question,
                            meq.question_id AS question_id,
                            q.config_alternative_id,
                            dwt.type_material_id,
                            tm.description AS type_material,
                            c.code AS course_code,
                            t.code AS topic_code,
                            s.code AS subtopic_code,
                            meq.position AS position,
                            q.status,
                            COALESCE(fus.is_frequent, false) AS frequent_subtopic,
                            qn.question_origin,
                            'P' AS type_question,
                            ea.description AS exam_area,
                            ea.id AS area_exam_id,
                            meq.fl_is_manual AS fl_is_manual
                        FROM detail_week_type_mat dwt
                        INNER JOIN material m ON dwt.material_id = m.id
                        INNER JOIN material_exam_area_week meaw ON dwt.id = meaw.week_type_material_id AND meaw.id IN (SELECT xd.exam_area_id FROM area_ids xd)
                        INNER JOIN material_exam_question meq ON meaw.id = meq.material_exam_area_week_id AND meq.fl_status = true
                        LEFT JOIN question_shares qsh ON qsh.question_id = meq.question_id AND qsh.deleted_at IS NULL
                        LEFT JOIN question q ON meq.question_id = q.id
                        LEFT JOIN more_recent_questions_origin qn ON qn.question_id = q.id
                        LEFT JOIN course c ON meq.course_id = c.id
                        LEFT JOIN topic t ON meq.topic_id = t.id
                        LEFT JOIN subtopic s ON meq.subtopic_id = s.id
                        INNER JOIN level l ON meq.level_id = l.id
                        INNER JOIN type_material tm ON dwt.type_material_id = tm.id
                        LEFT JOIN configuration_alternative ca ON q.config_alternative_id = ca.id
                        INNER JOIN area a ON c.area_id = a.id
                        LEFT JOIN material_column_configurations mcc ON meq.topic_id = mcc.topic_id
                        LEFT JOIN type_material tm_ordering ON tm_ordering.id = COALESCE(dwt.parent_type_material_id, dwt.type_material_id)
                        LEFT JOIN template_type_material_courses_order course_ordering
                        ON course_ordering.template_type_material_id = tm_ordering.type_material_template_id
                        AND course_ordering.course_id = meq.course_id
                        AND (
                            (m.university_id = 16 AND course_ordering.university_id = 16)
                            OR
                            (COALESCE(m.university_id, 0) != 16 AND course_ordering.university_id IS NULL)
                        )
                        LEFT JOIN alternative al ON q.id = al.question_id
                        LEFT JOIN exam_area ea ON ea.id = meaw.area_id AND ea.fl_status = true
                        LEFT JOIN frequent_university_subtopic fus
                            ON 1 = 1
                            AND fus.university_id IN (SELECT tm.university_id FROM tbl_material tm)
                            AND fus.subtopic_id = q.subtopic_id
                            AND fus.fl_status IS TRUE
                        WHERE 1 = 1
                        AND ( p_course_id IS NULL OR meq.course_id = p_course_id )
                        AND ( p_topic_id IS NULL OR meq.topic_id = p_topic_id )
                        AND ( p_subtopic_id IS NULL OR meq.subtopic_id = p_subtopic_id )
                        AND ( p_search IS NULL OR q.code ILIKE '%' || p_search || '%' )
                        AND ( p_area_ids IS NULL OR ea.id = ANY(v_area_ids) )
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
                        GROUP BY
                            meq.id,
                            dwt.type_material_id,
                            dwt.parent_type_material_id,
                            course_ordering.position,
                            tm.description,
                            c.area_id,
                            a.description,
                            meq.course_id,
                            c.name,
                            c.code,
                            meq.topic_id,
                            t.name,
                            meq.subtopic_id,
                            s.name,
                            meq.level_id,
                            meq.question_id,
                            COALESCE(qsh.code, q.code),
                            q.description,
                            q.answer_id,
                            q.parent_id,
                            q.config_alternative_id,
                            ca.columns,
                            ca.styles,
                            mcc.column_count,
                            mcc.column_width,
                            mcc.column_spacing,
                            mcc.layout_format,
                            mcc.number_format,
                            ca.fl_image,
                            t.code,
                            s.code,
                            l.name,
                            q.columns,
                            ea.id,
                            meq.position,
                            q.status,
                            fus.is_frequent,
                            qn.question_origin
                    ), all_questions_and_texts AS ( -- <-- Version 1.1
                    SELECT
                        gwi.material_exam_parent_question_id AS id,
                        gwi.material_exam_area_week_id AS material_exam_area_week_id,
                        gwi.order_course,
                        gwi.course,
                        gwi.course_id,
                        NULL AS topic,
                        NULL AS topic_id,
                        NULL AS subtopic,
                        NULL AS subtopic_id,
                        gwi.code,
                        gwi.expected_level AS level_to_be_found,
                        NULL AS level_id,
                        gwi.current_level AS level,
                        NULL AS column_question,
                        gwi.parent_question_id AS question_id,
                        NULL AS config_alternative_id,
                        gwi.type_material_id,
                        gwi.type_material AS type_material,
                        gwi.course_code AS course_code,
                        NULL AS topic_code,
                        NULL AS subtopic_code,
                        NULL AS type,
                        gwi.text_position AS position,
                        NULL AS status,
                        NULL AS frequent_subtopic,
                        NULL AS question_origin,
                        'T' AS type_question,
                        gwi.exam_area AS exam_area,
                        gwi.exam_area_id AS exam_area_id,
                        NULL AS fl_is_manual,
                        gwi.category AS category,
                        gwi.subcategory AS subcategory,
                        gwi.subquestions AS subquestions
                    FROM add_ordering_by_course_in_text gwi

                    UNION ALL

                    SELECT
                        qwt.id AS id,
                        NULL AS material_exam_area_week_id,
                        qwt.order_course,
                        qwt.course,
                        qwt.course_id,
                        qwt.topic,
                        qwt.topic_id,
                        qwt.subtopic,
                        qwt.subtopic_id,
                        qwt.code,
                        NULL::BIGINT AS level_to_be_found,
                        qwt.level_id,
                        qwt.level::BIGINT,
                        qwt.column_question,
                        qwt.question_id,
                        qwt.config_alternative_id,
                        qwt.type_material_id,
                        qwt.type_material,
                        qwt.course_code AS course_code,
                        qwt.topic_code AS topic_code,
                        qwt.subtopic_code AS subtopic_code,
                        NULL::CHARACTER VARYING AS type,
                        qwt.position::SMALLINT AS position,
                        qwt.status,
                        qwt.frequent_subtopic,
                        qwt.question_origin,
                        qwt.type_question,
                        qwt.exam_area,
                        qwt.area_exam_id,
                        qwt.fl_is_manual AS fl_is_manual,
                        NULL AS category,
                        NULL AS subcategory,
                        NULL::JSONB AS subquestions
                    FROM tbl_questions qwt
                    WHERE ( p_show_missing_ones IS NULL OR p_show_missing_ones IS FALSE OR ( p_show_missing_ones IS TRUE AND qwt.question_id IS NULL ) )
                    ),
                    with_row_counts AS (
                        SELECT 
                            qt.*,
                            CASE 
                                WHEN qt.type_question = 'P' THEN 1
                                WHEN qt.type_question = 'T' THEN jsonb_array_length(COALESCE(qt.subquestions, '[]'::jsonb))
                                ELSE 0
                            END as row_slots
                        FROM all_questions_and_texts qt
                    ),
                    with_running_totals AS (
                        SELECT 
                            wrc.*,
                            COALESCE(SUM(row_slots) OVER (
                                PARTITION BY wrc.exam_area_id 
                                ORDER BY 
                                    wrc.order_course,
                                    wrc.type_question DESC,
                                    wrc.fl_is_manual,
                                    wrc.topic_code,
                                    wrc.subtopic_code,
                                    wrc.level,
                                    CASE WHEN wrc.question_id IS NOT NULL THEN 0 ELSE 1 END,
                                    wrc.question_id
                                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                            ), 0) - row_slots AS start_counter
                        FROM with_row_counts wrc
                    )
                    SELECT
                        wrt.id,
                        wrt.material_exam_area_week_id,
                        wrt.order_course,
                        wrt.course,
                        wrt.course_id,
                        wrt.topic,
                        wrt.topic_id,
                        wrt.subtopic,
                        wrt.subtopic_id,
                        wrt.code,
                        wrt.level_to_be_found,
                        wrt.level_id,
                        wrt.level,
                        wrt.column_question,
                        wrt.question_id,
                        wrt.config_alternative_id,
                        wrt.type_material_id,
                        wrt.type_material,
                        wrt.course_code,
                        wrt.topic_code,
                        wrt.subtopic_code,
                        wrt.type,
                        wrt.position,
                        wrt.status,
                        wrt.frequent_subtopic,
                        wrt.question_origin,
                        wrt.type_question,
                        wrt.exam_area,
                        wrt.exam_area_id,
                        wrt.fl_is_manual,
                        wrt.category,
                        wrt.subcategory,
                        CASE
                            WHEN wrt.type_question = 'T' AND wrt.subquestions IS NOT NULL THEN (
                                SELECT jsonb_agg(
                                    sub.elem || jsonb_build_object(
                                        'correlativo',
                                        CASE
                                            WHEN (sub.elem->>'question_id') IS NOT NULL AND (sub.elem->>'question_id')::int > 0 
                                            THEN LEFT(UPPER(wrt.type_material), 4) || '-' || (wrt.start_counter + sub.ordinality)::text
                                            ELSE ''
                                        END
                                    )
                                )
                                FROM jsonb_array_elements(wrt.subquestions) WITH ORDINALITY AS sub(elem, ordinality)
                            )
                            ELSE wrt.subquestions
                        END as subquestions,
                        CASE
                            WHEN wrt.type_question = 'P' THEN
                                CASE
                                    WHEN wrt.question_id IS NOT NULL AND wrt.question_id > 0
                                    THEN LEFT(UPPER(wrt.type_material), 4) || '-' || (wrt.start_counter + 1)::text
                                    ELSE ''
                                END
                            ELSE ''
                        END AS correlativo
                    FROM with_running_totals wrt
                    ORDER BY
                        wrt.order_course,
                        wrt.type_question DESC,
                        wrt.fl_is_manual,
                        wrt.topic_code,
                        wrt.subtopic_code,
                        wrt.level,
                        CASE WHEN wrt.question_id IS NOT NULL THEN 0 ELSE 1 END,
                        wrt.question_id;
                END;
                $$;


ALTER FUNCTION exams.fn_get_exam_questions(p_search character varying, p_type_material_id integer, p_material_id integer, p_week integer, p_course_id integer, p_topic_id integer, p_subtopic_id integer, p_area_ids jsonb, p_university_id smallint, p_option_id smallint, p_modality_id smallint, p_version smallint, p_year character varying, p_show_missing_ones boolean) OWNER TO postgres;

--
