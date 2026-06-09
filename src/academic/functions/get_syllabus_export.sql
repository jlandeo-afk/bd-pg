-- Function: academic.get_syllabus_export(bigint, bigint, bigint)

--

CREATE FUNCTION academic.get_syllabus_export(p_cycle_id bigint, p_company_id bigint, p_course_id bigint DEFAULT NULL::bigint) RETURNS TABLE(syllabus_id bigint, course_name character varying, cycle_description character varying, week smallint, topics jsonb, subtopic_names text, subtopics jsonb)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        SELECT 
            syll.id AS syllabus_id,
            cour.name AS course_name,
            cycl.description AS cycle_description,
            stw.week AS week,
            jsonb_agg(DISTINCT jsonb_build_object('id', tp.id, 'name', tp.name)) AS topics,
            STRING_AGG(DISTINCT subt.name, ', ') AS subtopic_names,
            JSONB_AGG(
                JSONB_BUILD_OBJECT(
                    'id', subt.id,
                    'code', subt.code,
                    'name', subt.name,
                    'name_no_prefix', subt.name,
                    'amount', sds.questions_amount,
                    'questions_amount', COALESCE(sttm.questions_amount, '[]'::jsonb)
                ) ORDER BY subt.name
            ) AS subtopics
        FROM
            syllabus syll
        INNER JOIN course cour ON cour.id = syll.course_id
        INNER JOIN origin_university univ ON univ.id = syll.university_id
        INNER JOIN cycle cycl ON cycl.id = syll.cycle_id
        INNER JOIN syllabus_topic st ON st.syllabus_id = syll.id AND st.fl_status = true AND st.is_topic_deleted = false
        INNER JOIN syllabus_topic_week stw ON stw.syllabus_topic_id = st.id AND stw.fl_status = true
        INNER JOIN topic tp ON tp.id = st.topic_id
        INNER JOIN syllabus_detail_subtopic sds ON sds.syllabus_topic_week_id = stw.id AND sds.fl_status = true AND sds.is_subtopic_deleted = false
        INNER JOIN subtopic subt ON subt.id = sds.subtopic_id
        LEFT JOIN (
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
            FROM syllabus_subtopic_type_material sst
            JOIN type_material tm 
              ON tm.id = sst.type_material_id 
             AND sst.company_id = p_company_id
             AND tm.fl_status IS TRUE 
             AND sst.fl_status IS TRUE
            GROUP BY sst.syllabus_detail_subtopic_id
        ) sttm ON sttm.syllabus_detail_subtopic_id = sds.id
        WHERE cycl.id = p_cycle_id
          AND syll.company_id = p_company_id
          AND syll.fl_status = true
          AND (p_course_id IS NULL OR cour.id = p_course_id)
        GROUP BY syll.id, cycl.id, cour.id, stw.week
        ORDER BY cour.id;
    END;
    $$;


ALTER FUNCTION academic.get_syllabus_export(p_cycle_id bigint, p_company_id bigint, p_course_id bigint) OWNER TO postgres;

--
