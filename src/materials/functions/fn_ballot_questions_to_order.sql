-- Function: materials.fn_ballot_questions_to_order(integer, integer, integer, integer)

--

CREATE FUNCTION materials.fn_ballot_questions_to_order(p_material_id integer, p_type_material_id integer, p_start_week integer, p_end_week integer) RETURNS TABLE(id bigint, material_ballot_question_id bigint, course_id bigint, topic_id bigint, code_topic character varying, subtopic_id bigint, code_subtopic character varying, level_id bigint, level character varying, question_id bigint, parent_question_id bigint, category_id bigint, subcategory_id bigint, subquestion jsonb, "position" smallint, position_initial smallint, absolute_position smallint, "order" smallint, course_position smallint, type_material_id smallint, week smallint)
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    RETURN QUERY
                    WITH prepare_type_material_ids AS (
                        SELECT
                        CASE WHEN EXISTS (
                            SELECT 1 FROM type_material tm
                            WHERE tm.parent_id = p_type_material_id) THEN
                            ARRAY (
                                SELECT tm.id FROM type_material tm WHERE tm.parent_id = p_type_material_id
                            )
                        ELSE
                            ARRAY[p_type_material_id]
                        END AS ids
                    ), type_material_ids AS (
                        SELECT UNNEST(ids) AS id FROM prepare_type_material_ids
                    ), template_type_material AS (
                        SELECT
                            tmt.id
                        FROM type_material tm
                        JOIN type_material_template tmt ON tmt.id = tm.type_material_template_id
                        WHERE 1 = 1
                            AND tm.type_material_template_id IS NOT NULL
                            AND tm.id = p_type_material_id
                    ), courses_ordering AS (
                        SELECT
                            ttmco.course_id,
                            ttmco.position AS course_position,
                            ttmco.university_id
                        FROM template_type_material_courses_order ttmco
                        WHERE 1 = 1
                            AND ttmco.deleted_by IS NULL
                            AND ttmco.template_type_material_id IN (SELECT ttm.id FROM template_type_material ttm)
                    ), type_material_valid_weeks AS (
                        SELECT tdt.week
                        FROM type_material_detail_template tdt
                        WHERE 1 = 1
                            AND tdt.type_material_id = p_type_material_id
                            AND tdt.fl_status IS TRUE
                    ), detail_week_type_mat_ids AS (
                        SELECT
                            dtm.id,
                            dtm.type_material_id,
                            dtm.week,
                            dtm.material_id
                        FROM detail_week_type_mat dtm
                        WHERE dtm.material_id = p_material_id
                            AND dtm.type_material_id IN (SELECT tmi.id FROM type_material_ids tmi)
                            AND dtm.week BETWEEN p_start_week AND p_end_week
                            AND dtm.week IN (SELECT tmvw.week FROM type_material_valid_weeks tmvw)
                            AND dtm.fl_status IS TRUE
                    )
                    SELECT
                        mdbq.id,
                        CASE 
                            WHEN mdbq.question_id IS NOT NULL OR mdbq.parent_question_id IS NOT NULL THEN mdbq.id 
                            ELSE NULL 
                        END AS material_ballot_question_id,
                        mdbq.course_id::BIGINT AS course_id,
                        mdbq.topic_id::BIGINT AS topic_id,
                        t.code AS code_topic,
                        mdbq.subtopic_id::BIGINT AS subtopic_id,
                        s.code AS code_subtopic,
                        mdbq.level_id AS level_id,
                        l.name AS level,
                        COALESCE(mdbq.question_id, mdbq.id * -1) AS question_id,
                        mdbq.parent_question_id::BIGINT,
                        mdbq.type_text_id AS category_id,
                        mdbq.type_text_subcategory_id AS subcategory_id,
                        (
                            SELECT
                                JSONB_AGG(JSONB_BUILD_OBJECT(
                                    'question_id', sub.question_id,
                                    'position', sub.position,
                                    'course_id', q_sub.course_id,
                                    'topic_id', q_sub.topic_id,
                                    'subtopic_id', q_sub.subtopic_id,
                                    'removed_in_completion', FALSE,
                                    'added_in_completion', FALSE,
                                    'updated_at', sub.created_at,
                                    'fl_is_manual', FALSE
                                ) ORDER BY sub.position)
                            FROM
                                material_ballot_subquestions sub
                                JOIN question q_sub ON sub.question_id = q_sub.id
                            WHERE sub.material_ballot_question_id = mdbq.id
                        ) AS subquestion,
                        mdbq.position,
                        mdbq.position_initial,
                        mdbq.absolute_position,
                        mdbq.position AS "order",
                        ccor.course_position,
                        mdbq.type_material_id,
                        dwtmi.week
                    FROM materials.material_ballot_question mdbq
                    JOIN detail_week_type_mat_ids dwtmi ON mdbq.week_type_material_id = dwtmi.id
                    JOIN material m ON dwtmi.material_id = m.id
                    LEFT JOIN courses_ordering ccor ON ccor.course_id = mdbq.course_id
                        AND ccor.university_id IS NULL
                    JOIN level l ON mdbq.level_id = l.id
                    LEFT JOIN topic t ON t.id = mdbq.topic_id
                    LEFT JOIN subtopic s ON s.id = mdbq.subtopic_id
                    WHERE mdbq.fl_status IS TRUE
                    ORDER BY
                        dwtmi.week ASC,
                        mdbq.type_material_id ASC,
                        ccor.course_position ASC,
                        mdbq.absolute_position ASC,
                        mdbq.position ASC;
                END;
                $$;


ALTER FUNCTION materials.fn_ballot_questions_to_order(p_material_id integer, p_type_material_id integer, p_start_week integer, p_end_week integer) OWNER TO postgres;

--
