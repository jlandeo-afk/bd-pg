-- Function: auth.fn_deleted_user(bigint, bigint)

--

CREATE FUNCTION auth.fn_deleted_user(p_user_id bigint, p_deleted_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        begin
            UPDATE auth.users  
            SET fl_status  = FALSE,
                deleted_by = p_deleted_by,
                deleted_at = now() 
            WHERE id = p_user_id;
            
               
           
           update odiseo.employees    
                   SET fl_status  = FALSE,
                deleted_by = p_deleted_by,
                deleted_at = now() 
            WHERE user_id  = p_user_id;
           
        END;
        $$;


ALTER FUNCTION auth.fn_deleted_user(p_user_id bigint, p_deleted_by bigint) OWNER TO postgres;

--
