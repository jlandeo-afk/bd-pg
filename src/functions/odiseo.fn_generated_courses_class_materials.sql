-- Function: odiseo.fn_generated_courses_class_materials(integer, integer, bigint, bigint, smallint, boolean, boolean)

--

CREATE FUNCTION odiseo.fn_generated_courses_class_materials(p_per_page integer, p_n_page integer, p_material_id bigint, p_type_material_id bigint, p_week smallint, p_solution boolean, p_quality boolean) RETURNS TABLE(id bigint, url_resource character varying, course_id smallint, course_name character varying, fl_course_active boolean, status_id smallint, status_name character varying, status_course character varying, total bigint, resource_name text)
    LANGUAGE plpgsql
    AS $$
                DECLARE offset_val INTEGER;
                BEGIN
                    offset_val := p_per_page * (p_n_page - 1);
                    RETURN QUERY
                    WITH courses AS (
                        SELECT
                          mcw.id AS id,
                          mcw.url_material_class url_resource,
                          mcw.course_id::SMALLINT course_id,
                          c.name course_name,
                          mcw.fl_course_active,
                          mcw.fl_process_status status_id,
                          CASE
                           WHEN mcw.fl_process_status = 2 THEN 'Por generar'::VARCHAR(15)
                           WHEN mcw.fl_process_status = 3 THEN 'Completado'::VARCHAR(15)
                           WHEN mcw.fl_process_status = 4 THEN 'Generando'::VARCHAR(15)
                           WHEN mcw.fl_process_status = 5 THEN 'Error'::VARCHAR(15)
                           ELSE 'DESCONOCIDO'::VARCHAR(15)
                          END AS status_name,
                          CASE
                            WHEN mcw.fl_course_active = TRUE THEN 'Activo'::VARCHAR(15)
                            ELSE 'Inactivo'::VARCHAR(15)
                          END AS status_course,
                          COUNT(*) OVER () AS total,
                          'Material de clases (' || tm.description || ' ) ' || c.name || ' - ' || w.description AS resource_name
                        FROM odiseo.material_class_week mcw
                        LEFT JOIN odiseo.course c ON c.id = mcw.course_id
                        LEFT JOIN odiseo.type_material tm ON tm.id = mcw.type_material_id
                        LEFT JOIN odiseo.week w ON w.id = mcw.week
                        WHERE 1 = 1
                          AND mcw.material_id = p_material_id
                          AND mcw.type_material_id = p_type_material_id
                          AND mcw.week = p_week
                          AND mcw.fl_status IS TRUE
                          AND mcw.deleted_at IS NULL
                        ORDER BY mcw.id
                    )
                    SELECT
                        *
                    FROM courses cs
                    LIMIT p_per_page
                    OFFSET offset_val;
                    END;
                $$;


ALTER FUNCTION odiseo.fn_generated_courses_class_materials(p_per_page integer, p_n_page integer, p_material_id bigint, p_type_material_id bigint, p_week smallint, p_solution boolean, p_quality boolean) OWNER TO postgres;

--
