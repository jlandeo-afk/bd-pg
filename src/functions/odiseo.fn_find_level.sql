-- Function: odiseo.fn_find_level(integer, boolean)

--

CREATE FUNCTION odiseo.fn_find_level(f_level_id integer, f_status boolean) RETURNS TABLE(id bigint, name character varying, description character varying, courses json, fl_status boolean, created_by bigint, updated_by bigint, deleted_by bigint, created_at timestamp without time zone, updated_at timestamp without time zone, deleted_at timestamp without time zone, user_name character varying, user_email odiseo.email_citext)
    LANGUAGE plpgsql
    AS $$
                        BEGIN
                            RETURN QUERY
                            SELECT
                                l.id,
                                l.name,
                                l.description,
                                CASE
                                    WHEN count(cl.id) > 0 THEN json_agg(cl.*)
                                    ELSE '[]'::json
                                END AS courses,
                                l.fl_status,
                                l.created_by,
                                l.updated_by,
                                l.deleted_by,
                                l.created_at,
                                l.updated_at,
                                l.deleted_at,
                                u.user as user_name,
                                u.email as user_email
                            FROM level l
                            LEFT JOIN users u ON l.created_by = u.id
                            LEFT JOIN (
                                SELECT cl.id, cl.level_id, cl.code, cl.course_id, c.code AS code_course, c.name
                                FROM course_level cl
                                INNER JOIN course c ON cl.course_id = c.id
                                WHERE cl.fl_status = true
                            ) cl ON l.id = cl.level_id
                            WHERE l.fl_status = f_status
                            AND l.deleted_at IS NULL
                            AND l.id = f_level_id
                            GROUP BY
                                l.id,
                                l.name,
                                l.description,
                                l.fl_status,
                                l.created_by,
                                l.updated_by,
                                l.deleted_by,
                                l.created_at,
                                l.updated_at,
                                l.deleted_at,
                                u.user,
                                u.email;
                        END;
                        $$;


ALTER FUNCTION odiseo.fn_find_level(f_level_id integer, f_status boolean) OWNER TO postgres;

--
