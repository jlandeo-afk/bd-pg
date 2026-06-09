-- Function: auth.fn_delete_rol(integer, integer)

CREATE OR REPLACE FUNCTION auth.fn_delete_rol(p_rol_id integer, p_deleted_by integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
            DECLARE
                user_count INT;
            BEGIN
                SELECT COUNT(*)
                INTO user_count
                FROM auth.users_roles ur
                WHERE ur.rol_id = p_rol_id AND ur.fl_status = TRUE;
            
                IF user_count = 0 THEN
                    UPDATE auth.roles
                    SET
                        fl_status = FALSE,
                        deleted_by = p_deleted_by,
                        deleted_at = now()
                    WHERE id = p_rol_id;
                    RETURN TRUE;
                ELSE
                    RETURN FALSE;
                END IF;
            END;
            $$;

ALTER FUNCTION auth.fn_delete_rol(p_rol_id integer, p_deleted_by integer) OWNER TO postgres;
