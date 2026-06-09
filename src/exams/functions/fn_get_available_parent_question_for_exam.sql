-- Function: exams.fn_get_available_parent_question_for_exam(bigint, smallint, smallint, bigint, bigint, integer, integer, integer, integer, integer, character varying)

--

CREATE FUNCTION exams.fn_get_available_parent_question_for_exam(p_material_id bigint, p_course_id smallint, p_week smallint, p_material_exam_area_week_id bigint, p_type_material_id bigint, p_category_id integer, p_subcategory_id integer, p_level_id integer, p_perpage integer, p_npage integer, p_search character varying) RETURNS TABLE(parent_question_id bigint, course_id smallint, level smallint, level_id bigint, category_id bigint, category_name character varying, subcategory_id bigint, subcategory_name character varying, category_position smallint, code character varying, periods smallint[], subquestion jsonb, subquestion_amount smallint, total bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    C_MORE_RECENT_USAGE SMALLINT DEFAULT 1;
    C_DEFAULT_STARTING_WEEK SMALLINT DEFAULT 1;
    C_TYPE_TWO_EXAM VARCHAR DEFAULT 'Tipo 2';
    C_TYPE_THREE_EXAM VARCHAR DEFAULT 'Tipo 3';
    offset_val INTEGER := NULL;
BEGIN
    IF p_perpage IS NOT NULL AND p_npage IS NOT NULL THEN
        offset_val := p_perpage * (p_npage - 1);
    END IF;
    RETURN QUERY
    WITH cycle_and_university AS (
        SELECT
            m.cycle_id,
            m.university_id,
            c.start_date,
            m.id AS material_id
        FROM material m
        JOIN cycle c ON c.id = m.cycle_id
        WHERE m.id = p_material_id
    ), limit_months_questions AS (
        SELECT
            limit_months_questions AS months_limit
        FROM advanced_settings
        WHERE fl_status IS TRUE
        LIMIT 1
    ), used_in_exam_parent_question_history AS (
        SELECT
            DISTINCT ON ( qeq.parent_question_id, dwtm.material_id )
            qeq.parent_question_id AS parent_question_id,
            dwtm.material_id AS material_id,
            m.cycle_id AS cycle_id,
            COALESCE( dwtm.parent_type_material_id, dwtm.type_material_id ) AS type_material_id,
            dwtm.week AS week
        FROM question_history_usage_exam_parent_question qeq
        JOIN material_exam_area_week meak ON meak.id = qeq.material_exam_area_week_id AND qeq.updated_at IS NULL 
        JOIN detail_week_type_mat dwtm ON dwtm.id = meak.week_type_material_id
        JOIN material m ON m.id = dwtm.material_id
        WHERE 1 = 1
        AND m.university_id IN ( SELECT w.university_id FROM cycle_and_university w )
    ), text_lasts_times_used_in_question_history_cycle AS (
        SELECT
            DISTINCT ON ( qh.parent_question_id, m.id )
            qh.parent_question_id AS parent_question_id,
            m.id AS material_id,
            m.cycle_id AS cycle_id,
            COALESCE( ddm.parent_type_material_id, ddm.type_material_id ) AS type_material_id,
            ddm.week AS week
        FROM question_history_cycle qh
        JOIN material m
          ON 1 = 1
         AND m.university_id IN ( SELECT cuv.university_id FROM cycle_and_university cuv )
         AND qh.fl_status IS TRUE
         AND qh.parent_question_id IS NOT NULL
         AND m.university_id = qh.university_id
         AND m.cycle_id = qh.cycle_id
         AND m.headquarte_id = qh.headquarters_id
        JOIN material_ballot_question mbq
          ON 1 = 1
         AND mbq.question_history_id =  qh.id
         AND mbq.fl_status IS TRUE
        JOIN detail_week_type_mat ddm
          ON 1 = 1
         AND ddm.id = mbq.week_type_material_id
    ), unifify_histories AS (
        SELECT * FROM used_in_exam_parent_question_history
        UNION
        SELECT * FROM text_lasts_times_used_in_question_history_cycle
    ), texts_times_used_in_university AS (
        SELECT
            uh.parent_question_id AS parent_question_id,
            ROW_NUMBER() OVER ( PARTITION BY uh.parent_question_id ORDER BY c.start_date DESC ) AS last_time_used_position,
            c.start_date AS cycle_start_date,
            uh.material_id AS material_id,
            uh.type_material_id AS type_material_id,
            uh.week AS week
        FROM unifify_histories uh
        JOIN cycle c ON uh.cycle_id = c.id
    ), text_last_time_used_per_text AS (
        SELECT
            stu.parent_question_id,
            stu.last_time_used_position,
            stu.cycle_start_date,
            stu.material_id,
            stu.type_material_id,
            stu.week
        FROM texts_times_used_in_university stu
        WHERE stu.last_time_used_position = C_MORE_RECENT_USAGE
    ), find_exam_type AS (
        SELECT
            txs.name AS exam_type_name
        FROM type_material tm
        JOIN type_material_template tmm ON tmm.id = tm.type_material_template_id AND tm.id = p_type_material_id
        JOIN type_exams txs ON txs.id = tmm.type_exam_id
    ), available_periods_weeks AS (
        SELECT
            *
        FROM fn_get_periods_weeks_on_type_material(p_type_material_id, p_week)
    ),
    syllabus_last_week AS (
        SELECT
            MAX(stw.week) AS max_week
        FROM syllabus s
        JOIN syllabus_text_weeks stw ON stw.syllabus_id = s.id
        WHERE 1 = 1
          AND s.course_id = p_course_id
          AND s.university_id IN ( SELECT university_id FROM cycle_and_university )
          AND s.cycle_id IN ( SELECT cycle_id FROM cycle_and_university )
          AND stw.fl_status IS TRUE
    ),
    syllabus_full_configuration AS (
        SELECT
            tt.id AS category_id,
            tt.name AS category_name,
            st.type_text_subcategory_id AS subcategory_id,
            sts.name AS subcategory_name,
            stc.subtopic_id AS subtopic_id,
            stp.topic_id AS topic_id,
            tt.position AS position,
            aw.period_number AS period_number,
            stw.week AS week
        FROM syllabus s
        JOIN syllabus_text_weeks stw ON stw.syllabus_id = s.id AND stw.fl_status IS TRUE
        JOIN syllabus_text_distributions std ON std.syllabus_text_week_id = stw.id AND std.fl_status IS TRUE
        JOIN type_material tm ON tm.id = std.type_material_id
        JOIN type_material_template tmt ON tmt.id = tm.type_material_template_id AND tmt.fl_use_syllabus_exam IS TRUE
        JOIN syllabus_texts st ON st.syllabus_text_distribution_id = std.id AND st.fl_status IS TRUE
        JOIN type_text_subcategories sts ON sts.id = st.type_text_subcategory_id
        JOIN syllabus_text_content stc ON stc.syllabus_text_id = st.id AND stc.fl_status IS TRUE
        JOIN type_text tt ON tt.id = st.type_text_id
        JOIN subtopic stp ON stp.id = stc.subtopic_id
        LEFT JOIN available_periods_weeks aw ON ( stw.week BETWEEN aw.starting_week AND aw.ending_week )
        WHERE 1 = 1
          AND s.university_id IN ( SELECT university_id FROM cycle_and_university )
          AND s.cycle_id IN ( SELECT cycle_id FROM cycle_and_university )
          AND s.course_id = p_course_id
          AND s.fl_status = true
          AND (
                (EXISTS( SELECT 1 FROM find_exam_type WHERE exam_type_name = 'Tipo 3' ))
                OR
                (aw.period_number IS NOT NULL)
          )
          AND (
            ( EXISTS( SELECT 1 FROM find_exam_type WHERE exam_type_name = C_TYPE_TWO_EXAM ) AND stw.week BETWEEN C_DEFAULT_STARTING_WEEK AND p_week )
            OR (EXISTS( SELECT 1 FROM find_exam_type WHERE exam_type_name = C_TYPE_THREE_EXAM ) AND stw.week BETWEEN C_DEFAULT_STARTING_WEEK AND (SELECT max_week FROM syllabus_last_week))
            OR ( NOT EXISTS( SELECT 1 FROM find_exam_type WHERE exam_type_name = C_TYPE_TWO_EXAM ) AND stw.week = p_week )
          )
    ), categories_from_syllabus AS (
        SELECT
            slf.category_id AS category_id,
            slf.category_name AS category_name,
            slf.period_number AS category_period_number,
            slf.position AS position
        FROM syllabus_full_configuration slf
        GROUP BY
            slf.category_id,
            slf.category_name,
            slf.period_number,
            slf.position
    ), subcategories_from_syllabus AS (
        SELECT
        ssc.subcategory_id AS subcategory_id,
        ssc.subcategory_name AS subcategory_name,
        ssc.period_number AS subcategory_period_number
        FROM syllabus_full_configuration ssc
        GROUP BY
            ssc.subcategory_id,
            ssc.subcategory_name,
            ssc.period_number
    ), cross_category_subcategory_same_period AS (
        SELECT
            cgf.category_id,
            cgf.category_name,
            scs.subcategory_id,
            scs.subcategory_name,
            cgf.category_period_number AS period,
            cgf.position
        FROM categories_from_syllabus cgf
        CROSS JOIN subcategories_from_syllabus scs
        WHERE 1 = 1
           AND (EXISTS( SELECT 1 FROM find_exam_type WHERE exam_type_name = 'Tipo 3' ) OR cgf.category_period_number = scs.subcategory_period_number)
    ), categories_and_subcategories_with_periods AS (
        SELECT
            cpp.category_id,
            cpp.category_name,
            cpp.subcategory_id,
            cpp.subcategory_name,
            ARRAY_AGG( DISTINCT cpp.period ORDER BY cpp.period ) AS periods,
            cpp.position
        FROM cross_category_subcategory_same_period cpp
        GROUP BY
            cpp.category_id,
            cpp.category_name,
            cpp.subcategory_id,
            cpp.subcategory_name,
            cpp.position
    ), subtopics_choosen_in_syllabus AS (
        SELECT
            sfl.subtopic_id AS subtopic_id
        FROM syllabus_full_configuration sfl
        GROUP BY sfl.subtopic_id
    ), parent_questions_in_material_exam_area_week_id AS (
        SELECT
            mpn.parent_question_id
        FROM material_exam_parent_question mpn
        WHERE 1 = 1
          AND p_material_exam_area_week_id IS NOT NULL
          AND mpn.material_exam_area_week_id = p_material_exam_area_week_id
          AND mpn.deleted_at IS NULL
          AND mpn.parent_question_id IS NOT NULL
    ), parent_questions AS (
        SELECT
            pq.id AS parent_question_id,
            pq.course_id AS course_id,
            l.name::SMALLINT AS level,
            l.id AS level_id,
            csc.category_id,
            csc.category_name,
            csc.subcategory_id,
            csc.subcategory_name,
            csc.position,
            pq.code,
            csc.periods
        FROM parent_question pq
        JOIN level l ON l.id = pq.level_id AND pq.level_id IS NOT NULL
        JOIN categories_and_subcategories_with_periods csc ON csc.category_id = pq.type_text_id AND pq.type_text_subcategory_id = csc.subcategory_id AND pq.course_id = p_course_id
        JOIN course c ON c.id = pq.course_id AND c.apply_text IS TRUE
        LEFT JOIN text_last_time_used_per_text tlt ON tlt.parent_question_id = pq.id
        LEFT JOIN cycle_and_university cau ON 1 = 1
        LEFT JOIN limit_months_questions lmq ON 1 = 1
        WHERE 1 = 1
          AND ( p_category_id IS NULL OR csc.category_id = p_category_id )
          AND ( p_subcategory_id IS NULL OR csc.subcategory_id = p_subcategory_id )
          AND ( p_level_id IS NULL OR l.name = p_level_id::VARCHAR )
          AND ( p_search IS NULL OR pq.code ILIKE '%' || p_search || '%' )
          AND pq.status NOT IN ('ARCH', 'DUPL')
          AND ( p_material_exam_area_week_id IS NULL OR pq.id NOT IN ( SELECT wi.parent_question_id FROM parent_questions_in_material_exam_area_week_id wi ) )
          AND ( tlt.last_time_used_position IS NULL
            OR ( cau.start_date >= tlt.cycle_start_date AND ( tlt.cycle_start_date >= cau.start_date - (lmq.months_limit || ' months')::INTERVAL ) )
            OR ( cau.start_date > tlt.cycle_start_date AND ( cau.start_date >= tlt.cycle_start_date - (lmq.months_limit || ' months')::INTERVAL ) )
            OR ( cau.start_date >= tlt.cycle_start_date AND ( tlt.cycle_start_date >= cau.start_date - INTERVAL '21 days' ) )
            OR ( cau.start_date < tlt.cycle_start_date AND ( cau.start_date >= tlt.cycle_start_date - INTERVAL '21 days' ) ) 
          )
    ), sub_questions AS (
        SELECT
            pss.parent_question_id,
            JSONB_AGG(
                JSONB_BUILD_OBJECT(
                    'code', q.code,
                    'question_id', q.id,
                    'topic', t.name,
                    'topic_id', q.topic_id,
                    'subtopic', stp.name,
                    'subtopic_id', sq.subtopic_id
                )
            ) AS subquestions,
            COUNT(q.*) AS subquestions_amount
        FROM parent_questions pss
        JOIN question q ON q.parent_id = pss.parent_question_id
        LEFT JOIN question_subtopic sq ON sq.question_id = q.id AND sq.fl_status IS TRUE
        LEFT JOIN subtopic stp ON stp.id = sq.subtopic_id
        LEFT JOIN topic t ON t.id = stp.topic_id
        WHERE  1 = 1
          AND sq.subtopic_id IN ( SELECT subtopic_id FROM subtopics_choosen_in_syllabus )
          AND q.status IN ('VERI', 'APRB')
        GROUP BY pss.parent_question_id
    )
    SELECT
        pqs.*,
        ssq.subquestions,
        ssq.subquestions_amount::SMALLINT AS subquestions_amount,
        COUNT(pqs.*) OVER () AS total
    FROM parent_questions pqs
    JOIN sub_questions ssq ON pqs.parent_question_id = ssq.parent_question_id
    ORDER BY ssq.subquestions_amount DESC
    LIMIT
        CASE
            WHEN p_perpage IS NOT NULL THEN p_perpage
        END
    OFFSET
        CASE
            WHEN offset_val IS NOT NULL THEN offset_val
    END;
END;
$$;


ALTER FUNCTION exams.fn_get_available_parent_question_for_exam(p_material_id bigint, p_course_id smallint, p_week smallint, p_material_exam_area_week_id bigint, p_type_material_id bigint, p_category_id integer, p_subcategory_id integer, p_level_id integer, p_perpage integer, p_npage integer, p_search character varying) OWNER TO postgres;

--
