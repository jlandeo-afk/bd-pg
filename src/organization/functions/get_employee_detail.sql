-- Function: organization.get_employee_detail(integer)

--

CREATE FUNCTION organization.get_employee_detail(p_user_id integer) RETURNS TABLE(id bigint, user_id bigint, user_name character varying, first_name character varying, first_surname character varying, second_surname character varying, type_document_id bigint, document character varying, email odiseo.email_citext, phone character varying, fl_status boolean, image character varying)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY 
                SELECT e.id, 
                u.id as user_id,
                u.user as  user_name,
                e.first_name, 
                e.first_surname, 
                e.second_surname, e.type_document_id, e."document", e.email, e.phone, e.fl_status,u.image 
                FROM employees e
                left join users u 
                on e.user_id = u.id 
                WHERE e.user_id = p_user_id;
            END;
            $$;


ALTER FUNCTION organization.get_employee_detail(p_user_id integer) OWNER TO postgres;

--
