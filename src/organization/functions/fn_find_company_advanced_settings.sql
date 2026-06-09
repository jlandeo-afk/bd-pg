-- Function: organization.fn_find_company_advanced_settings(integer)

--

CREATE FUNCTION organization.fn_find_company_advanced_settings(f_company_id integer) RETURNS TABLE(id integer, company_id integer, similarity_percentage numeric, fl_status boolean, created_by bigint, updated_by bigint, created_at timestamp without time zone, updated_at timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    a.id,
                    a.company_id,
                    a.similarity_percentage,
                    a.fl_status,
                    a.created_by,
                    a.updated_by,
                    a.created_at,
                    a.updated_at
                FROM common.advanced_settings a
                WHERE a.fl_status = true
                AND a.company_id = f_company_id
                ORDER BY a.id ASC;
            END;
            $$;


ALTER FUNCTION organization.fn_find_company_advanced_settings(f_company_id integer) OWNER TO postgres;

--
