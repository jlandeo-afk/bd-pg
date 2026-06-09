-- Function: auth.fn_find_permission_rol(integer, integer)

--

CREATE FUNCTION auth.fn_find_permission_rol(f_permission_id integer, f_company_id integer) RETURNS TABLE(id bigint, name character varying, fl_status boolean, created_by bigint, updated_by bigint, deleted_by bigint, created_at timestamp without time zone, updated_at timestamp without time zone, deleted_at timestamp without time zone, module character varying, fl_administrator boolean, roles json, user_name character varying, user_email odiseo.email_citext)
    LANGUAGE plpgsql
    AS $$
            BEGIN

            RETURN QUERY
            SELECT
                p.id,
                p.name,
                p.fl_status,
                p.created_by,
                p.updated_by,
                p.deleted_by,
                p.created_at,
                p.updated_at,
                p.deleted_at,
                p.module,
                p.fl_administrator,
                COALESCE(json_agg(r.*) FILTER (WHERE r.id IS NOT NULL), '[]'::json) AS roles,
                u.user as user_name,
                u.email as user_email
            FROM permissions p
            LEFT JOIN (
                SELECT rp.id, rp.rol_id, rp.permission_id, rp.fl_status, rp.company_id
                FROM roles_permissions rp
                WHERE rp.fl_status = true
            ) rp ON p.id = rp.permission_id AND rp.company_id = f_company_id
            LEFT JOIN users u ON p.created_by = u.id
            LEFT JOIN (
                SELECT r.id, r.name, r.slug, r.fl_status
                FROM roles r
                WHERE r.fl_status = true
            ) r ON rp.rol_id = r.id
            WHERE rp.rol_id = f_permission_id
            GROUP BY
                p.id,
                p.name,
                p.fl_status,
                p.created_by,
                p.updated_by,
                p.deleted_by,
                p.created_at,
                p.updated_at,
                p.deleted_at,
                p.fl_administrator,
                p.module,
                u.user,
                u.email
            ORDER BY p.id ASC;
            END;
            $$;


ALTER FUNCTION auth.fn_find_permission_rol(f_permission_id integer, f_company_id integer) OWNER TO postgres;

--
