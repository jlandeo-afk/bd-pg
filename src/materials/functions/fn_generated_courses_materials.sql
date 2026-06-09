-- Function: materials.fn_generated_courses_materials(integer, integer, bigint, bigint, smallint, boolean, boolean)

--

CREATE FUNCTION materials.fn_generated_courses_materials(p_per_page integer, p_n_page integer, p_material_id bigint, p_type_material_id bigint, p_week smallint, p_solution boolean, p_quality boolean) RETURNS TABLE(id bigint, url_resource character varying, course_id smallint, course_name character varying, status_id smallint, status_name character varying, status_course character varying, total bigint, resource_name text)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            offset_val INTEGER;
        BEGIN
            offset_val := p_per_page * (p_n_page - 1);
            RETURN QUERY

            WITH courses AS (
                SELECT
                    smw.id AS id,
                    smw.url_material url_resource,
                    smw.course_id::SMALLINT course_id,
                    c.name course_name,
                    smw.fl_process_status status_id,
                    CASE
                        WHEN smw.fl_process_status = 2 THEN 'Por generar'::VARCHAR(15)
                        WHEN smw.fl_process_status = 3 THEN 'Completado'::VARCHAR(15)
                        WHEN smw.fl_process_status = 4 THEN 'Generando'::VARCHAR(15)
                        WHEN smw.fl_process_status = 5 THEN 'Error'::VARCHAR(15)
                    ELSE 'Desconocido'::VARCHAR(15)
                    END AS status_name,
                    CASE
                        WHEN smw.fl_course_active = TRUE THEN 'Activo'::VARCHAR(15)
                        ELSE 'Inactivo'::VARCHAR(15)
                    END AS status_course,
                    COUNT(*) OVER () AS total,
                    tm.description || ' - ' ||
                    c.name || ' - ' ||
                    w.description || ' - ' ||
                    CASE
                        WHEN smw.fl_solution THEN 'Con solución'
                    ELSE 'Sin solución'
                    END || ' - ' ||
                    CASE
                        WHEN smw.fl_quality THEN 'Revisión'
                    ELSE 'Oficial'
                    END AS resource_name
                FROM separated_material_week smw
                LEFT JOIN course c ON c.id = smw.course_id
                LEFT JOIN type_material tm ON tm.id = smw.type_material_id
                LEFT JOIN week w ON w.id = smw.week
                WHERE 1 = 1
                    AND smw.material_id = p_material_id
                    AND smw.type_material_id = p_type_material_id
                    AND smw.week = p_week
                    AND smw.fl_status IS TRUE
                    AND smw.fl_solution = p_solution
                    AND smw.fl_quality = p_quality
                ORDER BY smw.id
            )
            SELECT
                *
            FROM courses cs
            LIMIT p_per_page
            OFFSET offset_val;
        END;
        $$;


ALTER FUNCTION materials.fn_generated_courses_materials(p_per_page integer, p_n_page integer, p_material_id bigint, p_type_material_id bigint, p_week smallint, p_solution boolean, p_quality boolean) OWNER TO postgres;

--
