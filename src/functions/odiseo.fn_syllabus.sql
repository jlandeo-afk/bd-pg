-- Function: odiseo.fn_syllabus(integer, integer, jsonb, jsonb, bigint, boolean, bigint)

--

CREATE FUNCTION odiseo.fn_syllabus(p_perpage integer, p_npage integer, f_course_ids jsonb, f_university_ids jsonb, f_cycle_id bigint, f_cycle_active boolean, p_company_id bigint) RETURNS TABLE(id bigint, university_id smallint, code_university character varying, slug_university character varying, university character varying, course_id bigint, code_course character varying, course character varying, cycle_id bigint, code_cycle character varying, cycle character varying, start_date date, end_date date, is_topic_modified boolean, is_disabled boolean, is_deleteable boolean, created_at timestamp without time zone, is_inconsistent boolean, total bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    offset_val INTEGER;
BEGIN
    offset_val := p_perpage * (p_npage - 1);
    
    RETURN QUERY
    WITH tbl_syllabus AS (
        SELECT
            s.id, s.university_id, u.code AS code_university, u.slug AS slug_university, u.name AS university,
            s.course_id, co.code AS code_course, co.name AS course, s.cycle_id, cy.code AS code_cycle,
            cy.description AS cycle, cy.start_date, cy.end_date, false AS is_topic_modified,
            s.is_disabled, s.is_deleteable, s.created_at
        FROM syllabus s
        INNER JOIN origin_university u ON s.university_id = u.id
        LEFT JOIN course co ON s.course_id = co.id
        INNER JOIN cycle cy ON s.cycle_id = cy.id
        WHERE s.fl_status = TRUE
        AND s.course_id IN (SELECT value::BIGINT FROM jsonb_array_elements_text(f_course_ids) AS value)
        AND s.university_id IN ( SELECT value::BIGINT FROM jsonb_array_elements_text(f_university_ids) AS value)
        AND (f_cycle_id IS NULL OR s.cycle_id = f_cycle_id)
        AND (f_cycle_active IS NULL OR cy.active = f_cycle_active)
        AND s.company_id = p_company_id
    ),

    counted_syllabus AS (
        SELECT *, COUNT(*) OVER () AS total_rows
        FROM tbl_syllabus
        ORDER BY
            tbl_syllabus.created_at DESC,
            tbl_syllabus.university_id ASC,
            tbl_syllabus.start_date DESC,
            tbl_syllabus.cycle_id DESC
    ),
    paginated_syllabus AS (
        SELECT * FROM counted_syllabus
        LIMIT p_perpage OFFSET offset_val
    ),
    cycle_active_weeks AS (
        SELECT DISTINCT cw.cycle_id, cw.week
        FROM cycle_weeks cw
        JOIN type_week tw ON tw.id = cw.type_week_id
        WHERE cw.cycle_id IN (SELECT DISTINCT ps2.cycle_id FROM paginated_syllabus ps2)
        AND cw.fl_status = true
        AND tw.description != 'Inactiva'
        AND cw.week IS NOT NULL
    ),
    all_type_materials AS (
        SELECT DISTINCT
            tmc.course_id,
            tm.cycle_id,
            tm.id AS type_material_id
        FROM type_material tm
        JOIN type_material_course tmc ON tmc.type_material_id = tm.id
        WHERE tm.cycle_id IN (SELECT DISTINCT ps2.cycle_id FROM paginated_syllabus ps2)
        AND tmc.course_id IN (SELECT DISTINCT ps2.course_id FROM paginated_syllabus ps2)
        AND tm.fl_exam = false
        AND tm.fl_status = true
        AND (
            tm.parent_id IS NOT NULL
            OR tm.id NOT IN (
                SELECT sub_tm.parent_id FROM type_material sub_tm
                WHERE sub_tm.cycle_id = tm.cycle_id AND sub_tm.parent_id IS NOT NULL
            )
        )
    ),
    all_combinations AS (
        SELECT
            atm.course_id,
            atm.cycle_id,
            caw.week,
            atm.type_material_id
        FROM all_type_materials atm
        JOIN cycle_active_weeks caw ON caw.cycle_id = atm.cycle_id
    ),
    expected_config AS (
        SELECT
            tmc.course_id,
            tm.cycle_id,
            tmdt.week,
            tm.id AS type_material_id,
            'P'::text AS type,
            SUM(CASE WHEN tmc.is_generic = true THEN tmc.amount_question ELSE COALESCE(tmdc.amount_question, 0) END) AS expected_amount
        FROM type_material tm
        JOIN type_material_detail_template tmdt ON tmdt.type_material_id = tm.id AND tmdt.fl_status = true
        JOIN type_material_course tmc ON tmc.type_material_id = tm.id
        LEFT JOIN type_material_detail_courses tmdc ON tmdc.type_material_course_id = tmc.id AND tmdc.type_material_detail_template_id = tmdt.id
        WHERE tm.cycle_id IN (SELECT DISTINCT ps2.cycle_id FROM paginated_syllabus ps2)
        AND tmc.course_id IN (SELECT DISTINCT ps2.course_id FROM paginated_syllabus ps2)
        AND tm.fl_exam = false AND tm.fl_status = true
        AND (
            tm.parent_id IS NOT NULL
            OR tm.id NOT IN (
                SELECT sub_tm.parent_id FROM type_material sub_tm
                WHERE sub_tm.cycle_id = tm.cycle_id AND sub_tm.parent_id IS NOT NULL
            )
        )
        GROUP BY tmc.course_id, tm.cycle_id, tmdt.week, tm.id
        HAVING SUM(CASE WHEN tmc.is_generic = true THEN tmc.amount_question ELSE COALESCE(tmdc.amount_question, 0) END) > 0

        UNION ALL

        SELECT
            tmc.course_id,
            tm.cycle_id,
            tmdt.week,
            tm.id AS type_material_id,
            'T'::text AS type,
            SUM(CASE WHEN tmc.is_generic_text = true THEN tmc.amount_text ELSE COALESCE(tmdct.amount_text, 0) END) AS expected_amount
        FROM type_material tm
        JOIN type_material_detail_template tmdt ON tmdt.type_material_id = tm.id AND tmdt.fl_status = true
        JOIN type_material_course tmc ON tmc.type_material_id = tm.id
        LEFT JOIN type_material_detail_course_texts tmdct ON tmdct.type_material_course_id = tmc.id AND tmdct.type_material_detail_template_id = tmdt.id
        WHERE tm.cycle_id IN (SELECT DISTINCT ps2.cycle_id FROM paginated_syllabus ps2)
        AND tmc.course_id IN (SELECT DISTINCT ps2.course_id FROM paginated_syllabus ps2)
        AND tm.fl_exam = false AND tm.fl_status = true
        AND (
            tm.parent_id IS NOT NULL
            OR tm.id NOT IN (
                SELECT sub_tm.parent_id FROM type_material sub_tm
                WHERE sub_tm.cycle_id = tm.cycle_id AND sub_tm.parent_id IS NOT NULL
            )
        )
        GROUP BY tmc.course_id, tm.cycle_id, tmdt.week, tm.id
        HAVING SUM(CASE WHEN tmc.is_generic_text = true THEN tmc.amount_text ELSE COALESCE(tmdct.amount_text, 0) END) > 0
    ),
    actual_syllabus AS (
        SELECT
            st.syllabus_id,
            stw.week,
            sstm.type_material_id,
            'P'::text AS type,
            SUM(sstm.questions_amount) AS actual_amount
        FROM syllabus_subtopic_type_material sstm
        JOIN syllabus_detail_subtopic sds ON sds.id = sstm.syllabus_detail_subtopic_id
        JOIN syllabus_topic_week stw ON stw.id = sds.syllabus_topic_week_id
        JOIN syllabus_topic st ON st.id = stw.syllabus_topic_id
        WHERE st.syllabus_id IN (SELECT ps2.id FROM paginated_syllabus ps2)
        AND sstm.fl_status = true AND sds.fl_status = true AND stw.fl_status = true AND st.fl_status = true
        GROUP BY st.syllabus_id, stw.week, sstm.type_material_id

        UNION ALL

        SELECT
            stw.syllabus_id,
            stw.week,
            std.type_material_id,
            'T'::text AS type,
            COUNT(stx.id) AS actual_amount
        FROM syllabus_text_weeks stw
        JOIN syllabus_text_distributions std ON std.syllabus_text_week_id = stw.id AND std.fl_status = true
        JOIN syllabus_texts stx ON stx.syllabus_text_distribution_id = std.id AND stx.fl_status = true
        WHERE stw.syllabus_id IN (SELECT ps2.id FROM paginated_syllabus ps2)
        AND stw.fl_status = true
        GROUP BY stw.syllabus_id, stw.week, std.type_material_id
    ),
    syllabus_inconsistencies AS (
        SELECT DISTINCT ps2.id AS syllabus_id
        FROM paginated_syllabus ps2
        JOIN all_combinations ac ON ac.course_id = ps2.course_id AND ac.cycle_id = ps2.cycle_id
        LEFT JOIN expected_config ec
            ON ec.course_id = ac.course_id
            AND ec.cycle_id = ac.cycle_id
            AND ec.week = ac.week
            AND ec.type_material_id = ac.type_material_id
        LEFT JOIN actual_syllabus asy
            ON asy.syllabus_id = ps2.id
            AND asy.week = ac.week
            AND asy.type_material_id = ac.type_material_id
            AND asy.type = ec.type
        WHERE
            (ec.expected_amount IS NOT NULL AND asy.actual_amount IS NULL)
            -- inconsistent: las cantidades no coinciden
            OR ec.expected_amount != COALESCE(asy.actual_amount, 0)
    )
    SELECT 
        ps.id, ps.university_id, ps.code_university, ps.slug_university, ps.university,
        ps.course_id, ps.code_course, ps.course, ps.cycle_id, ps.code_cycle, ps.cycle,
        ps.start_date, ps.end_date, ps.is_topic_modified, ps.is_disabled, ps.is_deleteable, ps.created_at,
        (si.syllabus_id IS NOT NULL) AS is_inconsistent,
        ps.total_rows AS total
    FROM paginated_syllabus ps
    LEFT JOIN syllabus_inconsistencies si ON si.syllabus_id = ps.id;
END;
$$;


ALTER FUNCTION odiseo.fn_syllabus(p_perpage integer, p_npage integer, f_course_ids jsonb, f_university_ids jsonb, f_cycle_id bigint, f_cycle_active boolean, p_company_id bigint) OWNER TO postgres;

--
