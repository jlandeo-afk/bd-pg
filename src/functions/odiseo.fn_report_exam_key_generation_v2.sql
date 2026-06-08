-- Function: odiseo.fn_report_exam_key_generation_v2(jsonb)

--

CREATE FUNCTION odiseo.fn_report_exam_key_generation_v2(p_ids jsonb) RETURNS TABLE(material_exam_area_week_id bigint, area character varying, area_id smallint, cycle character varying, cycle_type character varying, exam_type character varying, formated_date character varying, integer_date integer, type_material_id smallint, week smallint, keys json, university_id smallint)
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_university_id smallint;
            BEGIN
                SELECT
                    CASE
                        WHEN m.university_id = 16 THEN m.university_id
                        ELSE NULL::SMALLINT
                    END
                INTO v_university_id
                FROM material_exam_area_week meaw
                JOIN detail_week_type_mat dwtm ON dwtm.id = meaw.week_type_material_id
                JOIN material m ON m.id = dwtm.material_id
                WHERE meaw.id = ANY(SELECT (JSONB_ARRAY_ELEMENTS_TEXT(p_ids))::BIGINT)
                LIMIT 1;

                RETURN QUERY
                WITH question_per_material_exam_area_week AS (
                    SELECT
                        meq.material_exam_area_week_id,
                        meq.course_id,
                        meq.question_id,
                        q.code,
                        q.answer_id,
                        meq.position AS relative_position,
                        meq.topic_id,
                        meq.subtopic_id,
                        l.name AS level_name,
                        ea.short_description AS area,
                        ea.id AS area_id,
                        c.code AS cycle,
                        c.description AS cycle_name,
                        ct.name AS cycle_type,
                        COALESCE(
                            UPPER(
                                CASE
                                    WHEN POSITION(' ' IN tm.description) > 0 THEN SUBSTRING(SPLIT_PART(tm.description, ' ', 1) FROM LENGTH(SPLIT_PART(tm.description, ' ', 1)) - 1 FOR 2)
                                    ELSE SUBSTRING(tm.description FROM LENGTH(tm.description) - 1 FOR 2) 
                                END), ''
                        )::VARCHAR AS exam_type,
                        TO_CHAR(meaw.created_at, 'DD/MM/YYYY')::VARCHAR AS formated_date,
                        (EXTRACT(DAY FROM meaw.created_at - '1900-01-01'::TIMESTAMP) + 2)::INTEGER AS integer_date,
                        tm.id AS type_material_id,
                        dwtm.week AS week,
                        RANK() OVER (
                            PARTITION BY meq.material_exam_area_week_id
                                ORDER BY
                                    co.position,
                                    meq.position,
                                    t.code ASC,
                                    st.code ASC,
                                    l.name ASC,
                                    q.id
                        ) AS absolute_position,
                        'P' AS type_question,
                        NULL::JSONB AS subquestions,
                        m.university_id
                    FROM odiseo.material_exam_question AS meq
                    LEFT JOIN odiseo.topic AS t ON meq.topic_id = t.id
                    LEFT JOIN odiseo.subtopic AS st ON st.id = meq.subtopic_id
                    JOIN odiseo.question AS q ON q.id = meq.question_id AND meq.fl_status IS TRUE
                    LEFT JOIN odiseo.material_exam_area_week AS meaw ON meaw.id = meq.material_exam_area_week_id
                    LEFT JOIN odiseo.exam_area AS ea ON ea.id = meaw.area_id
                    LEFT JOIN odiseo.detail_week_type_mat AS dwtm ON dwtm.id = meaw.week_type_material_id
                    LEFT JOIN odiseo.material AS m ON m.id = dwtm.material_id
                    LEFT JOIN odiseo.cycle AS c ON c.id = m.cycle_id
                    LEFT JOIN odiseo.cycle_types ct ON ct.id = c.cycle_type_id
                    LEFT JOIN odiseo.type_material AS tm ON tm.id = dwtm.type_material_id
                    LEFT JOIN odiseo.type_material_template AS tmt ON tmt.id = tm.type_material_template_id
                    LEFT JOIN odiseo.template_type_material_courses_order AS co ON co.template_type_material_id = tmt.id AND meq.course_id = co.course_id
                        AND co.university_id IS NOT DISTINCT FROM v_university_id
                    LEFT JOIN odiseo.level AS l ON l.id = meq.level_id
                    WHERE 1 = 1
                      AND meq.material_exam_area_week_id = ANY(SELECT (JSONB_ARRAY_ELEMENTS_TEXT(p_ids))::BIGINT)
                ), parent_questions_with_subquestions AS (
                    SELECT
                        mepq.material_exam_area_week_id,
                        mepq.course_id,
                        mepq.parent_question_id AS question_id,
                        pq.code,
                        NULL::INTEGER AS answer_id,
                        mepq.position AS relative_position,
                        NULL::INTEGER AS topic_id,
                        NULL::INTEGER AS subtopic_id,
                        NULL::VARCHAR AS level_name,
                        ea.short_description AS area,
                        ea.id AS area_id,
                        c.code AS cycle,
                        c.description AS cycle_name,
                        ct.name AS cycle_type,
                        COALESCE(
                            UPPER(
                                CASE
                                    WHEN POSITION(' ' IN tm.description) > 0 THEN SUBSTRING(SPLIT_PART(tm.description, ' ', 1) FROM LENGTH(SPLIT_PART(tm.description, ' ', 1)) - 1 FOR 2)
                                    ELSE SUBSTRING(tm.description FROM LENGTH(tm.description) - 1 FOR 2) 
                                END), ''
                        )::VARCHAR AS exam_type,
                        TO_CHAR(meaw.created_at, 'DD/MM/YYYY')::VARCHAR AS formated_date,
                        (EXTRACT(DAY FROM meaw.created_at - '1900-01-01'::TIMESTAMP) + 2)::INTEGER AS integer_date,
                        tm.id AS type_material_id,
                        dwtm.week AS week,
                        RANK() OVER (
                            PARTITION BY mepq.material_exam_area_week_id
                                ORDER BY
                                    co.position,
                                    mepq.position,
                                    pq.id
                        ) AS absolute_position,
                        'T' AS type_question,
                        mepq.subquestion AS subquestions,
                        m.university_id
                    FROM odiseo.material_exam_parent_question AS mepq
                    JOIN odiseo.parent_question AS pq ON pq.id = mepq.parent_question_id
                    LEFT JOIN odiseo.material_exam_area_week AS meaw ON meaw.id = mepq.material_exam_area_week_id
                    LEFT JOIN odiseo.exam_area AS ea ON ea.id = meaw.area_id
                    LEFT JOIN odiseo.detail_week_type_mat AS dwtm ON dwtm.id = meaw.week_type_material_id
                    LEFT JOIN odiseo.material AS m ON m.id = dwtm.material_id
                    LEFT JOIN odiseo.cycle AS c ON c.id = m.cycle_id
                    LEFT JOIN odiseo.cycle_types ct ON ct.id = c.cycle_type_id
                    LEFT JOIN odiseo.type_material AS tm ON tm.id = dwtm.type_material_id
                    LEFT JOIN odiseo.type_material_template AS tmt ON tmt.id = tm.type_material_template_id
                    LEFT JOIN odiseo.template_type_material_courses_order AS co ON co.template_type_material_id = tmt.id AND mepq.course_id = co.course_id
                        AND co.university_id IS NOT DISTINCT FROM v_university_id
                    WHERE 1 = 1
                      AND mepq.deleted_at IS NULL
                      AND mepq.material_exam_area_week_id = ANY(SELECT (JSONB_ARRAY_ELEMENTS_TEXT(p_ids))::BIGINT)
                ), all_questions_and_texts AS (
                    SELECT * FROM question_per_material_exam_area_week
                    UNION ALL
                    SELECT * FROM parent_questions_with_subquestions
                ), question_alternatives AS (
                    SELECT
                        qn.question_id,
                        qn.answer_id,
                        al.id AS alternative_id,
                        qn.answer_id = al.id AS correct_answer,
                        CHR(64 + (ROW_NUMBER() OVER ( PARTITION BY qn.material_exam_area_week_id, qn.question_id ORDER BY al.id ))::INT)::CHARACTER AS answer_position,
                        qn.material_exam_area_week_id,
                        qn.type_question
                    FROM all_questions_and_texts qn
                    LEFT JOIN odiseo.alternative AS al ON al.question_id = qn.question_id AND al.fl_status IS TRUE
                    WHERE qn.type_question = 'P'
                    ORDER BY qn.question_id, al.id
                ), subquestion_alternatives AS (
                    SELECT
                        qn.question_id AS parent_question_id,
                        (sq.value->>'question_id')::BIGINT AS question_id,
                        q.answer_id,
                        al.id AS alternative_id,
                        q.answer_id = al.id AS correct_answer,
                        CHR(64 + (ROW_NUMBER() OVER ( PARTITION BY q.id ORDER BY al.id ))::INT)::CHARACTER AS answer_position,
                        qn.material_exam_area_week_id
                    FROM all_questions_and_texts qn
                    CROSS JOIN LATERAL JSONB_ARRAY_ELEMENTS(qn.subquestions) AS sq(value)
                    JOIN odiseo.question AS q ON q.id = (sq.value->>'question_id')::BIGINT
                    LEFT JOIN odiseo.alternative AS al ON al.question_id = q.id AND al.fl_status IS TRUE
                    WHERE qn.type_question = 'T'
                      AND qn.subquestions IS NOT NULL
                    ORDER BY q.id, al.id
                )
                SELECT
                    qw.material_exam_area_week_id,
                    qw.area,
                    qw.area_id,
                    qw.cycle,
                    qw.cycle_type,
                    qw.exam_type,
                    qw.formated_date,
                    qw.integer_date,
                    qw.type_material_id,
                    qw.week,
                    JSON_AGG(
                        JSON_BUILD_OBJECT(
                            'id', qw.question_id,
                            'question_id', qw.question_id,
                            'question_code', qw.code,
                            'course_id', qw.course_id,
                            'description', CASE 
                                WHEN qw.type_question = 'P' THEN qal.answer_position
                                ELSE NULL
                            END,
                            'code', qw.code,
                            'absolute_position', qw.absolute_position,
                            'material_exam_area_week_id', qw.material_exam_area_week_id,
                            'type_question', qw.type_question,
                            'subquestions', CASE 
                                WHEN qw.type_question = 'T' THEN (
                                    SELECT JSON_AGG(
                                        JSON_BUILD_OBJECT(
                                            'question_id', sqa.question_id,
                                            'answer_position', sqa.answer_position
                                        )
                                        ORDER BY sqa.question_id
                                    )
                                    FROM subquestion_alternatives sqa
                                    WHERE sqa.parent_question_id = qw.question_id
                                      AND sqa.material_exam_area_week_id = qw.material_exam_area_week_id
                                      AND sqa.correct_answer IS TRUE
                                )
                                ELSE NULL
                            END
                        )
                        ORDER BY qw.absolute_position
                    ) AS questions,
                    qw.university_id
                FROM all_questions_and_texts AS qw
                LEFT JOIN question_alternatives AS qal ON qw.question_id = qal.question_id 
                    AND qal.material_exam_area_week_id = qw.material_exam_area_week_id 
                    AND qal.correct_answer IS TRUE
                    AND qw.type_question = 'P'
                GROUP BY
                    qw.material_exam_area_week_id,
                    qw.area,
                    qw.area_id,
                    qw.cycle,
                    qw.cycle_type,
                    qw.exam_type,
                    qw.formated_date,
                    qw.integer_date,
                    qw.type_material_id,
                    qw.week,
                    qw.university_id;
            END;
            $$;


ALTER FUNCTION odiseo.fn_report_exam_key_generation_v2(p_ids jsonb) OWNER TO postgres;

--
