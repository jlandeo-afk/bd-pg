-- Function: academic.fn_get_amount_levels_required_per_text(bigint, smallint, smallint)

--

CREATE FUNCTION academic.fn_get_amount_levels_required_per_text(p_type_material_id bigint, p_course_id smallint, p_area_id smallint) RETURNS TABLE(course_id bigint, area_id smallint, level smallint, amount smallint)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    tte.course_id,
                    tte.area_id,
                    ttl.level AS level_id,
                    tte.text_amount AS amount
                FROM type_text_exam_material_configuration tte
                JOIN course c ON c.id = tte.course_id AND c.apply_text IS TRUE
                JOIN exam_material_configurations emc 
                ON 1 = 1
                AND emc.id = tte.exam_material_config_id
                AND emc.type_material_id = p_type_material_id
                JOIN type_text_level ttl ON ttl.id = tte.type_text_level_id
                WHERE 1 = 1
                AND ( p_course_id IS NULL OR tte.course_id = p_course_id )
                AND ( p_area_id IS NULL OR tte.area_id = p_area_id )
                AND tte.deleted_at IS NULL
                AND emc.deleted_at IS NULL
                AND EXISTS(
                    SELECT 1
                    FROM type_text_material_type_course_area ty
                    WHERE 1 = 1
                    AND ty.type_material_id = emc.type_material_id
                    AND ty.course_id = tte.course_id
                    AND ty.exam_area_id = tte.area_id
                    AND ty.deleted_at IS NULL
                )
                ORDER BY tte.course_id, tte.area_id ASC;
            END;
            $$;


ALTER FUNCTION academic.fn_get_amount_levels_required_per_text(p_type_material_id bigint, p_course_id smallint, p_area_id smallint) OWNER TO postgres;

--
