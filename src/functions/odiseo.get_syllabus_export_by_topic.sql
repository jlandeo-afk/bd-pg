-- Function: odiseo.get_syllabus_export_by_topic(bigint, bigint)

--

CREATE FUNCTION odiseo.get_syllabus_export_by_topic(p_syllabus_id bigint, p_company_id bigint) RETURNS TABLE(syllabus_id bigint, course_name character varying, cycle_description character varying, week integer, topic_id smallint, week_name character varying, alternative_week_name text, topic_name character varying, subtopics jsonb)
    LANGUAGE plpgsql
    AS $$
     DECLARE v_weeks_amount INTEGER DEFAULT 0;
 BEGIN
     SELECT c.weeks INTO v_weeks_amount
     FROM odiseo.syllabus syll
     JOIN odiseo.cycle c ON c.id = syll.cycle_id
     WHERE syll.id = p_syllabus_id
     AND syll.company_id = p_company_id;
     
     RETURN QUERY
         WITH syllabus_weeks AS (
             SELECT
                 *
             FROM generate_series(1, v_weeks_amount) AS week
         ), syllabus_general_content AS (
             SELECT
                 syll.id,
                 stw.week,
                 syll.course_id AS course_id,
                 st.topic_id AS topic_id,
                 sds.subtopic_id AS subtopic_id,
                 syll.cycle_id AS cycle_id,
                 stw.week AS syllabus_week,
                 sds.id AS syllabus_detail_subtopic_id,
                 sds.questions_amount
             FROM odiseo.syllabus syll
             INNER JOIN odiseo.syllabus_topic st ON st.syllabus_id = syll.id AND st.fl_status IS TRUE AND st.is_topic_deleted IS FALSE
             INNER JOIN odiseo.syllabus_topic_week stw ON stw.syllabus_topic_id = st.id AND stw.fl_status IS TRUE
             INNER JOIN odiseo.syllabus_detail_subtopic sds ON sds.syllabus_topic_week_id = stw.id AND sds.fl_status IS TRUE AND sds.is_subtopic_deleted IS FALSE
             WHERE syll.id = p_syllabus_id
             AND syll.company_id = p_company_id
         ), question_amount_per_material_type AS (
             SELECT
                 sst.syllabus_detail_subtopic_id,
                 JSONB_AGG(
                     JSONB_BUILD_OBJECT(
                         'id', sst.id,
                         'type_material_id', sst.type_material_id,
                         'type_material', tm.description,
                         'amount', sst.questions_amount
                     )
                     ORDER BY 
                         CASE
                             WHEN tm.description = 'ECO' THEN 1
                             WHEN tm.description = 'Guía de clases' THEN 2
                             WHEN tm.description = 'Homework' THEN 3
                             ELSE 4
                         END
                 ) AS questions_amount
             FROM syllabus_general_content sgc
             LEFT JOIN odiseo.syllabus_subtopic_type_material sst ON sst.syllabus_detail_subtopic_id = sgc.syllabus_detail_subtopic_id
             JOIN odiseo.type_material tm ON tm.id = sst.type_material_id 
              AND tm.fl_status IS TRUE 
              AND sst.fl_status IS TRUE
             GROUP BY sst.syllabus_detail_subtopic_id
         ), syllabus_with_topics AS (
             SELECT
                 slc.id,
                 slc.course_id,
                 slc.topic_id,
                 slc.cycle_id,
                 slc.week,
                 JSONB_AGG(
                     JSONB_BUILD_OBJECT(
                         'id', st.id,
                         'code', st.code,
                         'name', st.name,
                         'name_no_prefix', st.name,
                         'amount', slc.questions_amount,
                         'questions_amount', COALESCE(sqpm.questions_amount, '[]'::JSONB)
                     )
                     ORDER BY st.name
                 ) subtopics_amount
             FROM syllabus_general_content slc
             JOIN odiseo.subtopic st ON slc.subtopic_id = st.id
             LEFT JOIN question_amount_per_material_type sqpm ON sqpm.syllabus_detail_subtopic_id = slc.syllabus_detail_subtopic_id
             GROUP BY
                 slc.id,
                 slc.course_id,
                 slc.topic_id,
                 slc.cycle_id,
                 slc.week
         ), syllabus AS (
             SELECT
                 swt.id,
                 c.name AS course_name,
                 cy.description AS cycle_name,
                 swt.week AS week_id,
                 swt.topic_id,
                 stt.title AS week_name,
                 t.name AS topic_name,
                 swt.subtopics_amount
             FROM syllabus_with_topics swt
             JOIN odiseo.course c ON c.id = swt.course_id
             JOIN odiseo.topic t ON t.id = swt.topic_id
             JOIN odiseo.cycle cy ON cy.id = swt.cycle_id
             LEFT JOIN odiseo.syllabus_week_titles stt ON stt.syllabus_id = swt.id AND swt.week = stt.week AND stt.fl_status IS TRUE
         ), syllabus_with_filled_empty_weeks AS (
             SELECT
                 sss.id,
                 (SELECT DISTINCT s1.course_name FROM syllabus s1 LIMIT 1) AS course_name,
                 (SELECT DISTINCT s2.cycle_name FROM syllabus s2 LIMIT 1) AS cycle_name,
                 COALESCE(sss.week_id, sw.week) AS week_id,
                 sss.topic_id,
                 COALESCE(sss.week_name,'') AS week_name,
                 COALESCE(STRING_AGG(sss.topic_name, ', ') OVER (PARTITION BY week_id), '') AS alternative_week_name,
                 COALESCE(sss.topic_name, '') AS topic_name,
                 COALESCE(sss.subtopics_amount, '[]'::JSONB) AS subtopics_amount
             FROM syllabus_weeks sw
             LEFT JOIN syllabus sss ON sss.week_id = sw.week
         ) SELECT
             *
         FROM syllabus_with_filled_empty_weeks
         ORDER BY week_id ASC;
     END;
 $$;


ALTER FUNCTION odiseo.get_syllabus_export_by_topic(p_syllabus_id bigint, p_company_id bigint) OWNER TO postgres;

--
