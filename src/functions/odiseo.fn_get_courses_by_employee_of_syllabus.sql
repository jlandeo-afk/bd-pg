-- Function: odiseo.fn_get_courses_by_employee_of_syllabus(smallint, smallint, smallint)

--

CREATE FUNCTION odiseo.fn_get_courses_by_employee_of_syllabus(p_employee_id smallint, p_cycle_id smallint, p_university_id smallint) RETURNS TABLE(id smallint, code character varying, name character varying, fl_template boolean)
    LANGUAGE plpgsql
    AS $$
            BEGIN
            RETURN QUERY
            select tbl_courses.id,tbl_courses.code,tbl_courses.name,tbl_courses.fl_template
            FROM
            (
                SELECT DISTINCT
                c.id,
                c.code,
                c."name",
                CASE
                    WHEN COALESCE(tbl_syllabus.total, 0) > 0 THEN true
                    ELSE false
                END AS fl_template
            FROM
                odiseo.employee_course ec
            LEFT JOIN
                odiseo.course c ON ec.course_id = c.id
            LEFT JOIN (
                SELECT
                    s.course_id,
                    COUNT(*) AS total
                FROM
                    odiseo.syllabus s
                WHERE
                    s.fl_status = true
                    AND s.deleted_at IS null AND
                    s.cycle_id = p_cycle_id AND
                    s.university_id  = p_university_id
                GROUP BY
                    s.course_id
            ) AS tbl_syllabus ON c.id = tbl_syllabus.course_id
            WHERE
                ec.fl_status = true
                AND c.fl_status = true
                AND ec.deleted_at IS NULL
                AND c.deleted_at IS NULL
                AND (p_employee_id IS NULL OR ec.teacher_id = p_employee_id)
            ) as tbl_courses
            order by   tbl_courses.fl_template desc, unaccent(tbl_courses.name)
                ;
            END;
        $$;


ALTER FUNCTION odiseo.fn_get_courses_by_employee_of_syllabus(p_employee_id smallint, p_cycle_id smallint, p_university_id smallint) OWNER TO postgres;

--
