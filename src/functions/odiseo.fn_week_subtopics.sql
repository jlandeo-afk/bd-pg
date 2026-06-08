-- Function: odiseo.fn_week_subtopics(bigint, integer, bigint)

--

CREATE FUNCTION odiseo.fn_week_subtopics(p_syllabus_id bigint, p_week integer, p_company_id bigint) RETURNS TABLE(syllabus_id bigint, week smallint, topic_id smallint, topic_name character varying, subtopic_id smallint, subtopic_name character varying, amount smallint, questions_amount jsonb)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            WITH tbl_syllabus_subtopic_type_material AS (
                SELECT
                    st.id,
                    st.type_material_id,
                    tm.description AS type_material,
                    st.questions_amount AS amount,
                    st.syllabus_detail_subtopic_id
                FROM syllabus_subtopic_type_material st
                LEFT JOIN type_material tm ON st.type_material_id = tm.id
                WHERE st.fl_status = true
                AND tm.fl_status = true
                AND st.company_id = p_company_id
                ORDER BY tm.description ASC
            ), tbl_syllabus_detail_subtopic AS (
                SELECT
                    ds.id,
                    ds.syllabus_topic_week_id,
                    ds.subtopic_id,
                    s.name AS subtopic_name,
                    ds.questions_amount AS amount,
                    COALESCE(
                        jsonb_agg(
                            jsonb_build_object(
                                'id', st.id,
                                'type_material_id', st.type_material_id,
                                'type_material', st.type_material,
                                'amount', st.amount
                            )
                        ),
                        '[]'::jsonb
                    ) as questions_amount
                FROM syllabus_detail_subtopic ds
                LEFT JOIN subtopic s ON ds.subtopic_id = s.id
                LEFT JOIN tbl_syllabus_subtopic_type_material st ON ds.id = st.syllabus_detail_subtopic_id
                WHERE ds.fl_status = true
                AND ds.company_id = p_company_id
                GROUP BY ds.id, ds.syllabus_topic_week_id, ds.subtopic_id, s.name, ds.questions_amount
            ), tbl_syllabus_topic_week AS (
                SELECT
                    st.syllabus_id,
                    tw.week,
                    st.topic_id,
                    t.name AS topic_name,
                    ds.subtopic_id,
                    ds.subtopic_name,
                    ds.amount,
                    ds.questions_amount
                FROM syllabus_topic_week tw
                INNER JOIN tbl_syllabus_detail_subtopic ds ON tw.id = ds.syllabus_topic_week_id
                INNER JOIN syllabus_topic st ON tw.syllabus_topic_id = st.id
                INNER JOIN topic t ON st.topic_id = t.id
                WHERE tw.fl_status = true
                AND st.fl_status = true
                AND tw.company_id = p_company_id
                AND tw.week = p_week
                AND st.syllabus_id = p_syllabus_id
            )
            SELECT * FROM tbl_syllabus_topic_week
            ORDER BY topic_name ASC, subtopic_name ASC;
        END;
        $$;


ALTER FUNCTION odiseo.fn_week_subtopics(p_syllabus_id bigint, p_week integer, p_company_id bigint) OWNER TO postgres;

--
