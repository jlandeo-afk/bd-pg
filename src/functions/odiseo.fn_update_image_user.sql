-- Function: odiseo.fn_update_image_user(bigint, character varying, bigint)

--

CREATE FUNCTION odiseo.fn_update_image_user(p_user_id bigint, p_image character varying, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
            begin
                UPDATE odiseo.users  
                SET image  = p_image,
                    updated_by = p_updated_by,
                    updated_at = now() 
                WHERE id = p_user_id;
                
            END;
            $$;


ALTER FUNCTION odiseo.fn_update_image_user(p_user_id bigint, p_image character varying, p_updated_by bigint) OWNER TO postgres;

--
