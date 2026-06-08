-- Function: odiseo.fn_deleted_user(bigint, bigint)

--

CREATE FUNCTION odiseo.fn_deleted_user(p_user_id bigint, p_deleted_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        begin
            UPDATE odiseo.users  
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


ALTER FUNCTION odiseo.fn_deleted_user(p_user_id bigint, p_deleted_by bigint) OWNER TO postgres;

--
