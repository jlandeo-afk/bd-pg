-- Function: odiseo.fn_create_permission(character varying, integer)

--

CREATE FUNCTION odiseo.fn_create_permission(p_name character varying, p_created_by integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_new_permission_id INTEGER;
                v_count INTEGER;
            BEGIN
                -- Comprobar si ya existe un registro con el mismo nombre
                SELECT COUNT(*)
                INTO v_count
                FROM odiseo.permissions
                WHERE LOWER(name) = LOWER(p_name);
            
                -- Si no existe un registro con el mismo nombre, proceder con la inserción
                IF v_count = 0 THEN
                    INSERT INTO odiseo.permissions (name, created_by, created_at)
                    VALUES (p_name, p_created_by, now())
                    RETURNING id INTO v_new_permission_id;
            
                    RETURN v_new_permission_id;
                ELSE
                    -- Si ya existe un registro con el mismo nombre, devolver NULL
                    RETURN NULL;
                END IF;
            END;
            $$;


ALTER FUNCTION odiseo.fn_create_permission(p_name character varying, p_created_by integer) OWNER TO postgres;

--
