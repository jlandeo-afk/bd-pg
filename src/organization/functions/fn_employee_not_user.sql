-- Function: organization.fn_employee_not_user(character varying, integer)

--

CREATE FUNCTION organization.fn_employee_not_user(p_name_text character varying, p_company_id integer) RETURNS TABLE(id bigint, uuid uuid, user_id bigint, first_name character varying, first_surname character varying, second_surname character varying, charge_id bigint, charge character varying, type_document_id bigint, type_document character varying, document character varying, email odiseo.email_citext)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    e.id,
                    e.uuid,
                    e.user_id,
                    e.first_name,
                    e.first_surname,
                    e.second_surname,
                    e.charge_id,
                    c.name AS charge,
                    e.type_document_id,
                    t.name as type_document,
                    e.document,
                    e.email
                FROM employees e
                INNER JOIN charge c ON e.charge_id = c.id
                INNER JOIN common.type_documents t ON e.type_document_id = t.id
                WHERE e.fl_status = true
                AND e.user_id IS NULL
                AND (
                    p_name_text IS NULL 
                    OR LOWER(e.first_name) LIKE '%' || LOWER(p_name_text) || '%' 
                    OR LOWER(e.first_surname) LIKE '%' || LOWER(p_name_text) || '%' 
                    OR LOWER(e.second_surname) LIKE '%' || LOWER(p_name_text) || '%' 
                    OR e.document LIKE '%' || p_name_text || '%'
                    OR CONCAT(LOWER(e.first_name), ' ', LOWER(e.first_surname)) LIKE '%' || LOWER(p_name_text) || '%'
                )
                AND e.company_id = p_company_id
                ORDER BY e.id ASC;
            END;
            $$;


ALTER FUNCTION organization.fn_employee_not_user(p_name_text character varying, p_company_id integer) OWNER TO postgres;

--
