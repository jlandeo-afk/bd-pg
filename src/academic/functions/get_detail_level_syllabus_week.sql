-- Function: academic.get_detail_level_syllabus_week(integer, integer, integer, integer, jsonb)

--

CREATE FUNCTION academic.get_detail_level_syllabus_week(p_university_id integer, p_cycle_id integer, p_week_id integer, p_course_id integer, p_headquarter_id jsonb) RETURNS TABLE(level_id bigint, name_level character varying, type_material_id smallint, name_type_material character varying, type_question text, total_questions integer)
    LANGUAGE plpgsql
    AS $$

        BEGIN

            RETURN QUERY
            SELECT
                tbl_detail_level_syllabus_week.level_id,
                tbl_detail_level_syllabus_week.name_level,
                tbl_detail_level_syllabus_week.type_material_id,
                tbl_detail_level_syllabus_week.name_type_material,
                tbl_detail_level_syllabus_week.type_question,
                COALESCE(tbl_value_detail_level_syllabus_week.number_questions, 0) AS number_questions
            FROM
                (
                    SELECT
                        l.id AS level_id,
                        l.description AS name_level,
                        tm.type_material_id,
                        tm.name_type_material,
                        tq.type_question,
                        cl.course_id
                    FROM
                        course_level cl
                    INNER JOIN
                        "level" l
                    ON
                        cl.level_id = l.id
                    CROSS JOIN
                        (SELECT 'T' AS type_question
                        UNION ALL
                        SELECT 'D' AS type_question) tq
                    CROSS JOIN
                        (SELECT
                            tm.id AS type_material_id,
                            tm.description AS name_type_material
                        FROM
                            type_material tm
                        WHERE
                            tm.fl_status = true
                            AND tm.deleted_at IS NULL
                            AND tm.cycle_id = p_cycle_id
                        ) AS tm
                    WHERE
                        cl.course_id = p_course_id
                        AND cl.fl_status = true
                        AND l.fl_status = true
                        AND l.deleted_at IS NULL
                ) AS tbl_detail_level_syllabus_week
            LEFT JOIN
                (
                    SELECT
                        DISTINCT dlsw.type_material_id,
                        dlsw.level_id,
                        dlsw.type_question,
                        dlsw.number_questions
                    FROM
                        level_syllabus ls
                    INNER JOIN
                        level_syllabus_weeks lsw
                    ON
                        ls.id = lsw.level_syllabus_id
                    INNER JOIN
                        detail_level_syllabus_weeks dlsw
                    ON
                        dlsw.level_syllabus_weeks_id = lsw.id
                    WHERE
                        ls.course_id = p_course_id
                        AND ls.university_id = p_university_id
                        AND ls.cycle_id = p_cycle_id
                        AND lsw.week  = p_week_id
                        AND ls.headquarter_id = ANY (SELECT jsonb_array_elements_text(p_headquarter_id)::INTEGER)
                        AND ls.fl_status = true
                        AND lsw.fl_status = true
                        AND dlsw.fl_status = true
                ) AS tbl_value_detail_level_syllabus_week
            ON
                tbl_detail_level_syllabus_week.level_id = tbl_value_detail_level_syllabus_week.level_id 
                AND tbl_detail_level_syllabus_week.type_question = tbl_value_detail_level_syllabus_week.type_question
                AND tbl_detail_level_syllabus_week.type_material_id = tbl_value_detail_level_syllabus_week.type_material_id
            ORDER BY
                tbl_detail_level_syllabus_week.name_level ASC,
                tbl_detail_level_syllabus_week.type_material_id ASC,
                tbl_detail_level_syllabus_week.type_question DESC;
        END;
        $$;


ALTER FUNCTION academic.get_detail_level_syllabus_week(p_university_id integer, p_cycle_id integer, p_week_id integer, p_course_id integer, p_headquarter_id jsonb) OWNER TO postgres;

--
