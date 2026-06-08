-- Function: odiseo.fn_update_employee(bigint, character varying, character varying, character varying, bigint, character varying, character varying, character varying, bigint)

--

CREATE FUNCTION odiseo.fn_update_employee(p_id bigint, p_first_name character varying, p_first_surname character varying, p_second_surname character varying, p_type_document bigint, p_document character varying, p_email character varying, p_phone character varying, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN
       
       UPDATE odiseo.employees  
       SET first_name = p_first_name,
           first_surname = p_first_surname,
           second_surname = p_second_surname, 
           type_document_id = p_type_document,
           document = p_document, 
           email = p_email,
           phone = p_phone,
           updated_by = p_updated_by,
           updated_at = now() 
       WHERE id = p_id;
       
   END;
   $$;


ALTER FUNCTION odiseo.fn_update_employee(p_id bigint, p_first_name character varying, p_first_surname character varying, p_second_surname character varying, p_type_document bigint, p_document character varying, p_email character varying, p_phone character varying, p_updated_by bigint) OWNER TO postgres;

--
