-- Function: odiseo.fn_create_user(uuid, character varying, character varying, character varying, integer, character varying, integer, integer, character varying, integer)

--

CREATE FUNCTION odiseo.fn_create_user(p_uuid uuid, p_user_name character varying, p_email character varying, p_password character varying, p_status_session integer, p_image character varying, p_company integer, p_role_id integer, p_employee_uuid character varying, p_created_by integer) RETURNS TABLE(status boolean, data integer)
    LANGUAGE plpgsql
    AS $$
            DECLARE
				v_exists_username_id INT;
				v_exists_email_id INT;
				v_exists_employee_id INT;
                v_new_user_id INT;
            BEGIN
				IF p_user_name IS NOT NULL THEN
					SELECT id
					INTO v_exists_username_id
					FROM users
					WHERE LOWER("user") = LOWER(p_user_name)
                	AND fl_status = true
					LIMIT 1;
                END IF;

				IF p_email IS NOT NULL THEN
					SELECT id
					INTO v_exists_email_id
					FROM users
					WHERE LOWER(email) = LOWER(p_email)
                	AND fl_status = true
					LIMIT 1;
                END IF;

				IF v_exists_username_id IS NOT NULL THEN
					RETURN QUERY SELECT false, 1;
				ELSIF v_exists_email_id IS NOT NULL THEN
					RETURN QUERY SELECT false, 2;
				ELSE
					INSERT INTO users (uuid, "user", email, password, status_session, image, company_id, created_by, created_at)
					VALUES (p_uuid, p_user_name, p_email, p_password, p_status_session, p_image, p_company, p_created_by, now())
					RETURNING id INTO v_new_user_id;

					INSERT INTO users_roles (user_id, rol_id, created_by, created_at)
					VALUES (v_new_user_id, p_role_id, p_created_by, now());

					IF p_employee_uuid IS NOT NULL THEN
						SELECT id
						INTO v_exists_employee_id
						FROM employees
						WHERE uuid = p_employee_uuid::UUID
						AND user_id IS NULL
						AND fl_status = true
						LIMIT 1;

						IF v_exists_employee_id IS NOT NULL THEN
							UPDATE employees
							SET user_id = v_new_user_id
							WHERE id = v_exists_employee_id;
						END IF;
					END IF;

					RETURN QUERY SELECT true, v_new_user_id;
				END IF;
            END;
            $$;


ALTER FUNCTION odiseo.fn_create_user(p_uuid uuid, p_user_name character varying, p_email character varying, p_password character varying, p_status_session integer, p_image character varying, p_company integer, p_role_id integer, p_employee_uuid character varying, p_created_by integer) OWNER TO postgres;

--
