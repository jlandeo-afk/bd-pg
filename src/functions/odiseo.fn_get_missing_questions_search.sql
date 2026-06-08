-- Function: odiseo.fn_get_missing_questions_search(bigint, smallint, smallint, smallint)

--

CREATE FUNCTION odiseo.fn_get_missing_questions_search(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint) RETURNS TABLE(id bigint, type_material_id smallint, amount_type_mat smallint, course_position smallint, course_id smallint, code_course character varying, course character varying, topic_id smallint, code_topic character varying, topic character varying, subtopic_id smallint, code_subtopic character varying, subtopic character varying, week smallint, level_id bigint, level_description character varying, level_name character varying, usage_level_id bigint, type_question character varying, "position" smallint, position_initial smallint, question_id bigint, usage_status boolean, absolute_position smallint)
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    RETURN QUERY
                    WITH type_material_ids AS (
                        SELECT
                            CASE
                                WHEN EXISTS ( SELECT 1 FROM type_material tmx WHERE tmx.parent_id = p_type_material_id )
                                THEN ARRAY( SELECT tmy.id FROM type_material tmy WHERE tmy.parent_id = p_type_material_id )
                                ELSE ARRAY[p_type_material_id]
                            END AS ids
                    ), template_type_material AS (
                        SELECT
                            tm.type_material_template_id
                        FROM type_material tm
                        WHERE tm.id = p_type_material_id
                    ), courses_ordering AS (
                        SELECT
                            cor.course_id,
                            cor.position AS course_position
                        FROM template_type_material_courses_order cor
                        WHERE 1 = 1
                            AND cor.university_id IS NULL
                            AND cor.deleted_at IS NULL
                            AND cor.template_type_material_id IN (SELECT tmt.type_material_template_id FROM template_type_material tmt)
                    ), weeks_in_type_material_ids AS (
                        SELECT
                            tmdt.week,
                            ttm.id AS child_type_material_id,
                            ttm.parent_id AS parent_type_material_id
                        FROM type_material_detail_template tmdt
                        LEFT JOIN (
                            SELECT tm.id, tm.parent_id FROM type_material tm
                            WHERE tm.id IN ( SELECT UNNEST(ids) FROM type_material_ids )
                        ) ttm ON 1 = 1
                        WHERE 1 = 1
                        AND tmdt.type_material_id = p_type_material_id
                        AND tmdt.week BETWEEN p_start_week AND p_end_week
                        AND tmdt.fl_status = true
                        ORDER BY tmdt.week ASC, ttm.id ASC
                    )
                    SELECT DISTINCT
                        mbq.id,
                        dwtm.type_material_id,
                        1::SMALLINT AS amount_type_mat,
                        ccor.course_position,
                        mbq.course_id,
                        c.code AS code_course,
                        c.name AS course,
                        mbq.topic_id,
                        t.code AS code_topic,
                        t.name AS topic,
                        mbq.subtopic_id,
                        s.code AS code_subtopic,
                        s.name AS subtopic,
                        mbq.week,
                        mbq.level_id,
                        l.description AS level_description,
                        l.name AS level_name,
                        mbq.usage_level_id,
                        mbq.type AS type_question,
                        mbq.position,
                        mbq.position_initial,
                        mbq.question_id,
                        mbq.usage_status,
                        mbq.absolute_position
                    FROM material_ballot_question mbq
                    JOIN detail_week_type_mat dwtm ON mbq.week_type_material_id = dwtm.id
                    JOIN weeks_in_type_material_ids witmi ON dwtm.week = witmi.week
                        AND dwtm.type_material_id = witmi.child_type_material_id
                    JOIN subtopic s ON mbq.subtopic_id = s.id
                    JOIN topic t ON mbq.topic_id = t.id
                    JOIN course c ON mbq.course_id = c.id
                    JOIN level l ON mbq.level_id = l.id
                    LEFT JOIN courses_ordering ccor ON mbq.course_id = ccor.course_id
                    WHERE 1 = 1
                        AND dwtm.fl_status IS TRUE
                        AND mbq.fl_status IS TRUE
                        AND dwtm.material_id = p_material_id
                        AND dwtm.type_material_id IN (SELECT UNNEST(ids) FROM type_material_ids)
                        AND mbq.type_text_id IS NULL
                    ORDER BY
                        ccor.course_position ASC,
                        mbq.course_id ASC,
                        mbq.position ASC,
                        mbq.position_initial ASC;
                END;
                $$;


ALTER FUNCTION odiseo.fn_get_missing_questions_search(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint) OWNER TO postgres;

--
