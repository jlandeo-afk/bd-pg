-- Function: academic.fn_course_all(boolean)

--

CREATE FUNCTION academic.fn_course_all(f_fl_pseudo_course boolean) RETURNS TABLE(id smallint, code character varying, name character varying, name_course character varying, area_id bigint, area_code character varying, area character varying, setting_diagrammed_course boolean, fl_pseudo_course boolean)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    c.id,
                    c.code,
                    CONCAT(c.code, ' - ', c.name)::VARCHAR AS name,
                    c.name AS name_course,
                    c.area_id,
                    a.code AS area_code,
                    a.description AS area,
                    CASE WHEN COUNT(sdc.course_id) > 0 THEN false ELSE true END AS setting_diagrammed_course,
                    c.fl_pseudo_course
                FROM academic.course c
                LEFT JOIN odiseo.area a ON c.area_id = a.id
                LEFT JOIN academic.setting_diagrammed_courses sdc ON c.id = sdc.course_id
                WHERE c.fl_status = true
                AND (f_fl_pseudo_course IS NULL OR c.fl_pseudo_course = f_fl_pseudo_course)
                GROUP BY
                    c.id,
                    c.code,
                    c.name,
                    c.area_id,
                    a.code,
                    a.description
                ORDER BY c.id ASC;
            END;
            $$;


ALTER FUNCTION academic.fn_course_all(f_fl_pseudo_course boolean) OWNER TO postgres;

--
