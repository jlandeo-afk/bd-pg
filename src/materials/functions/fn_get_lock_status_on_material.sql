-- Function: materials.fn_get_lock_status_on_material(integer, integer, integer)

--

CREATE FUNCTION materials.fn_get_lock_status_on_material(p_material_id integer, p_type_material_id integer, p_week integer) RETURNS TABLE(is_locked boolean, locked_at timestamp without time zone, locked_by_id bigint, locked_by_name text)
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    RETURN QUERY
                     SELECT
                        dwtm.locked AS is_locked,
                        dwtm.locked_at AS locked_at,
                        dwtm.locked_by AS locked_by,
                        CASE
                            WHEN locked_by IS NULL THEN 'Sin acciones registradas'
                            WHEN locked_by IN (1, 2) THEN 'Administrador'
                            ELSE CONCAT( e.first_surname, ' ', e.second_surname, ' ', e.first_name )
                        END AS locked_by_name
                    FROM academic.detail_week_type_mat dwtm
                    LEFT JOIN odiseo.employees e ON dwtm.locked_by = e.user_id
                    WHERE 1 = 1
                      AND dwtm.material_id = p_material_id
                      AND dwtm.type_material_id = p_type_material_id
                      AND dwtm.week = p_week;
                END;
            $$;


ALTER FUNCTION materials.fn_get_lock_status_on_material(p_material_id integer, p_type_material_id integer, p_week integer) OWNER TO postgres;

--
