-- Function: auth.fn_get_rol(integer, integer)

CREATE OR REPLACE FUNCTION auth.fn_get_rol(p_rol_id integer, p_company_id integer) RETURNS TABLE(id bigint, name character varying, slug character varying, description text, fl_status boolean, created_by bigint, updated_by bigint, deleted_by bigint, created_at timestamp without time zone, updated_at timestamp without time zone, deleted_at timestamp without time zone, permissions json)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        SELECT
            r.id,
            r.name,
            r.slug,
            r.description,
            r.fl_status,
            r.created_by,
            r.updated_by,
            r.deleted_by,
            r.created_at,
            r.updated_at,
            r.deleted_at,
            CASE 
                WHEN count(p.id) > 0 THEN json_agg(p.*)
                ELSE '[]'::json
            END AS permissions
        FROM roles r
        LEFT JOIN (SELECT rp.id, rp.rol_id, rp.permission_id FROM roles_permissions rp WHERE rp.fl_status = TRUE) rp ON r.id = rp.rol_id
        LEFT JOIN (SELECT p.id, p.name, p.fl_status FROM permissions p WHERE p.fl_status = TRUE ORDER BY p.id) p ON rp.permission_id = p.id
        WHERE r.id = p_rol_id
        and r.company_id = p_company_id
        GROUP BY
            r.id,
            r.name,
            r.slug,
            r.description,
            r.fl_status,
            r.created_by,
            r.updated_by,
            r.deleted_by,
            r.created_at,
            r.updated_at,
            r.deleted_at;
    END;
    $$;

ALTER FUNCTION auth.fn_get_rol(p_rol_id integer, p_company_id integer) OWNER TO postgres;
