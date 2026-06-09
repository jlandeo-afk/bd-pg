-- Function: questions.fn_delete_image_gallery(integer, integer)

--

CREATE FUNCTION questions.fn_delete_image_gallery(p_id integer, p_user_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
                BEGIN  
                    UPDATE questions.image_gallery set fl_status = false, deleted_by = p_user_id , deleted_at = now() where id = p_id ;
                    UPDATE questions.image_galery_topic  set fl_status = false, updated_by = p_user_id, updated_at = now()
                    WHERE image_gallery_id = p_id ;
                END;
            $$;


ALTER FUNCTION questions.fn_delete_image_gallery(p_id integer, p_user_id integer) OWNER TO postgres;

--
