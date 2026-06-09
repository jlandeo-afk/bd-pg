-- Function: organization.fn_verified_save_user_employee(uuid, character varying, character varying, text, integer, character varying, bigint, bigint, bigint, uuid, character varying, character varying, character varying, integer, character varying, character varying, character varying, integer, integer, boolean, character varying, integer, jsonb)

--

CREATE FUNCTION organization.fn_verified_save_user_employee(p_uuid uuid, p_user character varying, p_email character varying, p_password text, p_status_session integer, p_image character varying, p_created_by bigint, p_company_id bigint, p_rol_id bigint, p_uuid_e uuid, p_first_name character varying, p_first_surname character varying, p_second_surname character varying, p_type_document_id integer, p_document character varying, p_email_e character varying, p_phone character varying, p_limit_assigned_questions integer, p_limit_assigned_questions_initial integer, p_fl_unlimit_questions boolean, p_code character varying, p_charge_id integer, p_course jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
			DECLARE
				v_id BIGINT;
				v_new_user_id BIGINT;
				v_new_employee_id BIGINT;
            BEGIN
                SELECT u.id INTO v_id
                FROM auth.users u
				WHERE u.user = p_user
				LIMIT 1;

				IF v_id IS NULL THEN
					INSERT INTO auth.users (uuid, "user", email, password, status_session, image, created_by, created_at, company_id)
					VALUES(p_uuid, p_user, p_email, p_password, p_status_session, p_image, p_created_by, now(), p_company_id)
					RETURNING id INTO v_new_user_id;

					INSERT INTO auth.users_roles (user_id, rol_id, created_by, created_at)
					VALUES (v_new_user_id, p_rol_id, p_created_by, now());

					INSERT INTO organization.employees (uuid, user_id, first_name, first_surname, second_surname, type_document_id, "document", email, phone, created_by, created_at, code, limit_assigned_questions, limit_assigned_questions_initial, fl_unlimit_questions, charge_id)
					VALUES (p_uuid, v_new_user_id, p_first_name, p_first_surname, p_second_surname, p_type_document_id, p_document, p_email_e, p_phone, p_created_by, now(), p_code, p_limit_assigned_questions, p_limit_assigned_questions_initial, p_fl_unlimit_questions, p_charge_id)
					RETURNING id INTO v_new_employee_id;

					INSERT INTO organization.employee_course (teacher_id, course_id, created_by, created_at)
		            SELECT v_new_employee_id, value::bigint, p_created_by, now()
		            FROM jsonb_array_elements(p_course) AS value;
				END IF;
            END;
            $$;


ALTER FUNCTION organization.fn_verified_save_user_employee(p_uuid uuid, p_user character varying, p_email character varying, p_password text, p_status_session integer, p_image character varying, p_created_by bigint, p_company_id bigint, p_rol_id bigint, p_uuid_e uuid, p_first_name character varying, p_first_surname character varying, p_second_surname character varying, p_type_document_id integer, p_document character varying, p_email_e character varying, p_phone character varying, p_limit_assigned_questions integer, p_limit_assigned_questions_initial integer, p_fl_unlimit_questions boolean, p_code character varying, p_charge_id integer, p_course jsonb) OWNER TO postgres;

--
