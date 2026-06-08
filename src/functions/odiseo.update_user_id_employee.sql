-- Function: odiseo.update_user_id_employee(integer, integer)

--

CREATE FUNCTION odiseo.update_user_id_employee(p_employee_id integer, p_user_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
            BEGIN
                UPDATE odiseo.employees
                SET user_id = p_user_id
                WHERE id = p_employee_id;
            END;
            $$;


ALTER FUNCTION odiseo.update_user_id_employee(p_employee_id integer, p_user_id integer) OWNER TO postgres;

--
