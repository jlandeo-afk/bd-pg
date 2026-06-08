-- Function: odiseo.fn_get_search_exam_areas(integer, integer, character varying)

--

CREATE FUNCTION odiseo.fn_get_search_exam_areas(p_perpage integer, p_npage integer, p_search character varying) RETURNS TABLE(id smallint, exam_area character varying, description character varying, created_at timestamp without time zone, created_by text, total bigint)
    LANGUAGE plpgsql
    AS $$
                DECLARE
                    offset_val INTEGER;
                BEGIN
                    -- Calcula el offset para la paginación
                    offset_val := p_perpage * (p_npage - 1);

                    RETURN QUERY
                    WITH tbl_exam_area AS (
                        SELECT 
                            ea.id,
                            ea.description AS exam_area,
                            ea.short_description AS description,
                            ea.created_at,
                            CASE
                                WHEN e.first_name IS NOT NULL AND e.first_surname IS NOT NULL THEN
                                    CONCAT(
                                        e.first_name, ' ',
                                        upper(left(e.first_surname, 1)), '. ',
                                        e.second_surname
                                    )
                                ELSE 'Administrador'
                            END AS created_by
                        FROM
                            odiseo.exam_area ea
                        LEFT JOIN odiseo.users u
                            ON u.id = ea.created_by
                        LEFT JOIN odiseo.employees e
                            ON e.user_id = u.id
                        WHERE
                            ea.fl_status = TRUE
                            AND (
                                p_search IS NULL OR
                                LOWER(ea.description) LIKE '%' || LOWER(p_search) || '%'
                            )
                    )
                    SELECT
                        tbl_exam_area.id,
                        tbl_exam_area.exam_area,
                        tbl_exam_area.description,
                        tbl_exam_area.created_at,
                        tbl_exam_area.created_by,
                        COUNT(*) OVER () AS total
                    FROM
                        tbl_exam_area
                    ORDER BY
                        created_at DESC
                    LIMIT p_perpage
                    OFFSET offset_val;
                END;
            $$;


ALTER FUNCTION odiseo.fn_get_search_exam_areas(p_perpage integer, p_npage integer, p_search character varying) OWNER TO postgres;

--
