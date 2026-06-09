-- Function: academic.fn_get_syllabus(bigint, bigint)

--

CREATE FUNCTION academic.fn_get_syllabus(p_syllabus_id bigint, p_company_id bigint) RETURNS TABLE(id bigint, university_id smallint, code_university character varying, slug_university character varying, university character varying, course_id bigint, apply_text_on_syllabus boolean, pseudo_course_id bigint, code_course character varying, course character varying, cycle_id bigint, code_cycle character varying, cycle character varying, weeks smallint, start_date date, end_date date, syllabus jsonb, syllabus_week_titles jsonb, type_text_template_id smallint)
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_university_id SMALLINT;
    v_course_id BIGINT;
    v_pseudo_course_id BIGINT;
BEGIN
    SELECT syl.university_id, syl.course_id, syl.pseudo_course_id
    INTO v_university_id, v_course_id, v_pseudo_course_id
    FROM syllabus syl
    WHERE syl.id = p_syllabus_id
    AND syl.company_id = p_company_id
    LIMIT 1;

    RETURN QUERY
    WITH tbl_syllabus_all_topic AS (
        SELECT DISTINCT
            NULL::BIGINT AS syllabus_topic_id,
            p_syllabus_id AS syllabus_id,
            st.university_id,
            st.course_id,
            st.pseudo_course_id,
            stt.topic_id,
            t.code,
            t.name
        FROM syllabus_template st
        INNER JOIN syllabus_template_topic stt ON st.id = stt.syllabus_template_id AND stt.fl_status IS TRUE
        INNER JOIN topic t ON stt.topic_id = t.id AND t.fl_status = true
        WHERE st.university_id = v_university_id
        AND (v_course_id IS NULL OR st.course_id = v_course_id)
        AND (v_pseudo_course_id IS NULL OR st.pseudo_course_id = v_pseudo_course_id)
        AND st.company_id = p_company_id
        AND st.fl_status = true
        UNION ALL
        SELECT DISTINCT
            st.id AS syllabus_topic_id,
            st.syllabus_id,
            v_university_id AS university_id,
            v_course_id AS course_id,
            null::bigint AS pseudo_course_id,
            st.topic_id,
            t.code,
            t.name
        FROM syllabus_topic st
        JOIN syllabus_template_topic stp ON stp.topic_id = st.topic_id AND stp.fl_status IS TRUE
        INNER JOIN syllabus_topic_week stw ON st.id = stw.syllabus_topic_id AND stw.fl_status = true
        LEFT JOIN topic t ON st.topic_id = t.id
        WHERE st.syllabus_id = p_syllabus_id
        AND st.company_id = p_company_id
        AND st.fl_status = true
    ), 
    tbl_syllabus_topic AS (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY tsat.topic_id ORDER BY syllabus_topic_id ASC NULLS LAST) AS row_num
        FROM tbl_syllabus_all_topic tsat
    ), 
    tbl_syllabus_duplicate AS (
        SELECT DISTINCT tstd.*
        FROM tbl_syllabus_topic tstd
        WHERE tstd.row_num = 1
        ORDER BY tstd.code ASC
    )
    SELECT
        s.id,
        s.university_id,
        u.code AS code_university,
        u.slug AS slug_university,
        u.name AS university,
        s.course_id,
        co.apply_text AS apply_text_on_syllabus,
        s.pseudo_course_id,
        CASE WHEN s.pseudo_course_id IS NULL THEN co.code ELSE pco.code END AS course_code,
        CASE WHEN s.pseudo_course_id IS NULL THEN co.name ELSE pco.name END AS course,
        s.cycle_id,
        cy.code AS code_cycle,
        cy.description AS cycle,
        cy.weeks,
        cy.start_date,
        cy.end_date,
        COALESCE(sub_topics.syllabus_json, '[]'::jsonb) AS syllabus,
        COALESCE(sub_weeks.weeks_json, '[]'::jsonb) AS syllabus_week_titles,
        co.type_text_template_id
    FROM syllabus s
    INNER JOIN origin_university u ON s.university_id = u.id
    LEFT JOIN course co ON s.course_id = co.id
    LEFT JOIN pseudo_course pco ON s.pseudo_course_id = pco.id
    INNER JOIN cycle cy ON s.cycle_id = cy.id
    LEFT JOIN LATERAL (
        SELECT jsonb_agg(
            jsonb_build_object(
                'id', tst.syllabus_topic_id,
                'syllabus_id', tst.syllabus_id,
                'topic_id', tst.topic_id,
                'code_topic', tst.code,
                'topic', tst.name,
                'weeks', ''
            )
        ) AS syllabus_json
        FROM tbl_syllabus_duplicate tst
        WHERE tst.syllabus_id = s.id
    ) sub_topics ON true
    LEFT JOIN LATERAL (
        SELECT 
            jsonb_agg(
                jsonb_build_object(
                    'week_id', cw.week,
                    'title', swt.title,
                    'type_week', tw.description,
                    'short_week_name', CONCAT_WS('-', cw.week, LEFT(tw.description, 1)),
                    'week_name', CONCAT_WS('-', cw.week, tw.description),
                    'type_week_id', tw.id
                ) ORDER BY cw.week
            ) AS weeks_json
        FROM cycle_weeks cw
        JOIN type_week tw 
            ON tw.id = cw.type_week_id 
            AND tw.fl_status = true AND tw.id != 5
        LEFT JOIN syllabus_week_titles swt 
            ON swt.week = cw.week
            AND swt.syllabus_id = s.id
            AND swt.fl_status = true
        WHERE cw.cycle_id = s.cycle_id
        AND cw.fl_status = true
    ) sub_weeks ON true
    WHERE s.id = p_syllabus_id
    AND s.company_id = p_company_id;
END;
$$;


ALTER FUNCTION academic.fn_get_syllabus(p_syllabus_id bigint, p_company_id bigint) OWNER TO postgres;

--
