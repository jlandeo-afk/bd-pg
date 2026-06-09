-- Function: auth.fn_find_user(character varying)

--

CREATE FUNCTION auth.fn_find_user(p_uuid character varying) RETURNS TABLE(id bigint, uuid uuid, user_name character varying, email odiseo.email_citext, typ_document_id bigint, document character varying, employee_email odiseo.email_citext, employee_uuid uuid, employee text, first_name character varying, first_surname character varying, second_surname character varying, role_id bigint, company_id integer)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    u.id,
                    u.uuid,
                    u.user,
                    u.email,
                    e.type_document_id,
                    e.document,
                    e.email AS employee_email,
                    e.uuid AS employee_uuid,
                    CONCAT(e.first_name,' ',e.first_surname,' ',e.second_surname) AS employee,
                    e.first_name,
                    e.first_surname,
                    e.second_surname,
                    ur.rol_id AS role_id,
                    u.company_id
                FROM users u
                LEFT JOIN employees e ON u.id = e.user_id
                LEFT JOIN users_roles ur ON u.id = ur.user_id
                WHERE u.uuid = p_uuid::UUID;
            END;
            $$;


ALTER FUNCTION auth.fn_find_user(p_uuid character varying) OWNER TO postgres;

--
