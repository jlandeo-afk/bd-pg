-- Function: auth.fn_list_roles(integer, integer, boolean, character varying, integer)

CREATE OR REPLACE FUNCTION auth.fn_list_roles(p_perpage integer, p_npage integer, f_status boolean, p_name_text character varying, p_company_id integer) RETURNS TABLE(id bigint, name character varying, slug character varying, description text, fl_status boolean, created_by bigint, updated_by bigint, deleted_by bigint, created_at timestamp without time zone, updated_at timestamp without time zone, deleted_at timestamp without time zone, total bigint)
    LANGUAGE plpgsql
    AS $$
    DECLARE 
        offset_val INTEGER;
    BEGIN
        offset_val := p_perpage * (p_npage - 1);

        RETURN QUERY
        WITH roles_filtrados AS (
            SELECT r.id,
                r.name,
                r.slug,
                r.description,
                r.fl_status,
                r.created_by,
                r.updated_by,
                r.deleted_by,
                r.created_at,
                r.updated_at,
                r.deleted_at
            FROM roles r
            WHERE r.fl_status = f_status
            AND r.deleted_at IS NULL
            AND r.company_id = COALESCE(p_company_id, 1)
            AND (
                p_name_text IS NULL
                OR LOWER(r.name) LIKE '%' || LOWER(p_name_text) || '%'
                OR LOWER(r.slug) LIKE '%' || LOWER(p_name_text) || '%'
            )
        ),
        total_rows AS (
            SELECT COUNT(*) AS total FROM roles_filtrados
        )
        SELECT rf.*, tr.total
        FROM roles_filtrados rf
        CROSS JOIN total_rows tr
        ORDER BY rf.id ASC
        LIMIT p_perpage
        OFFSET offset_val;

    END;
    $$;

ALTER FUNCTION auth.fn_list_roles(p_perpage integer, p_npage integer, f_status boolean, p_name_text character varying, p_company_id integer) OWNER TO postgres;
