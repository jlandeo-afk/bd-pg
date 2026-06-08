-- Function: odiseo.fn_get_topics_and_subtopics_probabilities_for_exam(bigint, smallint, smallint, bigint)

--

CREATE FUNCTION odiseo.fn_get_topics_and_subtopics_probabilities_for_exam(p_material_id bigint, p_course_id smallint, p_week smallint, p_type_material_id bigint) RETURNS TABLE(topic_id smallint, topic_probability numeric, subtopics_probabilities jsonb)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            WITH cycle_and_university AS (
                SELECT
                    m.cycle_id AS cu_cycle_id,
                    m.university_id AS cu_university_id
                FROM material m
                WHERE m.id = p_material_id
            ),
            find_exam_type AS (
                SELECT
                    txs.name AS exam_type_name
                FROM type_material tm
                JOIN type_material_template tmt
                    ON tmt.id = tm.type_material_template_id
                AND tm.id = p_type_material_id
                JOIN type_exams txs
                    ON txs.id = tmt.type_exam_id
            ),
            syllabus_last_week AS (
                SELECT
                    MAX(stw.week) AS last_week
                FROM syllabus s
                JOIN syllabus_text_weeks stw
                    ON stw.syllabus_id = s.id
                AND stw.fl_status IS TRUE
                WHERE s.university_id IN (SELECT cu_university_id FROM cycle_and_university)
                AND s.cycle_id IN (SELECT cu_cycle_id FROM cycle_and_university)
                AND (p_course_id IS NULL OR s.course_id = p_course_id)
            ),
             base_topics_subtopics AS (
                SELECT DISTINCT
                    tp.id  AS topic_id,
                    stp.id AS subtopic_id,
                    ttp.probability_percentage AS topic_percentage,
                    tts.probability_percentage AS subtopic_percentage
                FROM syllabus s
                JOIN syllabus_text_weeks stw
                    ON stw.syllabus_id = s.id
                AND stw.fl_status IS TRUE
                JOIN syllabus_text_distributions std
                    ON std.syllabus_text_week_id = stw.id
                AND std.fl_status IS TRUE
                JOIN type_material tm
                    ON tm.id = std.type_material_id
                JOIN type_material_template tmt
                    ON tmt.id = tm.type_material_template_id
                AND tmt.fl_use_syllabus_exam IS TRUE
                JOIN syllabus_texts st
                    ON st.syllabus_text_distribution_id = std.id
                AND st.fl_status IS TRUE
                JOIN syllabus_text_content stc
                    ON stc.syllabus_text_id = st.id
                JOIN subtopic stp
                    ON stp.id = stc.subtopic_id
                JOIN topic tp
                    ON tp.id = stp.topic_id
                JOIN type_text tt
                    ON tt.id = st.type_text_id
                JOIN type_texts_topics ttp
                    ON ttp.topic_id = tp.id
                AND ttp.type_text_id = tt.id
                JOIN type_texts_subtopics tts
                    ON tts.subtopic_id = stp.id
                AND tts.type_text_id = tt.id
                WHERE
                    s.university_id IN (SELECT cu_university_id FROM cycle_and_university)
                    AND s.cycle_id IN (SELECT cu_cycle_id FROM cycle_and_university)
                    AND (p_course_id IS NULL OR s.course_id = p_course_id)
                    AND (
                        (EXISTS (SELECT 1 FROM find_exam_type WHERE exam_type_name = 'Tipo 2')
                            AND stw.week BETWEEN 1 AND p_week)
                    OR (EXISTS (SELECT 1 FROM find_exam_type WHERE exam_type_name = 'Tipo 3')
                            AND stw.week BETWEEN 1 AND (SELECT last_week FROM syllabus_last_week))
                    OR (NOT EXISTS (SELECT 1 FROM find_exam_type WHERE exam_type_name = 'Tipo 2')
                            AND stw.week = p_week)
                    )
            ),
            topic_totals AS (
                SELECT
                    bts.topic_id AS tt_topic_id,
                    SUM(bts.topic_percentage) AS tt_topic_total
                FROM base_topics_subtopics bts
                GROUP BY bts.topic_id
            ),
            topic_normalized AS (
                SELECT
                    tt.tt_topic_id AS tn_topic_id,
                    ROUND(
                        (tt.tt_topic_total * 100.0)
                        / NULLIF(SUM(tt.tt_topic_total) OVER (), 0),
                        2
                    ) AS tn_topic_probability
                FROM topic_totals tt
            ),

            subtopic_totals AS (
                SELECT
                    bts.topic_id AS st_topic_id,
                    SUM(bts.subtopic_percentage) AS st_total
                FROM base_topics_subtopics bts
                GROUP BY bts.topic_id
            ),
            subtopic_normalized AS (
                SELECT
                    bts.topic_id AS sn_topic_id,
                    bts.subtopic_id AS sn_subtopic_id,
                    ROUND(
                        (bts.subtopic_percentage * 100.0)
                        / NULLIF(st.st_total, 0),
                        2
                    ) AS sn_subtopic_probability
                FROM base_topics_subtopics bts
                JOIN subtopic_totals st
                    ON st.st_topic_id = bts.topic_id
            )
            SELECT
                tn.tn_topic_id AS topic_id,
                tn.tn_topic_probability AS topic_probability,
                JSONB_AGG(
                    JSONB_BUILD_OBJECT(
                        'subtopic_id', sn.sn_subtopic_id,
                        'subtopic_probability', sn.sn_subtopic_probability
                    )
                    ORDER BY sn.sn_subtopic_probability DESC
                ) AS subtopics_probabilities
            FROM topic_normalized tn
            LEFT JOIN subtopic_normalized sn
                ON sn.sn_topic_id = tn.tn_topic_id
            GROUP BY
                tn.tn_topic_id,
                tn.tn_topic_probability
            ORDER BY
                tn.tn_topic_probability DESC;
        END;
        $$;


ALTER FUNCTION odiseo.fn_get_topics_and_subtopics_probabilities_for_exam(p_material_id bigint, p_course_id smallint, p_week smallint, p_type_material_id bigint) OWNER TO postgres;

--
