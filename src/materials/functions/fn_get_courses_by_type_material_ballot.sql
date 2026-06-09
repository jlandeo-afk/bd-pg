-- Function: materials.fn_get_courses_by_type_material_ballot(smallint, bigint, bigint)

--

CREATE FUNCTION materials.fn_get_courses_by_type_material_ballot(p_type_material_id smallint, p_company_id bigint, p_user_id bigint) RETURNS TABLE(id smallint, code_course character varying, course character varying)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                WITH tbl_type_material_template AS (
                    SELECT
                        tmt.type_material_template_id
                    FROM type_material tmt
                    WHERE tmt.id = p_type_material_id
                        AND tmt.company_id = p_company_id
                ), child_type_materials AS (
                    SELECT
                        tm.id
                    FROM type_material tm
                    WHERE tm.parent_id = p_type_material_id
                        AND tm.company_id = p_company_id
                ), get_type_material AS (
                    SELECT
                        ctm.id
                    FROM child_type_materials ctm

                    UNION ALL

                    SELECT tm.id
                    FROM type_material tm
                    WHERE tm.id = p_type_material_id
                        AND tm.company_id = p_company_id
                    AND NOT EXISTS (SELECT 1 FROM child_type_materials)
                ), get_courses AS (
                    -- cursos genericos
                    SELECT DISTINCT tmc.course_id
                    FROM materials.type_material_course tmc
                    WHERE tmc.type_material_id IN (SELECT gtm.id FROM get_type_material gtm)
                    AND tmc.is_generic IS TRUE
                    AND tmc.amount_question > 0
                    AND tmc.fl_status = TRUE

                    UNION ALL

                    -- cursos texto genericos
                    SELECT DISTINCT tmc.course_id
                    FROM materials.type_material_course tmc
                    WHERE tmc.type_material_id IN (SELECT gtm.id FROM get_type_material gtm)
                    AND tmc.is_generic_text IS TRUE
                    AND tmc.amount_text > 0
                    AND tmc.fl_status = TRUE

                    UNION ALL

                    -- cursos personalizados
                    SELECT DISTINCT tmdc.course_id
                    FROM materials.type_material_detail_courses tmdc
                    JOIN type_material_detail_template tmdt
                        ON tmdc.type_material_detail_template_id = tmdt.id
                    JOIN type_material_course tmc
                        ON tmdc.type_material_course_id = tmc.id
                    WHERE tmc.type_material_id IN (SELECT gtm.id FROM get_type_material gtm)
                    AND tmc.is_generic IS FALSE
                    AND tmdc.amount_question > 0
                    AND tmdc.fl_status = TRUE

                    UNION ALL

                    -- cursos textos personalizados
                    SELECT DISTINCT tmdct.course_id
                    FROM materials.type_material_detail_course_texts tmdct
                    JOIN type_material_detail_template tmdt
                        ON tmdct.type_material_detail_template_id = tmdt.id
                    JOIN type_material_course tmc
                        ON tmdct.type_material_course_id = tmc.id
                    WHERE tmc.type_material_id IN (SELECT gtm.id FROM get_type_material gtm)
                    AND tmc.is_generic_text IS FALSE
                    AND tmdct.amount_text > 0
                    AND tmdct.fl_status = TRUE
                ), get_courses_final AS (
                    SELECT DISTINCT
                        gc.course_id::SMALLINT AS id,
                        c.code AS code_course,
                        c.name AS course
                    FROM get_courses gc
                    JOIN course c ON gc.course_id = c.id
                ), validate_admin_user AS (
                    SELECT
                        u.id,
                        r.fl_administrator,
                        rp.permission_id
                    FROM users u
                    JOIN users_roles ur ON u.id = ur.user_id
                    JOIN roles r ON ur.rol_id = r.id
                    LEFT JOIN roles_permissions rp ON r.id = rp.rol_id
                        AND rp.permission_id = 133 -- 'admin.admin'
                    WHERE u.id = p_user_id
                ), get_courses_employees AS (
                    SELECT DISTINCT
                        ec.course_id
                    FROM employees e
                    JOIN employee_course ec ON e.id = ec.teacher_id
                    WHERE e.user_id = p_user_id
                        AND ec.fl_status = true
                        AND NOT EXISTS (
                            SELECT 1
                            FROM validate_admin_user vau
                            WHERE vau.permission_id = 133
                        )

                    UNION ALL

                    SELECT
                        c.id
                    FROM course c
                    WHERE c.fl_status = true
                    AND EXISTS (
                            SELECT 1
                            FROM validate_admin_user vau
                            WHERE vau.permission_id = 133
                        )
                )
                SELECT
                    gcf.id,
                    gcf.code_course,
                    gcf.course
                FROM get_courses_final gcf
                WHERE gcf.id IN (
                    SELECT
                        gce.course_id
                    FROM get_courses_employees gce
                )
                ORDER BY
                    gcf.code_course,
                    gcf.course;
            END;
            $$;


ALTER FUNCTION materials.fn_get_courses_by_type_material_ballot(p_type_material_id smallint, p_company_id bigint, p_user_id bigint) OWNER TO postgres;

--
