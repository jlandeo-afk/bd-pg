-- Function: odiseo.fn_get_course_materials_by_type(smallint, boolean, jsonb)

--

CREATE FUNCTION odiseo.fn_get_course_materials_by_type(p_type_material_id smallint, p_is_text boolean, p_courses jsonb DEFAULT NULL::jsonb) RETURNS TABLE(configured_amount integer, type_material_id smallint, course_id smallint, course_name character varying, type_material_name character varying)
    LANGUAGE sql STABLE
    AS $$
        SELECT
            CASE
                WHEN p_is_text = TRUE THEN tmc.amount_text
                ELSE tmc.amount_question
            END AS configured_amount,
            tmc.type_material_id,
            c.id AS course_id,
            c.name AS course_name,
            tm.description AS type_material_name
        FROM type_material_course AS tmc
        INNER JOIN course AS c ON tmc.course_id = c.id
        INNER JOIN type_material AS tm ON tm.id = tmc.type_material_id
        WHERE
            tmc.type_material_id = p_type_material_id
            AND (p_is_text IS FALSE OR tmc.amount_text > 0)
            AND (
                p_courses IS NULL
                OR c.id IN (
                    SELECT value::BIGINT
                    FROM jsonb_array_elements_text(p_courses)
                )
            );
    $$;


ALTER FUNCTION odiseo.fn_get_course_materials_by_type(p_type_material_id smallint, p_is_text boolean, p_courses jsonb) OWNER TO postgres;

--
