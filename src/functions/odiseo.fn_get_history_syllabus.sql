-- Function: odiseo.fn_get_history_syllabus(bigint, bigint)

--

CREATE FUNCTION odiseo.fn_get_history_syllabus(p_syllabus_id bigint, p_company_id bigint) RETURNS TABLE(id bigint, syllabus_id bigint, user_id bigint, role_id bigint, correlative integer, description text, created_at timestamp without time zone, updated_at timestamp without time zone, token character varying, weeks json, user_name character varying, user_email odiseo.email_citext, role_name character varying)
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    RETURN QUERY 
                    SELECT
                        s.id, 
                        s.syllabus_id,
                        s.user_id,
                        s.role_id,
                        s.correlative,
                        s.description, 
                        s.created_at, 
                        s.updated_at, 
                        s.token,
                        s.weeks,
                        u.user as user_name,
                        u.email as user_email,
                        r.name as role_name
                    FROM history_syllabus s
                    LEFT JOIN users u ON s.user_id = u.id
                    LEFT JOIN roles r ON s.role_id = r.id
                    WHERE s.syllabus_id = p_syllabus_id
                    AND s.company_id = p_company_id
                    ORDER BY s.correlative DESC;
                END;                    
            $$;


ALTER FUNCTION odiseo.fn_get_history_syllabus(p_syllabus_id bigint, p_company_id bigint) OWNER TO postgres;

--
