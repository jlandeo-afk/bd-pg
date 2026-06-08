-- Function: odiseo.fn_get_courses_by_type_material(smallint)

--

CREATE FUNCTION odiseo.fn_get_courses_by_type_material(p_type_material_id smallint) RETURNS TABLE(course_id bigint, course_name character varying)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                -- 1. Verificamos si existe una configuración de ordenamiento personalizada
                IF EXISTS (
                    SELECT 1
                    FROM template_type_material_courses_order ttmco
                    JOIN type_material_template tmt ON ttmco.template_type_material_id = tmt.id
                    JOIN type_material tm ON tm.type_material_template_id = tmt.id
                    WHERE tm.id = p_type_material_id
                ) THEN
                    -- CASO A: Retornar cursos ordenados por la plantilla
                    RETURN QUERY
                    SELECT
                        c.id::BIGINT,
                        c.name::varchar
                    FROM template_type_material_courses_order ttmco
                    JOIN course c ON c.id = ttmco.course_id
                    JOIN type_material_template tmt ON ttmco.template_type_material_id = tmt.id
                    JOIN type_material tm ON tm.type_material_template_id = tmt.id
                    WHERE tm.id = p_type_material_id
                    AND ttmco.university_id IS NULL
                    ORDER BY ttmco.position ASC, c.id ASC;
                ELSE
                    -- Validar si el tipo material es padre
                    RETURN QUERY
                    WITH type_materials AS (
                        SELECT
                            CASE WHEN EXISTS (
                                SELECT 1 FROM type_material tm
                                WHERE tm.parent_id = p_type_material_id) THEN
                                ARRAY (
                                    SELECT tm.id FROM type_material tm WHERE tm.parent_id = p_type_material_id
                                )
                            ELSE
                                ARRAY[p_type_material_id]
                            END AS ids
                    ), type_material_ids AS (
                        SELECT UNNEST(tm.ids) AS id FROM type_materials tm
                    ), get_courses AS (
                        SELECT DISTINCT
                            c.id::BIGINT,
                            c.name::varchar
                        FROM type_material_course tmc
                        JOIN course c ON c.id = tmc.course_id
                        WHERE tmc.type_material_id IN (SELECT tmi.id FROM type_material_ids tmi)
                    )
                    SELECT * FROM get_courses ORDER BY id ASC;
                END IF;

            END;
            $$;


ALTER FUNCTION odiseo.fn_get_courses_by_type_material(p_type_material_id smallint) OWNER TO postgres;

--
