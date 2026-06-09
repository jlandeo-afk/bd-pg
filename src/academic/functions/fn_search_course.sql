-- Function: academic.fn_search_course(integer, integer, character varying, integer)

--

CREATE FUNCTION academic.fn_search_course(p_perpage integer, p_npage integer, p_text character varying, p_area_id integer) RETURNS TABLE(id smallint, code character varying, name text, area_id bigint, area_code character varying, area character varying, fl_status boolean, total_setting_diagrammed_course bigint, created_by character varying, created_at timestamp without time zone, updated_by character varying, updated_at timestamp without time zone, total bigint, children jsonb, type_text_template_id smallint, type_text_template_name character varying)
    LANGUAGE plpgsql
    AS $$
                        DECLARE
                            offset_val INTEGER;
                        BEGIN
                            -- Calcular el offset para la paginación
                            offset_val := p_perpage * (p_npage - 1);

                            RETURN QUERY
                            WITH tbl_courses AS (
                                -- Listado de cursos principales
                                SELECT
                                    c.id AS id,
                                    c.code AS code,
                                    UPPER(c.name) AS name,
                                    c.area_id AS area_id,
                                    a.code AS area_code,
                                    a.description AS area,
                                    c.fl_status AS fl_status,
                                    (
                                        SELECT COUNT(*)
                                        FROM setting_diagrammed_courses sdc
                                        WHERE sdc.course_id = c.id AND sdc.fl_status = TRUE
                                    ) AS total_setting_diagrammed_course,
                                    u.user AS created_by,
                                    c.created_at AS created_at,
                                    u2.user AS updated_by,
                                    c.updated_at AS updated_at,
                                    COALESCE(
                                        (SELECT jsonb_agg(jsonb_build_object(
                                            'id', ch.id,
                                            'code', ch.code,
                                            'name', ch.name,
                                            'area_id', ch.area_id
                                        ))
                                        FROM course_pseudo_courses cpc
                                        INNER JOIN course ch ON ch.id = cpc.course_id
                                        WHERE cpc.pseudo_course_id = c.id
                                        AND cpc.fl_status = TRUE
                                        AND ch.fl_status = TRUE),
                                        '[]'::jsonb
                                    ) AS children,
                                    ttt.id type_text_template_id,
                                    ttt.name type_text_template_name
                                FROM course c
                                LEFT JOIN users u ON c.created_by = u.id
                                LEFT JOIN users u2 ON c.updated_by = u2.id
                                LEFT JOIN area a ON c.area_id = a.id
                                LEFT JOIN type_text_templates ttt ON ttt.id = c.type_text_template_id
                                WHERE
                                    c.deleted_at IS NULL
                                    AND (p_text IS NULL
                                        OR LOWER(c.name) LIKE '%' || LOWER(p_text) || '%'
                                        OR LOWER(c.code) LIKE '%' || LOWER(p_text) || '%')
                                    AND (p_area_id IS NULL OR c.area_id = p_area_id)
                                AND c.fl_status  IS TRUE
                                ORDER BY c.id ASC
                            ), tbl_courses_with_total AS (
                                -- Agregar el total de registros
                                SELECT
                                    *,
                                    COUNT(*) OVER () AS total
                                FROM tbl_courses
                            )
                            -- Aplicar paginación
                            SELECT
                                tbl.id,
                                tbl.code,
                                tbl.name,
                                tbl.area_id,
                                tbl.area_code,
                                tbl.area,
                                tbl.fl_status,
                                tbl.total_setting_diagrammed_course,
                                tbl.created_by,
                                tbl.created_at,
                                tbl.updated_by,
                                tbl.updated_at,
                                tbl.total,
                                tbl.children,
                                tbl.type_text_template_id,
                                tbl.type_text_template_name
                            FROM tbl_courses_with_total tbl
                            LIMIT p_perpage
                            OFFSET offset_val;
                        END;
                        $$;


ALTER FUNCTION academic.fn_search_course(p_perpage integer, p_npage integer, p_text character varying, p_area_id integer) OWNER TO postgres;

--
