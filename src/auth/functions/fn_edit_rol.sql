-- Function: auth.fn_edit_rol(integer, character varying, character varying, character varying, integer, integer)

--

CREATE FUNCTION auth.fn_edit_rol(p_id integer, p_name character varying, p_slug character varying, p_description character varying, p_updated_by integer, p_company_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    DECLARE
        v_rol_id INTEGER;
        v_count INTEGER;
    BEGIN
    
        
        -- Comprobar si ya existe otro registro con el mismo nombre
        SELECT COUNT(*)
        INTO v_count
        FROM roles
        WHERE name = p_name 
        AND id <> p_id
        AND company_id = p_company_id;
    
        -- Si no existe otro registro con el mismo nombre, proceder con la actualización
        IF v_count = 0 THEN
            UPDATE roles
            SET
                name = p_name,
                slug = p_slug,
                description = p_description,
                updated_by = p_updated_by,
                updated_at = now()
            WHERE id = p_id
            AND company_id = p_company_id
            RETURNING id INTO v_rol_id;
    
            RETURN v_rol_id;
        ELSE
            -- Si ya existe otro registro con el mismo nombre, devolver NULL
            RETURN NULL;
        END IF;
    END;
    $$;


ALTER FUNCTION auth.fn_edit_rol(p_id integer, p_name character varying, p_slug character varying, p_description character varying, p_updated_by integer, p_company_id integer) OWNER TO postgres;

--
