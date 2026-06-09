-- Function: academic.fn_search_level_syllabus(integer, integer, character varying, bigint, integer, integer, integer, boolean, integer, integer)

--

CREATE FUNCTION academic.fn_search_level_syllabus(p_perpage integer, p_npage integer, p_name_text character varying, p_employee_id bigint, p_course_id integer, p_university_id integer, p_cycle_id integer, p_cycle_active boolean, p_headquarter_id integer, p_company_id integer) RETURNS TABLE(id bigint, university_id smallint, university character varying, headquarter_id smallint, headquarter character varying, cycle_id bigint, cycle character varying, course_id smallint, course character varying, created_at timestamp without time zone, created_by text, is_weeks_configured boolean, total_count bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_offset_val INTEGER := p_perpage * (p_npage - 1);
BEGIN
    RETURN QUERY
    WITH filtered_level_syllabus AS (
        SELECT
            ls.id,
            ou.id AS university_id,
            ou."name" AS university,
            h.id AS headquarter_id,
            h.name AS headquarter,
            c2.id AS cycle_id,
            c2.description AS cycle,
            c.id AS course_id,
            c.name AS course,
            ls.created_at,
            CASE
                WHEN e.first_name IS NOT NULL AND e.first_surname IS NOT NULL THEN
                    CONCAT(
                        initcap(split_part(e.first_name, ' ', 1)), ' ',
                        upper(left(e.first_surname, 1)), '. ',
                        initcap(e.second_surname)
                    )
                ELSE NULL
            END AS created_by
        FROM level_syllabus ls
        LEFT JOIN course c ON ls.course_id = c.id
        LEFT JOIN origin_university ou ON ls.university_id = ou.id
        LEFT JOIN headquarters h ON ls.headquarter_id = h.id
        INNER JOIN "cycle" c2 ON ls.cycle_id = c2.id
        LEFT JOIN users u ON ls.created_by = u.id
        LEFT JOIN employees e ON e.user_id = u.id
        WHERE ls.fl_status = true
          AND ls.deleted_at IS NULL
          AND (p_company_id IS NULL OR ls.company_id = p_company_id)
          AND (p_employee_id IS NULL OR e.id = p_employee_id)
          AND (p_course_id IS NULL OR c.id = p_course_id)
          AND (p_university_id IS NULL OR ou.id = p_university_id)
          AND (p_cycle_id IS NULL OR c2.id = p_cycle_id)
          AND (p_cycle_active IS NULL OR c2.active = p_cycle_active)
          AND (p_headquarter_id IS NULL OR h.id = p_headquarter_id)
          AND (
              p_name_text IS NULL
              OR c2.description ILIKE '%' || p_name_text || '%'
              OR ou."name" ILIKE '%' || p_name_text || '%'
              OR h.name ILIKE '%' || p_name_text || '%'
          )
    ),
    paginated_results AS (
        SELECT *, count(*) OVER () AS total_count_window
        FROM filtered_level_syllabus
        ORDER BY created_at DESC, university_id ASC
        LIMIT p_perpage
        OFFSET v_offset_val
    )
    SELECT 
        pr.id,
        pr.university_id,
        pr.university,
        pr.headquarter_id,
        pr.headquarter,
        pr.cycle_id,
        pr.cycle,
        pr.course_id,
        pr.course,
        pr.created_at,
        pr.created_by,
        -- El resultado del JOIN LATERAL
        chk.is_configured AS is_weeks_configured,
        pr.total_count_window AS total_count
    FROM paginated_results pr
    CROSS JOIN LATERAL (
        SELECT NOT EXISTS (
            WITH expected_raw AS (
                SELECT 
                    tmdt.week,
                    tm.id AS material_type_id,
                    SUM(CASE WHEN tmc.is_generic = true THEN tmc.amount_question ELSE COALESCE(tmdc.amount_question, 0) END) AS total_question,
                    SUM(CASE WHEN tmc.is_generic_text = true THEN tmc.amount_text ELSE COALESCE(tmdct.amount_text, 0) END) AS total_text
                FROM type_material tm
                JOIN type_material_detail_template tmdt ON tmdt.type_material_id = tm.id AND tmdt.fl_status = true AND tmdt.deleted_at IS NULL
                JOIN type_material_template tmt ON tmt.id = tm.type_material_template_id 
                JOIN type_material_course tmc ON tmc.type_material_id = tm.id
                LEFT JOIN type_material_detail_courses tmdc ON tmdc.type_material_course_id = tmc.id AND tmdc.type_material_detail_template_id = tmdt.id
                LEFT JOIN type_material_detail_course_texts tmdct ON tmdct.type_material_course_id = tmc.id AND tmdct.type_material_detail_template_id = tmdt.id
                WHERE tm.cycle_id = pr.cycle_id
                  AND tmc.course_id = pr.course_id
                  AND tm.fl_exam = false
                  AND tm.fl_status = true
                  AND (
                      tm.parent_id IS NOT NULL
                      OR tm.id NOT IN (SELECT parent_id FROM type_material tm2 WHERE tm2.cycle_id = tm.cycle_id AND parent_id IS NOT NULL)
                  )
                GROUP BY tmdt.week, tm.id
            ),
            expected AS (
                SELECT week, material_type_id, 'P' AS type, total_question AS total FROM expected_raw 
                UNION ALL
                SELECT week, material_type_id, 'T' AS type, total_text AS total FROM expected_raw 
            ),
            actual_materials AS (
                SELECT level_syllabus_weeks_id, type_material_id, 'P' AS type, COALESCE(number_questions, 0) AS total
                FROM detail_level_syllabus_weeks
                WHERE fl_status = true AND deleted_at IS NULL AND COALESCE(number_questions, 0) > 0
                UNION ALL
                SELECT level_syllabus_weeks_id, type_material_id, 'T' AS type, COALESCE(number_of_passages, 0) AS total
                FROM detail_level_syllabus_weeks_parents
                WHERE fl_status = true AND deleted_at IS NULL AND COALESCE(number_of_passages, 0) > 0
            ),
            actual AS (
                SELECT 
                    lsw.week, 
                    am.type_material_id AS material_type_id, 
                    am.type,
                    SUM(am.total) AS total
                FROM level_syllabus_weeks lsw 
                JOIN actual_materials am ON am.level_syllabus_weeks_id = lsw.id 
                WHERE lsw.level_syllabus_id = pr.id 
                  AND lsw.fl_status = true 
                GROUP BY lsw.id, lsw.week, am.type_material_id, am.type
            )
            SELECT 1
            FROM expected e
            FULL OUTER JOIN actual a 
                ON e.week = a.week 
               AND e.material_type_id = a.material_type_id
               AND e.type = a.type
            WHERE COALESCE(e.total, 0) != COALESCE(a.total, 0)
        ) AS is_configured
    ) chk;
END;
$$;


ALTER FUNCTION academic.fn_search_level_syllabus(p_perpage integer, p_npage integer, p_name_text character varying, p_employee_id bigint, p_course_id integer, p_university_id integer, p_cycle_id integer, p_cycle_active boolean, p_headquarter_id integer, p_company_id integer) OWNER TO postgres;

--
