-- Function: exams.fn_get_course_and_exam_area(bigint)

--

CREATE FUNCTION exams.fn_get_course_and_exam_area(p_type_material_id bigint) RETURNS TABLE(course_id smallint, course_name character varying, apply_text boolean, exam_area jsonb, position_course smallint)
    LANGUAGE plpgsql
    AS $$
            BEGIN

                RETURN QUERY
                WITH course_ordering AS (
                SELECT DISTINCT
                    tmc.course_id,
                    tma.type_material_id,
                    course_ordering.position
                FROM type_material_area_courses tmac
                LEFT JOIN type_material_area tma ON tmac.type_material_area_id = tma.id
                LEFT JOIN type_material_course tmc ON tmac.type_material_course_id = tmc.id
                INNER JOIN type_material tm ON tma.type_material_id = tm.id
                LEFT JOIN (
                    SELECT
                        ttmco.course_id,
                        tm.id AS type_material_id,
                        tm.type_material_template_id,
                        ttmco.position
                    FROM template_type_material_courses_order ttmco
                    INNER JOIN type_material tm
                        ON tm.type_material_template_id = ttmco.template_type_material_id
                    WHERE ttmco.university_id IS NULL
                ) AS course_ordering
                    ON course_ordering.type_material_template_id = tm.type_material_template_id
                    AND course_ordering.course_id = tmc.course_id
                    WHERE tma.type_material_id = p_type_material_id
                    AND tmc.type_material_id = p_type_material_id
                    AND tmc.fl_status = TRUE AND tma.fl_status = TRUE
                ),
                configured_areas AS (
                    SELECT DISTINCT 
                        tma.area_id,
                        ea.description AS area_name
                    FROM type_material_area tma
                    JOIN exam_area ea ON ea.id = tma.area_id
                    WHERE tma.type_material_id = p_type_material_id
                    AND tma.fl_status = TRUE 
                    AND tma.deleted_at IS NULL
                    AND ea.fl_status = TRUE
                ),
                base_courses AS (
                    SELECT DISTINCT 
                        c.id, 
                        c.name,
                        c.apply_text
                    FROM type_material_course tmc
                    JOIN course c ON c.id = tmc.course_id
                    WHERE tmc.type_material_id = p_type_material_id 
                    AND tmc.fl_status = TRUE 
                    AND tmc.deleted_at IS NULL
                ),
                course_area_skeleton AS (
                    SELECT 
                        c.id AS course_id,
                        c.name AS course_name,
                        c.apply_text AS course_apply_text,
                        ca.area_id,
                        ca.area_name
                    FROM base_courses c
                    CROSS JOIN configured_areas ca
                ),
                questions_dataset AS (
                    SELECT 
                        cas.course_id,
                        cas.course_name,
                        FALSE AS apply_text,
                        cas.area_id,
                        cas.area_name,
                        COALESCE(MAX(tmc.amount_question), 0) AS total_amount
                    FROM course_area_skeleton cas
                    LEFT JOIN type_material_area tma 
                        ON tma.area_id = cas.area_id 
                        AND tma.type_material_id = p_type_material_id 
                        AND tma.fl_status = TRUE
                    LEFT JOIN type_material_area_courses tmac 
                        ON tmac.type_material_area_id = tma.id
                    LEFT JOIN type_material_course tmc 
                        ON tmc.id = tmac.type_material_course_id 
                        AND tmc.course_id = cas.course_id 
                        AND tmc.fl_status = TRUE
                    GROUP BY cas.course_id, cas.course_name, cas.area_id, cas.area_name
                ),
                texts_dataset AS (
                    SELECT 
                        cas.course_id,
                        cas.course_name,
                        TRUE AS apply_text,
                        cas.area_id,
                        cas.area_name,
                        COALESCE(MAX(
                            CASE 
                                WHEN ttmtca.type_material_id IS NOT NULL THEN tmc.amount_text
                                ELSE 0 
                            END
                        ), 0) AS total_amount
                    FROM course_area_skeleton cas
                    LEFT JOIN type_material_area tma 
                        ON tma.area_id = cas.area_id 
                        AND tma.type_material_id = p_type_material_id 
                        AND tma.fl_status = TRUE
                    LEFT JOIN type_material_area_courses tmac 
                        ON tmac.type_material_area_id = tma.id
                    LEFT JOIN type_material_course tmc 
                        ON tmc.id = tmac.type_material_course_id 
                        AND tmc.course_id = cas.course_id
                        AND tmc.fl_status = TRUE
                    LEFT JOIN type_text_material_type_course_area ttmtca 
                        ON ttmtca.type_material_id = p_type_material_id
                        AND ttmtca.course_id = cas.course_id
                        AND ttmtca.exam_area_id = cas.area_id
                        AND ttmtca.deleted_at IS NULL
                    WHERE cas.course_apply_text IS TRUE
                    GROUP BY cas.course_id, cas.course_name, cas.area_id, cas.area_name
                ),
                combined_data AS (
                    SELECT * FROM questions_dataset
                    UNION ALL
                    SELECT * FROM texts_dataset
                )
                SELECT
                    cd.course_id,
                    cd.course_name,
                    cd.apply_text,
                    jsonb_agg(
                        jsonb_build_object(
                            'exam_area_id', cd.area_id,
                            'exam_area_name', cd.area_name,
                            'total_question', cd.total_amount,
                            'levels', CASE 
                                WHEN cd.apply_text = FALSE THEN (
                                    SELECT jsonb_agg(
                                        jsonb_build_object(
                                            'id', l.id,
                                            'name', l.name,
                                            'description', l.description,
                                            'amount_question', 0
                                        ) ORDER BY l.description
                                    )
                                    FROM course_level cl
                                    JOIN level l ON cl.level_id = l.id
                                    WHERE cl.course_id = cd.course_id
                                        AND cl.fl_status = TRUE AND l.deleted_at IS NULL AND l.fl_status = TRUE
                                )
                                ELSE (
                                    SELECT jsonb_agg(
                                        jsonb_build_object(
                                            'id', tl.id,
                                            'name', tl.level,
                                            'description', tl.description,
                                            'amount_question', 0
                                        ) ORDER BY tl.description
                                    ) 
                                    FROM type_text_level tl
                                    WHERE tl.deleted_at IS NULL
                                )
                            END
                        ) ORDER BY cd.area_name
                    ) AS exam_area,
                    MAX(co.position) AS position_course
                FROM combined_data cd
                LEFT JOIN course_ordering co ON cd.course_id = co.course_id
                GROUP BY 
                    cd.course_id, 
                    cd.course_name, 
                    cd.apply_text
                ORDER BY 
                    MAX(co.position) ASC, 
                    UNACCENT(cd.course_name) ASC, 
                    cd.apply_text;
            END;
            $$;


ALTER FUNCTION exams.fn_get_course_and_exam_area(p_type_material_id bigint) OWNER TO postgres;

--
