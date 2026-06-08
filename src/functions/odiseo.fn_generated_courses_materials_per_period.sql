-- Function: odiseo.fn_generated_courses_materials_per_period(integer, character varying, boolean, integer)

--

CREATE FUNCTION odiseo.fn_generated_courses_materials_per_period(p_material_per_period_ballot_id integer, p_type character varying, p_has_permission_generar_por_cursos_asignados boolean, p_employee_id integer) RETURNS TABLE(id bigint, url_resource character varying, course_id smallint, course character varying, status_name text, resource_name text)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            SELECT
                mppc.id,
                mppc.url AS url_resource,
                c.id AS course_id,
                c.name AS course,
                CASE mppc.job_status
                    WHEN 'unprocessed' THEN 'Sin procesar'
                    WHEN 'pending'     THEN 'Por generar'
                    WHEN 'processing'  THEN 'Generando'
                    WHEN 'completed'   THEN 'Completado'
                    WHEN 'failed'      THEN 'Error'
                    WHEN 'canceled'    THEN 'Cancelado'
                    ELSE 'Desconocido'
                END AS status_name,
                CONCAT_WS(' - ',
                    tm.description,
                    c.name,
                    'Semana (' || mppb.start_week || ' - ' || mppb.end_week || ')',
                    CASE mppc.type
                        WHEN 'solution'              THEN 'Con solución - Oficial'
                        WHEN 'without_solution'      THEN 'Sin solución - Oficial'
                        WHEN 'review_solution'       THEN 'Con solución - Revisión'
                        WHEN 'review_without_solution' THEN 'Sin solución - Revisión'
                    END
                ) AS resource_name
            FROM material_per_period_course mppc
            JOIN material_per_period_ballot mppb ON mppb.id = mppc.material_per_period_ballot_id
            JOIN material_per_period mpp ON mpp.id = mppb.material_per_period_id
            JOIN type_material tm ON tm.id = mpp.type_material_id
            JOIN course c ON c.id = mppc.course_id
            LEFT JOIN template_type_material_courses_order ttmco
                ON ttmco.course_id = c.id
                AND ttmco.template_type_material_id = tm.type_material_template_id
                AND ttmco.university_id IS NULL
            WHERE mppc.material_per_period_ballot_id = p_material_per_period_ballot_id
            AND mppc.type = p_type
            AND mppc.deleted_at IS NULL
            AND (
                NOT COALESCE(p_has_permission_generar_por_cursos_asignados, FALSE)
                OR EXISTS (
                    SELECT 1
                    FROM employee_course ec
                    WHERE ec.course_id = mppc.course_id
                    AND ec.teacher_id = p_employee_id
                    AND ec.fl_status = TRUE
                )
            )
            ORDER BY ttmco.position NULLS LAST;
        END;
        $$;


ALTER FUNCTION odiseo.fn_generated_courses_materials_per_period(p_material_per_period_ballot_id integer, p_type character varying, p_has_permission_generar_por_cursos_asignados boolean, p_employee_id integer) OWNER TO postgres;

--
