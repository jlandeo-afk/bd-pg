-- Function: auth.fn_show_user(integer)

--

CREATE FUNCTION auth.fn_show_user(p_user_id integer) RETURNS TABLE(id bigint, "user" character varying, email odiseo.email_citext, fl_status boolean, rol_id bigint)
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    RETURN QUERY

                    select u.id, u."user", u.email , u.fl_status,ur.rol_id
                    from users u
                    left join users_roles ur  on u.id = ur.user_id
                    WHERE u.id = p_user_id   ;
                END;
                $$;


ALTER FUNCTION auth.fn_show_user(p_user_id integer) OWNER TO postgres;

--
