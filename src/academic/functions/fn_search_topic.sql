-- Function: academic.fn_search_topic(integer, integer, bigint, character varying)

--

CREATE FUNCTION academic.fn_search_topic(p_perpage integer, p_npage integer, f_course_id bigint, p_text character varying) RETURNS TABLE(id smallint, code character varying, name character varying, couse_id smallint, course character varying, fl_status boolean, total integer, created_by character varying, created_at timestamp without time zone, updated_by character varying, updated_at timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            total_count INTEGER;
            offset_val INTEGER;
        begin
            
            offset_val := p_perpage * (p_npage - 1);
        
            SELECT COUNT(*) 
            INTO total_count
            FROM academic.topic t 
            LEFT JOIN academic.course c ON t.course_id = c.id
            LEFT JOIN auth.users u ON t.created_by = u.id
            LEFT JOIN auth.users u2 ON t.updated_by = u2.id
            WHERE 
                t.deleted_at IS null
                AND (f_course_id IS NULL OR t.course_id = f_course_id)
                AND (p_text IS NULL 
                OR LOWER(t."name") LIKE '%' || LOWER(p_text) || '%'  
                OR LOWER(t.code) LIKE '%' || LOWER(p_text) || '%');
        
            -- Return the paginated topics matching the search criteria
            RETURN QUERY 
            SELECT 
                t.id,
                t.code,
                t."name",
                c.id AS course_id,
                c."name" AS course,
                t.fl_status,
                total_count AS total,
                u."user" AS created_by,
                t.created_at,
                u2."user" AS updated_by,
                t.updated_at
            FROM academic.topic t 
            LEFT JOIN academic.course c ON t.course_id = c.id
            LEFT JOIN auth.users u ON t.created_by = u.id
            LEFT JOIN auth.users u2 ON t.updated_by = u2.id
            WHERE 
                t.deleted_at IS null
                AND (f_course_id IS NULL OR t.course_id = f_course_id)
                AND (p_text IS NULL 
                OR LOWER(t."name") LIKE '%' || LOWER(p_text) || '%'  
                OR LOWER(t.code) LIKE '%' || LOWER(p_text) || '%')
            ORDER by  c."name" ASC, t.code ASC
            LIMIT p_perpage
            OFFSET offset_val;
        END;
        $$;


ALTER FUNCTION academic.fn_search_topic(p_perpage integer, p_npage integer, f_course_id bigint, p_text character varying) OWNER TO postgres;

--
