-- Function: odiseo.fn_migrate_diagrammed_fields()

--

CREATE FUNCTION odiseo.fn_migrate_diagrammed_fields() RETURNS TABLE(question_id bigint, question_code character varying, employee_didi_question_id bigint, deactivated_field_id bigint, created_field_id bigint)
    LANGUAGE plpgsql
    AS $$
                    DECLARE
                        v_user_id INTEGER := 2; -- ID del usuario que realiza la migración
                    BEGIN
                        RETURN QUERY
                        WITH 
                        courses_apply_text AS (
                            SELECT c.id FROM course c WHERE c.apply_text 
                        ), 
                        active_employee_didi_question AS (
                            SELECT
                                edq.id AS id, q.course_id, pq.type_text_id AS category_id,
                                q.id as question_id, q.code as question_code
                            FROM employee_didi_question edq
                            JOIN question q ON q.id = edq.question_id JOIN parent_question pq ON pq.id = q.parent_id 
                            WHERE edq.fl_status IS TRUE AND q.course_id IN (SELECT * FROM courses_apply_text) AND pq.type_text_id IS NOT NULL
                        ),
                        fields_to_migrate AS (
                            SELECT 
                                edqf.id AS original_field_id,
                                edqf.employee_didi_question_id AS edq_id,
                                edqf.value,
                                (
                                    SELECT sdc.id 
                                    FROM setting_diagrammed_courses sdc 
                                    WHERE sdc.course_id = aedq.course_id AND sdc.category_text_id = aedq.category_id
                                    AND sdc.fl_status = true AND sdc.field_diagram_id = sdc1.field_diagram_id
                                    LIMIT 1
                                ) AS new_setting_diagrammed_course_id,
                                aedq.question_code,
                                aedq.question_id,
                                edqf.created_by,
                                edqf.updated_by,
                                edqf.migrated_updated_at,
                                edqf.math_migration_status,
                                edqf.fl_status
                            FROM active_employee_didi_question aedq
                            JOIN employee_didi_question_field edqf ON edqf.employee_didi_question_id = aedq.id
                            JOIN setting_diagrammed_courses sdc1 ON sdc1.id = edqf.setting_diagrammed_course_id 
                            WHERE edqf.fl_status = true
                            AND sdc1.category_text_id IS NULL
                        ),
                        valid_migrations AS (
                            SELECT * FROM fields_to_migrate WHERE new_setting_diagrammed_course_id IS NOT NULL
                        ),
                        updated_rows AS (
                            UPDATE employee_didi_question_field
                            SET 
                                fl_status = false,
                                deleted_at = NOW(),
                                deleted_by = v_user_id
                            WHERE id IN (SELECT original_field_id FROM valid_migrations)
                        ),
                        inserted_rows AS (
                            INSERT INTO employee_didi_question_field (
                                employee_didi_question_id, 
                                setting_diagrammed_course_id, 
                                value,
                                fl_status, 
                                created_at, 
                                created_by, 
                                updated_by,
                                migrated_updated_at,
                                math_migration_status
                            )
                            SELECT
                                vm.edq_id, 
                                vm.new_setting_diagrammed_course_id, 
                                vm.value,
                                vm.fl_status, 
                                NOW(), 
                                vm.created_by,
                                vm.updated_by,
                                vm.migrated_updated_at,
                                vm.math_migration_status
                            FROM valid_migrations vm
                            RETURNING id, employee_didi_question_field.employee_didi_question_id
                        )
                        SELECT
                            vm.question_id,
                            vm.question_code,
                            vm.edq_id AS employee_didi_question_id,
                            vm.original_field_id AS deactivated_field_id,
                            ir.id AS created_field_id
                        FROM valid_migrations vm
                        JOIN inserted_rows ir ON vm.edq_id = ir.employee_didi_question_id;

                    END;
                    $$;


ALTER FUNCTION odiseo.fn_migrate_diagrammed_fields() OWNER TO postgres;

--
