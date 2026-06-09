-- Function: organization.fn_name_employee(bigint)

--

CREATE FUNCTION organization.fn_name_employee(p_user_id bigint) RETURNS TABLE(user_name text)
    LANGUAGE plpgsql
    AS $$
            DECLARE
                user_name TEXT;
            BEGIN
                IF p_user_id = 1 OR p_user_id = 2 THEN
                    RETURN QUERY SELECT 'SISTEMA'::text;
                ELSE
					RETURN QUERY
                    SELECT
                        concat(split_part(e.first_name, ' ', 1), ' ', upper(left(e.first_surname, 1)), '. ', e.second_surname) as user_name
                    FROM organization.employees e
                    WHERE e.user_id = p_user_id;
                END IF;
            END;
            $$;


ALTER FUNCTION organization.fn_name_employee(p_user_id bigint) OWNER TO postgres;

--
