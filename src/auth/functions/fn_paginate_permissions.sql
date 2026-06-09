-- Function: auth.fn_paginate_permissions(integer, integer, integer, boolean, boolean, character varying, integer, boolean)

--

CREATE FUNCTION auth.fn_paginate_permissions(p_perpage integer, p_npage integer, f_permission_id integer, p_administrator boolean, f_status boolean, p_name_text character varying, p_company_id integer, p_can_filter_companies boolean) RETURNS TABLE(id bigint, name character varying, fl_status boolean, created_by bigint, updated_by bigint, deleted_by bigint, created_at timestamp without time zone, updated_at timestamp without time zone, deleted_at timestamp without time zone, module character varying, fl_administrator boolean, roles json, user_name character varying, user_email odiseo.email_citext, total integer)
    LANGUAGE plpgsql
    AS $$
                        DECLARE
                            total_count INTEGER;
                            offset_val INTEGER;
                        BEGIN
                            offset_val := p_perpage * (p_npage - 1);

                           SELECT COUNT(*)
                            INTO total_count
                            FROM permissions p
                            LEFT JOIN users u ON p.created_by = u.id
                            WHERE 1 = 1
                            AND p.fl_status = f_status
                            AND (f_permission_id IS NULL OR p.id = f_permission_id)
                            AND (p_name_text IS NULL OR LOWER(p.name) LIKE '%' || LOWER(p_name_text) || '%');

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
                                u.email as user_email,
                                total_count AS total
                            FROM permissions p
                            LEFT JOIN (
                                SELECT rp.id, rp.rol_id, rp.permission_id, rp.fl_status
                                FROM roles_permissions rp
                                WHERE rp.fl_status = true
                            ) rp ON p.id = rp.permission_id 
                            LEFT JOIN (
                                SELECT r.id, r.name, r.slug, r.fl_status, r.fl_administrator
                                FROM roles r
                                WHERE r.fl_status = true
                                AND r.company_id = p_company_id
                            ) r ON rp.rol_id = r.id
                            LEFT JOIN users u ON p.created_by = u.id
                            WHERE 1 = 1
                            AND p.fl_status = f_status
                            AND (p_administrator = true OR p.fl_administrator = false)
                            AND (f_permission_id IS NULL OR p.id = f_permission_id)
                            AND (p_name_text IS NULL OR LOWER(p.name) LIKE '%' || LOWER(p_name_text) || '%')
                            AND (p_can_filter_companies = true OR p.fl_to_use_client = true)
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
                                p.module,
                                p.fl_administrator,
                                u.user,
                                u.email
                            ORDER BY p.id ASC
                            LIMIT p_perpage
                            OFFSET offset_val;
                        END;
                        $$;


ALTER FUNCTION auth.fn_paginate_permissions(p_perpage integer, p_npage integer, f_permission_id integer, p_administrator boolean, f_status boolean, p_name_text character varying, p_company_id integer, p_can_filter_companies boolean) OWNER TO postgres;

--
