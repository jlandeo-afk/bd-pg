-- Function: odiseo.fn_find_area(integer, boolean)

--

CREATE FUNCTION odiseo.fn_find_area(f_area_id integer, f_status boolean) RETURNS TABLE(id bigint, code character varying, slug character varying, description character varying, fl_status boolean, created_by bigint, updated_by bigint, deleted_by bigint, created_at timestamp without time zone, updated_at timestamp without time zone, deleted_at timestamp without time zone, user_name character varying, user_email odiseo.email_citext)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    a.*,
                    u.user as user_name,
                    u.email as user_email
                FROM area a
                LEFT JOIN users u ON a.created_by = u.id
                WHERE a.fl_status = f_status
                AND a.deleted_at IS NULL
                AND a.id = f_area_id
                ORDER BY a.id ASC;
            END;
            $$;


ALTER FUNCTION odiseo.fn_find_area(f_area_id integer, f_status boolean) OWNER TO postgres;

--
