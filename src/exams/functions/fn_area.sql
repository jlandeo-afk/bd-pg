-- Function: exams.fn_area(integer, integer, character varying, character varying, character varying, character varying, boolean)

--

CREATE FUNCTION exams.fn_area(p_perpage integer, p_npage integer, p_search character varying, p_code character varying, p_slug character varying, p_description character varying, f_status boolean) RETURNS TABLE(id bigint, code character varying, slug character varying, description character varying, fl_status boolean, agreement_url character varying, agreement_file_name character varying, created_by bigint, updated_by bigint, deleted_by bigint, created_at timestamp without time zone, updated_at timestamp without time zone, deleted_at timestamp without time zone, total integer)
    LANGUAGE plpgsql
    AS $$
            DECLARE
                total_count INTEGER;
                offset_val INTEGER;
            BEGIN
                offset_val := p_perpage * (p_npage - 1);

                SELECT COUNT(*)
                INTO total_count
                FROM area a
                WHERE a.fl_status = f_status
                AND a.deleted_at IS NULL
                AND (p_code IS NULL OR LOWER(a.code) LIKE '%' || LOWER(p_code) || '%')
                AND (p_slug IS NULL OR LOWER(a.slug) LIKE '%' || LOWER(p_slug) || '%')
                AND (p_description IS NULL OR LOWER(a.description) LIKE '%' || LOWER(p_description) || '%')
                AND (p_search IS NULL OR (LOWER(a.code) LIKE '%' || LOWER(p_search) || '%' OR LOWER(a.description) LIKE '%' || LOWER(p_search) || '%'));

                RETURN QUERY
                SELECT
                    a.id,
                    a.code,
                    a.slug,
                    a.description,
                    a.fl_status,
                    a.agreement_url,
                    a.agreement_file_name,
                    a.created_by,
                    a.updated_by,
                    a.deleted_by,
                    a.created_at,
                    a.updated_at,
                    a.deleted_at,
                    total_count AS total
                FROM area a
                WHERE a.fl_status = f_status
                AND a.deleted_at IS NULL
                AND (p_code IS NULL OR LOWER(a.code) LIKE '%' || LOWER(p_code) || '%')
                AND (p_slug IS NULL OR LOWER(a.slug) LIKE '%' || LOWER(p_slug) || '%')
                AND (p_description IS NULL OR LOWER(a.description) LIKE '%' || LOWER(p_description) || '%')
                AND (p_search IS NULL OR (LOWER(a.code) LIKE '%' || LOWER(p_search) || '%' OR LOWER(a.description) LIKE '%' || LOWER(p_search) || '%'))
                ORDER BY a.id ASC
                LIMIT p_perpage
                OFFSET offset_val;

            END;  
    $$;


ALTER FUNCTION exams.fn_area(p_perpage integer, p_npage integer, p_search character varying, p_code character varying, p_slug character varying, p_description character varying, f_status boolean) OWNER TO postgres;

--
