-- Function: organization.fn_create_employee(uuid, bigint, character varying, character varying, character varying, integer, character varying, character varying, character varying, jsonb, integer, jsonb, integer, integer)

--

CREATE FUNCTION organization.fn_create_employee(p_uuid uuid, p_charge_id bigint, p_first_name character varying, p_first_surname character varying, p_second_surname character varying, p_type_document_id integer, p_document character varying, p_email character varying, p_phone character varying, p_course_ids jsonb, p_created_by integer, p_data_docente jsonb, p_company_id integer, p_user_id integer) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_new_employee_id BIGINT;
                v_course_id TEXT;
                v_limit_assigned_questions INTEGER;
            BEGIN
                v_limit_assigned_questions := (p_data_docente->>'goal')::smallint + ((p_data_docente->>'goal')::smallint) / 2;

                INSERT INTO employees (
                    "uuid", first_name, first_surname, second_surname, type_document_id,
                    "document", email, phone, created_by, created_at, charge_id,
                    code, limit_assigned_questions, limit_assigned_questions_initial, fl_unlimit_questions,
                    goal, lot, level_id, company_id, user_id,
                    fl_resolve_missing_questions,
                    limit_missing_questions
                )
                VALUES (
                    p_uuid, p_first_name, p_first_surname, p_second_surname,
                    p_type_document_id, p_document, p_email, p_phone,
                    p_created_by, now(), p_charge_id,
                    p_data_docente->>'code',
                    v_limit_assigned_questions,
                    COALESCE((p_data_docente->>'limit_assigned_questions_initial')::smallint, 0),
                    (p_data_docente->>'fl_unlimit_questions')::boolean,
                    (p_data_docente->>'goal')::smallint,
                    (p_data_docente->>'lot')::smallint,
                    (p_data_docente->>'level')::smallint,
                    p_company_id,
                    p_user_id,
                    (p_data_docente->>'fl_resolve_missing_questions')::boolean,
                    (p_data_docente->>'missing_questions_lot')::smallint
                )
                RETURNING id INTO v_new_employee_id;

                FOR v_course_id IN
                    SELECT id
                    FROM course
                    WHERE id IN (
                        SELECT jsonb_array_elements_text(p_course_ids)::bigint
                    )
                LOOP
                    INSERT INTO employee_course (teacher_id, course_id, created_by, created_at)
                    VALUES (v_new_employee_id, v_course_id::bigint, p_created_by, now());
                END LOOP;

                RETURN v_new_employee_id;
            END;
            $$;


ALTER FUNCTION organization.fn_create_employee(p_uuid uuid, p_charge_id bigint, p_first_name character varying, p_first_surname character varying, p_second_surname character varying, p_type_document_id integer, p_document character varying, p_email character varying, p_phone character varying, p_course_ids jsonb, p_created_by integer, p_data_docente jsonb, p_company_id integer, p_user_id integer) OWNER TO postgres;

--
