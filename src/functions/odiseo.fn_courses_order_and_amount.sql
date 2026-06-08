-- Function: odiseo.fn_courses_order_and_amount(smallint, bigint, smallint)

--

CREATE FUNCTION odiseo.fn_courses_order_and_amount(p_type_material_id smallint, p_area_id bigint, p_university_id smallint) RETURNS TABLE(course_id bigint, course character varying, amount_question integer, "position" smallint, initial bigint)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            C_TYPE_EXAM_ONE BIGINT DEFAULT 2;
            C_TYPE_EXAM_TWO BIGINT DEFAULT 3;
            C_TYPE_EXAM_THREE BIGINT DEFAULT 4;

            v_type_material_template_id BIGINT;
            v_type_exam_id BIGINT;
            v_university_id SMALLINT;
        BEGIN
            SELECT type_material_template_id INTO v_type_material_template_id FROM type_material WHERE id = p_type_material_id LIMIT 1;
            SELECT type_exam_id INTO v_type_exam_id FROM type_material_template WHERE id = v_type_material_template_id;

            SELECT
                CASE
                    WHEN p_university_id = 16 THEN p_university_id
                    ELSE NULL
                END AS university_id
            INTO v_university_id;

            RETURN QUERY
            WITH tbl_course_ordering AS (
                SELECT
                    ttmco.course_id,
                    tm.id AS type_material_id,
                    ttmco.position
                FROM template_type_material_courses_order ttmco
                INNER JOIN type_material tm ON tm.type_material_template_id = ttmco.template_type_material_id
                WHERE ttmco.template_type_material_id = v_type_material_template_id
                    AND tm.id = p_type_material_id
                    AND ttmco.university_id IS NOT DISTINCT FROM v_university_id
            ), tbl_course_area_text AS ( -- <-- Cantidad de textos
                SELECT
                    ttmtca.course_id,
                    SUM(ttmtca.subquestion_amount)::INTEGER AS amount_question,
                    ttmtca.type_material_id,
                    ttmtca.exam_area_id
                FROM type_text_material_type_course_area ttmtca
                WHERE 1 = 1
                AND ttmtca.type_material_id = p_type_material_id
                AND ttmtca.exam_area_id = p_area_id
                AND ttmtca.deleted_at IS NULL
                AND v_type_exam_id IN (C_TYPE_EXAM_ONE, C_TYPE_EXAM_TWO, C_TYPE_EXAM_THREE)
                GROUP BY
                    ttmtca.type_material_id,
                    ttmtca.course_id,
                    ttmtca.exam_area_id
            ), tbl_course_area AS (
                SELECT
                    tmc.course_id,
                    ( tmc.amount_question + COALESCE(cat.amount_question, 0)) AS amount_question, -- <-- Se suma la cantidad de textos a las cantidad de preguntas
                    tmc.type_material_id,
                    tma.area_id
                FROM type_material_course tmc
                INNER JOIN type_material_area_courses tmac ON tmc.id = tmac.type_material_course_id AND tmac.fl_status = true
                INNER JOIN type_material_area tma ON tmac.type_material_area_id = tma.id AND tma.fl_status = TRUE
                LEFT JOIN tbl_course_area_text cat ON cat.type_material_id = tmc.type_material_id AND cat.exam_area_id = tma.area_id AND tmc.course_id = cat.course_id -- Se une la cantidad de textos
                WHERE tmc.fl_status = true
                AND tma.area_id = p_area_id
                AND tma.type_material_id = p_type_material_id
                AND ( tmc.amount_question > 0 OR cat.amount_question > 0 )
            ), tbl_courses AS (
                SELECT
                    tca.course_id,
                    c.name AS course,
                    tca.amount_question,
                    tco.position
                FROM tbl_course_area tca
                LEFT JOIN tbl_course_ordering tco ON tca.course_id = tco.course_id
                INNER JOIN course c ON tca.course_id = c.id
            )
            SELECT
                tc.course_id::BIGINT,
                tc.course,
                tc.amount_question,
                tc.position,
                COALESCE(
                    SUM(tc.amount_question) OVER (
                        ORDER BY tc.position ASC, tc.course_id ASC
                        ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
                    ), 0
                ) + 1 AS initial
            FROM tbl_courses tc
            ORDER BY tc.position ASC, tc.course_id ASC;
        END;
        $$;


ALTER FUNCTION odiseo.fn_courses_order_and_amount(p_type_material_id smallint, p_area_id bigint, p_university_id smallint) OWNER TO postgres;

--
