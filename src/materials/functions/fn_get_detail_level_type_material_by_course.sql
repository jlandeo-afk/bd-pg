-- Function: materials.fn_get_detail_level_type_material_by_course(integer, integer, integer)

--

CREATE FUNCTION materials.fn_get_detail_level_type_material_by_course(p_course_id integer, p_cycle_id integer, p_week integer) RETURNS TABLE(course_id smallint, course character varying, level_course jsonb, material_course jsonb)
    LANGUAGE plpgsql
    AS $$
                    DECLARE
                    BEGIN

                        RETURN QUERY
                        SELECT
                            c.id as course_id,
                            c.name as course,
                            jsonb_agg(
                                DISTINCT jsonb_build_object(
                                    'level_id', tbl_level.level_id,
                                    'level', tbl_level.level
                                )
                            ) AS level_course,
                            (
                                SELECT jsonb_agg(
                                jsonb_build_object(
                                    'type_material_id', tbl_type_material.type_material_id,
                                    'type_material', tbl_type_material.type_material,
                                    'amount_question', tbl_type_material.amount_question
                                    )
                                )   FROM fn_get_course_material_details(p_course_id::smallint, p_week, p_cycle_id) tbl_type_material
                            )	 AS material_course
                        FROM course c
                        INNER JOIN
                        (
                            SELECT DISTINCT
                                l.id AS level_id,
                                l.description AS level,
                                cl.course_id AS course_id
                            FROM course_level cl
                            LEFT JOIN "level" l ON cl.level_id = l.id
                            LEFT JOIN course c ON cl.course_id = c.id
                            WHERE
                                cl.fl_status = TRUE
                                AND cl.deleted_at IS NULL
                                AND c.fl_status = TRUE
                                AND l.fl_status = TRUE
                        ) AS tbl_level ON tbl_level.course_id = c.id
                        WHERE
                            c.id = p_course_id
                            AND c.fl_status = TRUE
                        GROUP BY c.id;
                    END;
                    $$;


ALTER FUNCTION materials.fn_get_detail_level_type_material_by_course(p_course_id integer, p_cycle_id integer, p_week integer) OWNER TO postgres;

--
