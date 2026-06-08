-- Function: odiseo.fn_rol_users(bigint)

--

CREATE FUNCTION odiseo.fn_rol_users(p_company_id bigint) RETURNS TABLE(id bigint, num_users bigint, name character varying, slug character varying, users json)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        SELECT
            r.id,
            count(u.id) AS num_users,
            r.name,
            r.slug,
            CASE
                WHEN count(u.id) > 0 THEN json_agg(u.*)
                ELSE '[]'::json
            END AS users
        FROM
            roles r
        LEFT JOIN
            users_roles rp ON r.id = rp.rol_id
        LEFT JOIN (
            SELECT
                u.id, u.uuid, u.user, u.email, u.image, u.fl_status
            FROM
                users u
            WHERE
                u.fl_status = true
        ) u ON rp.user_id = u.id
        WHERE
            r.fl_status = true
            AND r.fl_admin = false
            AND r.fl_administrator = false
            AND r.company_id = p_company_id
        GROUP BY
            r.id, r.name, r.slug
        ORDER BY
            r.id;
    END;
    $$;


ALTER FUNCTION odiseo.fn_rol_users(p_company_id bigint) OWNER TO postgres;

--
