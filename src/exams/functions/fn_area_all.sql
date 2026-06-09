-- Function: exams.fn_area_all(character varying, character varying, character varying, character varying, boolean)

--

CREATE FUNCTION exams.fn_area_all(p_search character varying, p_code character varying, p_slug character varying, p_description character varying, f_status boolean) RETURNS TABLE(id bigint, code character varying, slug character varying, description character varying, fl_status boolean, created_by bigint, updated_by bigint, deleted_by bigint, created_at timestamp without time zone, updated_at timestamp without time zone, deleted_at timestamp without time zone, user_name character varying, user_email odiseo.email_citext)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    a.id,
                    a.code,
                    a.slug,
                    a.description,
                    a.fl_status,
                    a.created_by,
                    a.updated_by,
                    a.deleted_by,
                    a.created_at,
                    a.updated_at,
                    a.deleted_at,
                    u.user as user_name,
                    u.email as user_email
                FROM area a
                LEFT JOIN users u ON a.created_by = u.id
                WHERE a.fl_status = f_status
                AND a.deleted_at IS NULL
                AND (p_code IS NULL OR LOWER(a.code) LIKE '%' || LOWER(p_code) || '%')
                AND (p_slug IS NULL OR LOWER(a.slug) LIKE '%' || LOWER(p_slug) || '%')
                AND (p_description IS NULL OR LOWER(a.description) LIKE '%' || LOWER(p_description) || '%')
                AND (p_search IS NULL OR (LOWER(a.code) LIKE '%' || LOWER(p_search) || '%' OR LOWER(a.description) LIKE '%' || LOWER(p_search) || '%'))
                ORDER BY a.id ASC;
            END;     
    $$;


ALTER FUNCTION exams.fn_area_all(p_search character varying, p_code character varying, p_slug character varying, p_description character varying, f_status boolean) OWNER TO postgres;

--
