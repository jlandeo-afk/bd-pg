-- Function: odiseo.update_data_employee(uuid, bigint, character varying, character varying, character varying, integer, character varying, character varying, character varying, jsonb, integer, jsonb)

--

CREATE FUNCTION odiseo.update_data_employee(p_uuid uuid, p_charge_id bigint, p_first_name character varying, p_first_surname character varying, p_second_surname character varying, p_type_document_id integer, p_document character varying, p_email character varying, p_phone character varying, p_course_ids jsonb, p_updated_by integer, p_data_docente jsonb) RETURNS TABLE(v_id_employee bigint, v_question_ids integer[])
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_id_employee BIGINT;
                v_charge_id BIGINT;
                v_course_id BIGINT;
                v_new_course_ids BIGINT[];
                v_existing_course_ids BIGINT[];
                v_limit_assigned_questions INTEGER;
                v_courses_delete BIGINT[];
                v_question_ids INT[];
            BEGIN

               v_limit_assigned_questions := (p_data_docente->>'goal')::smallint + ((p_data_docente->>'goal')::smallint)/2;

                -- Obtener ID del empleado y ID del cargo
                SELECT id, charge_id
                INTO v_id_employee, v_charge_id
                FROM employees e
                WHERE e.uuid = p_uuid;

                UPDATE employees
                SET charge_id = p_charge_id,
                    first_name = p_first_name,
                    first_surname = p_first_surname,
                    second_surname = p_second_surname,
                    type_document_id = p_type_document_id,
                    document = p_document,
                    email = p_email,
                    phone = p_phone,
                    updated_by = p_updated_by,
                    updated_at = NOW(),
                    code = p_data_docente->>'code',
                    limit_assigned_questions = v_limit_assigned_questions,
                    fl_unlimit_questions = (p_data_docente->>'fl_unlimit_questions')::BOOLEAN,
                    goal  = (p_data_docente->>'goal')::smallint,
                    level_id = (p_data_docente->>'level')::smallint,
                    lot = (p_data_docente->>'lot')::smallint,
                    fl_resolve_missing_questions = (p_data_docente->>'fl_resolve_missing_questions')::BOOLEAN,
                    limit_missing_questions = (p_data_docente->>'missing_questions_lot')::smallint
                WHERE uuid = p_uuid;

                v_new_course_ids := ARRAY(SELECT jsonb_array_elements_text(p_course_ids)::bigint);

                -- Eliminar los curso que no encuentra
                UPDATE employee_course
                SET fl_status = false, deleted_by = p_updated_by, deleted_at = now()
                WHERE teacher_id = v_id_employee
                AND course_id NOT IN (SELECT unnest(v_new_course_ids));

                -- Consultar los IDs existentes en employee_course
                v_existing_course_ids := ARRAY(
                    SELECT course_id
                    FROM employee_course
                    WHERE course_id = ANY(v_new_course_ids)
                    AND teacher_id = v_id_employee
                    AND fl_status = true
                );

                -- Eliminar los IDs existentes de la lista de nuevos IDs
                v_new_course_ids := ARRAY(
                    SELECT unnest(v_new_course_ids)
                    EXCEPT
                    SELECT unnest(v_existing_course_ids)
                );

                -- Insertar los nuevos IDs que no están en la tabla
                FOREACH v_course_id IN ARRAY v_new_course_ids
                LOOP
                    INSERT INTO employee_course (teacher_id, course_id, created_by, created_at)
                    VALUES (v_id_employee, v_course_id, p_updated_by, now());
                END LOOP;

                SELECT array_agg(ec.course_id)
                INTO v_courses_delete
                FROM employee_course ec
                WHERE ec.teacher_id = v_id_employee
                AND ec.fl_status = false;

                IF array_length(v_courses_delete, 1) IS NOT NULL THEN
                    SELECT array_agg(eq.question_id)
                    INTO v_question_ids
                    FROM employee_question eq
                    INNER JOIN question q ON eq.question_id = q.id
                    WHERE eq.teacher_id = v_id_employee
                    AND q.status IN ('ASIG', 'RESO')
                    AND q.course_id = ANY(v_courses_delete)
                    AND eq.fl_status = true
                    AND q.fl_status = true;

                    IF array_length(v_question_ids, 1) IS NOT NULL THEN
                        UPDATE employee_question
                        SET fl_status = false, deleted_by = 1, deleted_at = now()
                        WHERE question_id = ANY(v_question_ids)
                        AND teacher_id = v_id_employee;

                        UPDATE question
                        SET status = 'SASI', updated_by = p_updated_by, updated_at = now()
                        WHERE id = ANY(v_question_ids)
                        AND fl_status = true;
                    END IF;
                END IF;

                -- Devolver el ID del empleado
                RETURN QUERY
                SELECT v_id_employee, v_question_ids;
            END;
            $$;


ALTER FUNCTION odiseo.update_data_employee(p_uuid uuid, p_charge_id bigint, p_first_name character varying, p_first_surname character varying, p_second_surname character varying, p_type_document_id integer, p_document character varying, p_email character varying, p_phone character varying, p_course_ids jsonb, p_updated_by integer, p_data_docente jsonb) OWNER TO postgres;

--
