-- Function: academic.fn_get_teacher_nq_list_course(integer)

--

CREATE FUNCTION academic.fn_get_teacher_nq_list_course(p_teacher_id integer) RETURNS TABLE(id smallint, code character varying, name text, name_course character varying)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT 
                    DISTINCT
                    c.id, 
                    c.code, 
                    CONCAT(c.code, ' - ', c.name) AS name, 
                    c.name AS name_course 
                FROM employee_course ec
                LEFT JOIN course c ON ec.course_id = c.id
                WHERE ec.fl_status = true
                AND c.alias_nq IS NOT NULL
                AND (p_teacher_id IS NULL OR ec.teacher_id = p_teacher_id)
                ORDER BY c.code ASC, c.name ASC;
            END;
        $$;


ALTER FUNCTION academic.fn_get_teacher_nq_list_course(p_teacher_id integer) OWNER TO postgres;

--
