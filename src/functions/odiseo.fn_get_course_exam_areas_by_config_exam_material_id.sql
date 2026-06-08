-- Function: odiseo.fn_get_course_exam_areas_by_config_exam_material_id(bigint, bigint)

--

CREATE FUNCTION odiseo.fn_get_course_exam_areas_by_config_exam_material_id(p_exam_material_config_id bigint, p_company_id bigint) RETURNS TABLE(course_id smallint, course_name character varying, apply_text boolean, exam_area jsonb, position_course smallint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH course_ordering AS (
        SELECT DISTINCT
            emc.type_material_id,
            tmc.course_id,
            course_ordering.position
        FROM exam_material_configurations emc
        LEFT JOIN type_material_course tmc ON emc.type_material_id = tmc.type_material_id
        INNER JOIN type_material tm ON emc.type_material_id = tm.id
        LEFT JOIN (
            SELECT
                ttmco.course_id,
                tm.id AS type_material_id,
                tm.type_material_template_id,
                ttmco.position,
                ttmco.university_id
            FROM template_type_material_courses_order ttmco
            INNER JOIN type_material tm
                ON tm.type_material_template_id = ttmco.template_type_material_id
            WHERE ttmco.university_id IS NULL
        ) AS course_ordering
            ON course_ordering.type_material_template_id = tm.type_material_template_id
            AND course_ordering.course_id = tmc.course_id
        WHERE emc.id =  p_exam_material_config_id
        AND emc.company_id = p_company_id
    ), get_type_material AS (
        SELECT
            DISTINCT type_material_id
        FROM course_ordering
    ), tbl_exam_material_configurations_level AS (
        SELECT
            emcac.course_id,
            emcac.exam_area_id,
            emcacl.level_id,
            emcacl.amount_question,
            emcacl.id config_id,
            emcac.amount_type_d
        FROM exam_material_configurations emc
        LEFT JOIN exam_material_config_area_courses emcac ON emcac.exam_material_config_id = emc.id
        LEFT JOIN exam_material_config_area_course_levels emcacl
            ON emcac.id = emcacl.exam_material_config_area_course_id AND emcacl.fl_status = true
        WHERE emc.id = p_exam_material_config_id
    ), type_text_levels AS (
            SELECT
                id,
                level AS name,
                description,
                0 AS amount_text
            FROM type_text_level WHERE deleted_at IS NULL
    ), type_material_area_with_courses AS (
        SELECT
            c.id AS course_id,
            c.name AS course_name,
            tma.area_id AS area_id,
            tma.type_material_id AS type_material_id
        FROM course c
        CROSS JOIN type_material_area tma
        WHERE 1 = 1
        AND c.apply_text IS TRUE
        AND tma.deleted_at IS NULL
        AND tma.fl_status IS TRUE
        AND tma.type_material_id IN ( SELECT we.type_material_id FROM get_type_material we )
    ), type_material_area_and_courses AS (
        SELECT
            tmc.course_id,
            tma.area_id,
            tmc.amount_question,
            tmc.amount_text
        FROM type_material_area_courses tmac
        LEFT JOIN type_material_course tmc ON tmac.type_material_course_id = tmc.id AND tmc.fl_status IS TRUE
        LEFT JOIN type_material_area tma ON tmac.type_material_area_id = tma.id
        JOIN course c ON c.id = tmc.course_id
        WHERE 1 = 1
        AND c.apply_text IS TRUE
        AND tmc.type_material_id IN ( SELECT gg.type_material_id FROM get_type_material gg )
    ), ultimate_type_material_area_courses AS (
        SELECT
            taw.course_id,
            taw.course_name,
            taw.area_id,
            COALESCE(tyc.amount_question, 0) AS amount_question,
            COALESCE(tyc.amount_text, 0) AS amount_text
        FROM type_material_area_with_courses taw
        LEFT JOIN type_material_area_and_courses tyc ON taw.area_id = tyc.area_id AND taw.course_id = tyc.course_id
    ), type_text_exam_course AS (
        SELECT
            ut.course_id,
            ut.course_name,
            TRUE AS apply_text,
            JSONB_AGG(
                JSONB_BUILD_OBJECT(
                    'exam_area_id', ut.area_id,
                    'exam_area_name', ea.description,
                    'total_question', ut.amount_text, -- Esta es la cantidad de textos
                    'levels', ( SELECT JSONB_AGG(
                        JSON_BUILD_OBJECT(
                            'id', tl.id,
                            'name', tl.name,
                            'description', tl.description,
                            'amount_question',
                                CASE
                                    WHEN ut.amount_text = 0 OR ut.amount_text IS NULL THEN 0
                                    WHEN emc.text_amount IS NULL THEN 0 
                                    ELSE emc.text_amount
                                END -- <-- Evita traer montos mayores a cero en niveles individuales cuando el monto total fue desactivado desde tipo de material
                        ) ORDER BY tl.description )
                        FROM type_text_levels tl
                        LEFT JOIN type_text_exam_material_configuration emc
                        ON 1 = 1
                        AND emc.exam_material_config_id = p_exam_material_config_id
                        AND emc.course_id = ut.course_id
                        AND emc.area_id = ut.area_id
                        AND emc.type_text_level_id = tl.id
                    )
                ) ORDER BY ea.description
            ) AS exam_area
        FROM ultimate_type_material_area_courses ut
        JOIN exam_area ea ON ea.id = ut.area_id
        GROUP BY ut.course_id, ut.course_name
    ), exam_course AS (
        SELECT
            c.id AS course_id,
            c.name AS course_name,
            FALSE AS apply_text,
            jsonb_agg(
                jsonb_build_object(
                    'exam_area_id', ea.id,
                    'exam_area_name', ea.description,
                    'amount_type_d', (
                        SELECT COALESCE((
                            SELECT emcac.amount_type_d
                            FROM exam_material_configurations emc
                            INNER JOIN exam_material_config_area_courses emcac ON emc.id = emcac.exam_material_config_id
                            WHERE emc.id = p_exam_material_config_id
                                AND emcac.exam_area_id = ea.id
                                AND emcac.fl_status = true
                                AND emcac.course_id = c.id
                            LIMIT 1
                        ), NULL::INT)
                    ),
                    'total_question', (
                        SELECT COALESCE((
                            SELECT tmc.amount_question
                            FROM type_material_area_courses tmac
                            LEFT JOIN type_material_area tma ON tmac.type_material_area_id = tma.id
                            LEFT JOIN type_material_course tmc ON tmac.type_material_course_id = tmc.id
                            LEFT JOIN exam_material_configurations emc ON emc.type_material_id = tma.type_material_id
                            WHERE emc.id = p_exam_material_config_id
                                AND tma.area_id = ea.id
                                AND tmc.course_id = c.id
                                AND tma.fl_status = TRUE
                                AND tmc.fl_status = TRUE
                                AND tmac.fl_status = TRUE
                                AND emc.fl_status = TRUE
                        ), 0)
                    ),
                    'levels', (
                        SELECT jsonb_agg(
                            jsonb_build_object(
                                'id', l.id,
                                'name', l.name,
                                'description', l.description,
                                'amount_question', COALESCE(emcacl.amount_question, 0),
                                'config_id', emcacl.config_id
                            ) ORDER BY l.description
                        )
                        FROM course_level cl
                        LEFT JOIN level l ON cl.level_id = l.id
                        LEFT JOIN tbl_exam_material_configurations_level emcacl ON emcacl.course_id = c.id
                            AND emcacl.level_id = l.id
                            AND emcacl.exam_area_id = ea.id
                        WHERE cl.course_id = c.id
                            AND cl.fl_status = TRUE
                            AND l.fl_status = TRUE
                    )
                ) ORDER BY ea.description
            ) AS exam_area
        FROM course c
        CROSS JOIN exam_area ea
        JOIN type_material_area tma ON tma.type_material_id IN ( SELECT type_material_id FROM get_type_material ) AND tma.area_id = ea.id AND tma.fl_status IS TRUE -- <-- Traer solo las areas activas en tipo de material
        WHERE ea.fl_status = TRUE
            AND ea.deleted_at IS NULL
            AND c.deleted_at IS NULL
            AND c.fl_status = TRUE
        GROUP BY
            c.id, c.name
    ), merge_text_amounts_and_question_amounts AS (
        SELECT * FROM type_text_exam_course
        UNION ALL
        SELECT * FROM exam_course
    ) SELECT
        ccem.*,
        co.position AS position_course
    FROM merge_text_amounts_and_question_amounts ccem
    LEFT JOIN course_ordering co ON ccem.course_id = co.course_id
    ORDER BY co.position ASC, UNACCENT(ccem.course_name) ASC, ccem.apply_text;
END;
$$;


ALTER FUNCTION odiseo.fn_get_course_exam_areas_by_config_exam_material_id(p_exam_material_config_id bigint, p_company_id bigint) OWNER TO postgres;

--
