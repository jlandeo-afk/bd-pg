-- Function: materials.fn_set_lock_status_on_material(integer, integer, integer, boolean, integer)

--

CREATE FUNCTION materials.fn_set_lock_status_on_material(p_material_id integer, p_type_material_id integer, p_week integer, p_locked_status boolean, p_locker_user integer) RETURNS TABLE(lock_status boolean, locked_at timestamp without time zone, locked_by_id integer, locked_by_name text)
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    UPDATE academic.detail_week_type_mat
                        SET locked = p_locked_status,
                            locked_by = p_locker_user,
                            locked_at = NOW()
                        WHERE 1 = 1
                          AND material_id = p_material_id
                          AND week = p_week
                          AND type_material_id = p_type_material_id;
                          
                    RETURN QUERY
                    
                    WITH lock_status AS (
                        SELECT
                            p_locked_status AS lock_status,
                            p_locker_user AS locked_by_id
                    )
                    SELECT
                        ls.lock_status,
                        NOW()::TIMESTAMP WITHOUT TIME ZONE AS locked_at,
                        ls.locked_by_id,
                        CASE
                            WHEN ls.locked_by_id IN (1, 2) THEN 'Administrador'
                            ELSE CONCAT( e.first_surname, ' ', e.second_surname, ' ', e.first_name )
                        END AS locked_by_name
                    FROM lock_status ls
                    LEFT JOIN odiseo.employees e ON e.user_id = ls.locked_by_id;
                END;
            $$;


ALTER FUNCTION materials.fn_set_lock_status_on_material(p_material_id integer, p_type_material_id integer, p_week integer, p_locked_status boolean, p_locker_user integer) OWNER TO postgres;

--
