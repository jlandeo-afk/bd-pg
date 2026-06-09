-- Function: organization.fn_find_employee_user(integer)

--

CREATE FUNCTION organization.fn_find_employee_user(p_user_id integer) RETURNS TABLE(id bigint, uuid uuid, first_name character varying, first_surname character varying, second_surname character varying, charge_id bigint, name_charge character varying, courses jsonb)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            SELECT
                e.id AS employee_id,
                e."uuid",
                e.first_name,
                e.first_surname,
                e.second_surname,
                e.charge_id,
                c."name" AS name_charge,
                JSONB_AGG(
                    emplcour.course_id
                ) AS courses
            FROM organization.employees e
            LEFT JOIN organization.charge c ON e.charge_id = c.id
            LEFT JOIN organization.employee_course emplcour ON emplcour.teacher_id = e.id AND emplcour.fl_status = true
            WHERE 1 = 1
            AND e.user_id = p_user_id
            group by e.id,c.name;
        END;
        $$;


ALTER FUNCTION organization.fn_find_employee_user(p_user_id integer) OWNER TO postgres;

--
