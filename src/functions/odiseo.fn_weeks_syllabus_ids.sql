-- Function: odiseo.fn_weeks_syllabus_ids(jsonb)

--

CREATE FUNCTION odiseo.fn_weeks_syllabus_ids(p_syllabus_topic_ids jsonb) RETURNS TABLE(id bigint, syllabus_topic_id bigint, week smallint, total_questions_amount smallint, created_at timestamp without time zone, subtopics jsonb)
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                        RETURN QUERY
                        WITH get_syllabus_topics AS (
                            SELECT
                                value::BIGINT AS syballus_topic_id
                            FROM jsonb_array_elements(p_syllabus_topic_ids)
                        ), tbl_syllabus_subtopic_type_material AS (
                            SELECT
                                sstm.syllabus_detail_subtopic_id,
                                jsonb_agg(
                                    jsonb_build_object(
                                        'id',                 sstm.id,
                                        'type_material_id',   sstm.type_material_id,
                                        'type_material',      tm.description,
                                        'amount',             sstm.questions_amount
                                    ) ORDER BY
                                        CASE
                                            WHEN tm.description = 'ECO' THEN 1
                                            WHEN tm.description = 'Guía de clases' THEN 2
                                            WHEN tm.description = 'Homework' THEN 3
                                            ELSE 4
                                        END
                                )::TEXT AS questions_amount
                            FROM syllabus_subtopic_type_material sstm
                            JOIN type_material tm ON sstm.type_material_id = tm.id
                            JOIN syllabus_detail_subtopic sds ON sstm.syllabus_detail_subtopic_id = sds.id
                                AND sds.fl_status = true
                            JOIN syllabus_topic_week stw ON sds.syllabus_topic_week_id = stw.id
                                AND stw.fl_status = true
                            WHERE stw.syllabus_topic_id IN (SELECT gst.syballus_topic_id FROM get_syllabus_topics gst)
                                AND sstm.fl_status = true
                            GROUP BY sstm.syllabus_detail_subtopic_id
                        ), tbl_syllabus_detail_subtopic AS (
                            SELECT
                                ds.id,
                                ds.syllabus_topic_week_id,
                                ds.subtopic_id,
                                s.code        AS code_subtopic,
                                CONCAT(s.code, ' - ', s.name) AS name,
                                s.name       AS name_no_prefix,
                                ds.questions_amount AS amount,
                                ds.created_at,
                                st.questions_amount::jsonb
                            FROM syllabus_detail_subtopic ds
                            JOIN syllabus_topic_week stw ON ds.syllabus_topic_week_id = stw.id
                            JOIN subtopic s ON ds.subtopic_id = s.id
                            LEFT JOIN tbl_syllabus_subtopic_type_material st ON st.syllabus_detail_subtopic_id = ds.id
                            WHERE ds.fl_status
                                AND stw.syllabus_topic_id IN (SELECT gst.syballus_topic_id FROM get_syllabus_topics gst)
                            GROUP BY
                                ds.id, ds.syllabus_topic_week_id, ds.subtopic_id,
                                s.code, s.name, ds.questions_amount,
                                st.questions_amount
                        )
                        SELECT
                            tw.id,
                            tw.syllabus_topic_id,
                            tw.week,
                            tw.total_questions_amount,
                            tw.created_at,
                            COALESCE(
                            jsonb_agg(
                                jsonb_build_object(
                                'id',                         ds.subtopic_id,
                                'syllabus_topic_week_id',     ds.syllabus_topic_week_id,
                                'code_subtopic',              ds.code_subtopic,
                                'name',                       ds.name,
                                'name_no_prefix',             ds.name_no_prefix,
                                'amount',                     ds.amount,
                                'created_at',                 ds.created_at,
                                'questions_amount',           ds.questions_amount,
                                'syllabus_detail_subtopic_id',ds.id
                                ) ORDER BY ds.code_subtopic
                            ) FILTER (WHERE ds.id IS NOT NULL),
                            '[]'::jsonb
                            ) AS subtopics
                        FROM syllabus_topic_week tw
                        LEFT JOIN tbl_syllabus_detail_subtopic ds
                        ON tw.id = ds.syllabus_topic_week_id
                        WHERE tw.syllabus_topic_id IN (SELECT gst.syballus_topic_id FROM get_syllabus_topics gst)
                        AND tw.fl_status
                        GROUP BY
                        tw.id, tw.syllabus_topic_id, tw.week,
                        tw.total_questions_amount, tw.created_at
                        ORDER BY tw.week;
                    END;
                    $$;


ALTER FUNCTION odiseo.fn_weeks_syllabus_ids(p_syllabus_topic_ids jsonb) OWNER TO postgres;

--
