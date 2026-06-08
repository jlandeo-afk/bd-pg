-- Function: odiseo.fn_courses_complete_management(boolean, bigint)

--

CREATE FUNCTION odiseo.fn_courses_complete_management(p_fl_pseudo_course boolean, p_employee_id bigint) RETURNS TABLE(course_id smallint, code character varying, name character varying, area_id bigint, count_questions bigint, fl_pseudo_course boolean, children jsonb, type_text_template_id smallint)
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    RETURN QUERY
                    WITH tbl_question_veri AS (
                        SELECT
                            q.course_id,
                            count(q.id) AS count_questions
                        FROM question q
                        WHERE q.status IN ('VERI', 'APRB') AND q.fl_status
                        GROUP BY q.course_id
                    ), 
                    tbl_children_courses AS (
                        SELECT
                            cpc.course_id,
                            cpc.pseudo_course_id,
                            ch.code,
                            ch.name,
                            ch.area_id
                        FROM course_pseudo_courses cpc
                        INNER JOIN course ch ON ch.id = cpc.course_id
                        WHERE cpc.fl_status IS TRUE
                        AND ch.fl_status IS TRUE
                    ), 
                    courses_assigned AS (
                        SELECT DISTINCT ec.course_id
                        FROM employee_course ec
                        WHERE ec.fl_status = true
                        AND (p_employee_id IS NULL OR ec.teacher_id = p_employee_id) 
                    ),
                    tbl_children_json AS (
                        SELECT
                            tcc.pseudo_course_id,
                            jsonb_agg(
                                jsonb_build_object(
                                    'id', tcc.course_id,
                                    'code', tcc.code,
                                    'name', tcc.name,
                                    'area_id', tcc.area_id,
                                    'count_questions', COALESCE(tqvs.count_questions, 0)
                                )
                            ) as children_json
                        FROM tbl_children_courses tcc
                        LEFT JOIN tbl_question_veri tqvs ON tqvs.course_id = tcc.course_id
                        GROUP BY tcc.pseudo_course_id
                    )
                    SELECT
                        c.id AS course_id,
                        c.code,
                        c.name,
                        c.area_id,
                        COALESCE(tqv.count_questions, 0) AS count_questions,
                        c.fl_pseudo_course,
                        COALESCE(tcj.children_json, '[]'::jsonb) as children,
                        c.type_text_template_id
                    FROM course c
                    LEFT JOIN tbl_question_veri tqv ON tqv.course_id = c.id
                    LEFT JOIN tbl_children_json tcj ON tcj.pseudo_course_id = c.id
                    LEFT JOIN type_text_templates ttt on ttt.id = c.type_text_template_id
                    WHERE c.fl_status IS TRUE
                    AND (p_employee_id IS NULL OR c.id IN (SELECT ca.course_id FROM courses_assigned ca))
                    AND (p_fl_pseudo_course IS NULL OR c.fl_pseudo_course = p_fl_pseudo_course)
                    ORDER BY c.id ASC;
                END;
                $$;


ALTER FUNCTION odiseo.fn_courses_complete_management(p_fl_pseudo_course boolean, p_employee_id bigint) OWNER TO postgres;

--
