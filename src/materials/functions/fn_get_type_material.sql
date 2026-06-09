-- Function: materials.fn_get_type_material(integer)

--

CREATE FUNCTION materials.fn_get_type_material(p_type_material_id integer) RETURNS TABLE(id smallint, code character varying, description character varying, type_material_template_id bigint, type_material_template character varying, amount_question integer, areas jsonb, cycle_id bigint, cycle_name character varying, fl_status boolean, fl_exam boolean, fl_class_material boolean, thread smallint, level_order boolean, percentage numeric, courses jsonb, weeks jsonb, children_ids jsonb, periodicity_id smallint, periodicity character varying, quantity_week smallint, start_week smallint, group_previous_week boolean, group_remaining_week boolean)
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_ids_children INT[];
    v_fl_exam BOOLEAN;
BEGIN
    SELECT tm.fl_exam INTO v_fl_exam 
    FROM type_material tm 
    WHERE tm.id = p_type_material_id;

    SELECT ARRAY(SELECT tm.id FROM type_material tm WHERE tm.parent_id = p_type_material_id) INTO v_ids_children;
    
    IF array_length(v_ids_children, 1) IS NULL THEN
        v_ids_children := ARRAY[p_type_material_id];
    END IF;

    IF v_fl_exam THEN
        RETURN QUERY
        WITH tbl_area_exam_courses AS (
            SELECT
                tbl_area_courses.course_id,
                tbl_area_courses.course,
                tbl_area_courses.area_id,
                tbl_area_courses.type_material_id,
                COALESCE(tbl_courses.amount_question, 0) AS amount_question,
                COALESCE(tbl_courses.amount_text, 0) AS amount_text,
                tbl_area_courses.apply_text
            FROM (
                SELECT
                    c.code || ' - ' || c.name AS course,
                    c.id AS course_id,
                    tma.area_id,
                    tma.type_material_id,
                    c.apply_text
                FROM course c
                CROSS JOIN type_material_area tma
                WHERE tma.type_material_id = p_type_material_id 
                  AND c.fl_status = TRUE 
                  AND tma.fl_status = TRUE
                ORDER BY c.name, tma.area_id
            ) AS tbl_area_courses
            LEFT JOIN (
                SELECT tmc.course_id, tma.area_id, tmc.amount_question, tmc.amount_text
                FROM type_material_area_courses tmac
                LEFT JOIN type_material_course tmc
                    ON tmac.type_material_course_id = tmc.id AND tmc.fl_status = TRUE
                LEFT JOIN type_material_area tma
                    ON tmac.type_material_area_id = tma.id
                WHERE tmc.type_material_id = p_type_material_id
            ) AS tbl_courses
            ON tbl_area_courses.course_id = tbl_courses.course_id
            AND tbl_area_courses.area_id = tbl_courses.area_id
        )
        SELECT
            t.id,
            t.code,
            t.description,
            t.type_material_template_id,
            tmt.name AS type_material_template,
            t.amount_question,
            COALESCE(
                jsonb_agg(DISTINCT jsonb_build_object('id', tma.area_id, 'description', a.description))
                FILTER (WHERE tma.area_id IS NOT NULL AND tma.fl_status = TRUE AND a.description IS NOT NULL AND a.fl_status = TRUE),
                '[]'::jsonb
            ) AS areas,
            t.cycle_id,
            c.description AS cycle_name,
            t.fl_status,
            t.fl_exam,
            t.fl_class_material,
            t.thread,
            t.level_order,
            t.percentage,
            COALESCE(
                jsonb_agg(DISTINCT jsonb_build_object(
                    'id', tblexamcourse.course_id,
                    'name', tblexamcourse.course,
                    'amount', COALESCE(tblexamcourse.amount_question, 0),
                    'amount_text', COALESCE(tblexamcourse.amount_text, 0),
                    'area_id', tblexamcourse.area_id,
                    'apply_text', tblexamcourse.apply_text,
                    'subquestions', COALESCE(
                        (SELECT jsonb_agg(
                            jsonb_build_object(
                                'subquestion_amount', ttmtca.subquestion_amount,
                                'position', ttmtca.position
                            ) ORDER BY ttmtca.position
                        )
                        FROM type_text_material_type_course_area ttmtca
                        WHERE ttmtca.type_material_id = tblexamcourse.type_material_id
                        AND ttmtca.course_id = tblexamcourse.course_id
                        AND ttmtca.exam_area_id = tblexamcourse.area_id
                        AND ttmtca.deleted_at IS NULL
                        ), '[]'::jsonb
                    )
                )) FILTER (WHERE tblexamcourse.course_id IS NOT NULL),
                '[]'::jsonb
            ) AS courses,
            COALESCE(
                jsonb_agg(DISTINCT typematedetatemp.week) FILTER (WHERE typematedetatemp.fl_status = TRUE),
                '[]'::jsonb
            ) AS weeks,
            '[]'::jsonb children_ids,
            tmp.periodicity_id,
            p.name AS periodicity,
            tmp.quantity_week,
            tmp.start_week,
            tmp.group_previous_week,
            tmp.group_remaining_week
        FROM type_material t
        LEFT JOIN type_material_template tmt ON tmt.id = t.type_material_template_id
        LEFT JOIN type_material_detail_template typematedetatemp ON typematedetatemp.type_material_id = t.id
        LEFT JOIN tbl_area_exam_courses AS tblexamcourse ON tblexamcourse.type_material_id = t.id
        JOIN cycle c ON t.cycle_id = c.id
        LEFT JOIN type_material_area tma ON tma.type_material_id = t.id
        LEFT JOIN exam_area a ON a.id = tma.area_id
        LEFT JOIN type_material_periodicity tmp ON t.id = tmp.type_material_id AND tmp.fl_status = true
        LEFT JOIN periodicity p ON tmp.periodicity_id = p.id
        WHERE t.id = p_type_material_id
        GROUP BY
            t.id, t.code, t.description, t.type_material_template_id, tmt.name,
            t.amount_question, t.cycle_id, c.description, t.fl_status, t.fl_exam,
            t.fl_class_material, t.thread, t.level_order, t.percentage,
            tmp.periodicity_id, p.name, tmp.quantity_week, tmp.start_week,
            tmp.group_previous_week, tmp.group_remaining_week;
    ELSE
        RETURN QUERY
        WITH type_material_ids AS (
            SELECT unnest(v_ids_children) AS type_material_id
        ),
        tbl_material_courses_base AS (
            SELECT
                c.id AS course_id,
                c.code || ' - ' || c.name AS course,
                tmi.type_material_id,
                COALESCE(tmc.amount_question, 0) AS amount_question,
                COALESCE(tmc.amount_text, 0) AS amount_text,
                c.apply_text,
                COALESCE(tmt.id, tm_default.type_material_template_id) AS template_id,
                tmc.is_generic,
                tmc.is_generic_text,
                tmc.id AS type_material_course_id
            FROM course c
            CROSS JOIN type_material_ids tmi
            LEFT JOIN type_material_course tmc
                ON tmc.course_id = c.id AND tmc.type_material_id = tmi.type_material_id
            LEFT JOIN type_material tm
                ON tm.id = tmc.type_material_id
            LEFT JOIN type_material_template tmt
                ON tmt.id = tm.type_material_template_id
            LEFT JOIN type_material tm_default
                ON tm_default.id = tmi.type_material_id
            WHERE c.fl_status = true AND tm.fl_status = true
        )
        SELECT
            t.id,
            t.code,
            t.description,
            t.type_material_template_id,
            tmt.name AS type_material_template,
            t.amount_question,
            '[]'::jsonb AS areas,
            t.cycle_id,
            c.description AS cycle_name,
            t.fl_status,
            t.fl_exam,
            t.fl_class_material,
            t.thread,
            t.level_order,
            t.percentage,
            COALESCE(courses_data.json, '[]'::jsonb) AS courses,
            COALESCE(
                (SELECT jsonb_agg(week ORDER BY week)
                 FROM type_material_detail_template tmdt
                 WHERE tmdt.type_material_id = t.id AND tmdt.fl_status = TRUE),
                '[]'::jsonb
            ) AS weeks,
            (
                SELECT COALESCE(jsonb_agg(t2.id), '[]'::jsonb)
                FROM type_material t2
                WHERE t2.parent_id = t.id
            ) AS children_ids,
            tmp.periodicity_id,
            p.name AS periodicity,
            tmp.quantity_week,
            tmp.start_week,
            tmp.group_previous_week,
            tmp.group_remaining_week
        FROM type_material t
        LEFT JOIN type_material_template tmt ON tmt.id = t.type_material_template_id
        JOIN cycle c ON t.cycle_id = c.id
        LEFT JOIN type_material_periodicity tmp ON t.id = tmp.type_material_id AND tmp.fl_status = true
        LEFT JOIN periodicity p ON tmp.periodicity_id = p.id
        LEFT JOIN LATERAL (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id', mc.course_id,
                    'name', mc.course,
                    'amount', mc.amount_question,
                    'amount_text', mc.amount_text,
                    'area_id', NULL,
                    'apply_text', mc.apply_text,
                    'type_material_child_id', mc.template_id,
                    'type_material_id', mc.type_material_id,
                    'is_generic', mc.is_generic,
                    'is_generic_text', mc.is_generic_text,
                    'type_material_course_id', mc.type_material_course_id,
                    'subquestions', COALESCE(
                        (SELECT jsonb_agg(
                            jsonb_build_object(
                                'subquestion_amount', ttmtc.subquestion_amount,
                                'position', ttmtc.position
                            ) ORDER BY ttmtc.position
                        )
                        FROM type_text_material_type_course ttmtc
                        WHERE ttmtc.type_material_id = mc.type_material_id
                        AND ttmtc.course_id = mc.course_id
                        AND ttmtc.deleted_at IS NULL
                        ), '[]'::jsonb
                    )
                )
            ) as json
            FROM tbl_material_courses_base mc
        ) courses_data ON true
        WHERE t.id = p_type_material_id AND t.fl_status = true;
    END IF;
END;
$$;


ALTER FUNCTION materials.fn_get_type_material(p_type_material_id integer) OWNER TO postgres;

--
