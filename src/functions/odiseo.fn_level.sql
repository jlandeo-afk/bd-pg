-- Function: odiseo.fn_level(integer, integer, character varying, smallint, boolean)

--

CREATE FUNCTION odiseo.fn_level(p_perpage integer, p_npage integer, p_search character varying, p_course_id smallint, f_status boolean) RETURNS TABLE(id bigint, name character varying, description character varying, courses json, fl_status boolean, created_by bigint, updated_by bigint, deleted_by bigint, created_at timestamp without time zone, updated_at timestamp without time zone, deleted_at timestamp without time zone, user_name character varying, user_email odiseo.email_citext, total bigint)
    LANGUAGE plpgsql
    AS $$
                        DECLARE
                            offset_val INTEGER;
                        BEGIN
                            offset_val := p_perpage * (p_npage - 1);

                            RETURN QUERY
                            WITH tbl_level AS (
                                SELECT
                                    l.id,
                                    l.name,
                                    l.description,
                                    CASE
                                        WHEN count(cl.id) > 0 THEN json_agg(json_build_object(
                                            'id', cl.id,
                                            'level_id', cl.level_id,
                                            'code', cl.code,
                                            'course_id', cl.course_id,
                                            'code_course', c.code,
                                            'name', c.name
                                        ))
                                        ELSE '[]'::json
                                    END AS courses,
                                    l.fl_status,
                                    l.created_by,
                                    l.updated_by,
                                    l.deleted_by,
                                    l.created_at,
                                    l.updated_at,
                                    l.deleted_at,
                                    u.user AS user_name,
                                    u.email AS user_email
                                FROM level l
                                LEFT JOIN users u ON l.created_by = u.id
                                LEFT JOIN course_level cl ON l.id = cl.level_id AND cl.fl_status = true
                                LEFT JOIN course c ON cl.course_id = c.id
                                WHERE l.fl_status = f_status
                                AND l.deleted_at IS NULL
                                AND (
                                    p_search IS NULL
                                    OR (LOWER(l.name) LIKE '%' || LOWER(p_search) || '%'
                                    OR LOWER(l.description) LIKE '%' || LOWER(p_search) || '%')
                                )
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
                                    u.email
                                HAVING (
                                    p_course_id IS NULL
                                    OR EXISTS (
                                        SELECT 1
                                        FROM course_level cl2
                                        WHERE cl2.level_id = l.id
                                        AND cl2.course_id = p_course_id
                                        AND cl2.fl_status = true
                                    )
                                )
                                ORDER BY l.id ASC
                            )

                            SELECT *, count(*) OVER () AS total
                            FROM tbl_level
                            LIMIT p_perpage
                            OFFSET offset_val;
                        END;
                        $$;


ALTER FUNCTION odiseo.fn_level(p_perpage integer, p_npage integer, p_search character varying, p_course_id smallint, f_status boolean) OWNER TO postgres;

--
