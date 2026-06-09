-- Function: auth.fn_create_rol(character varying, character varying, character varying, integer, integer)

CREATE OR REPLACE FUNCTION auth.fn_create_rol(p_name character varying, p_slug character varying, p_description character varying, p_created_by integer, p_company_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    DECLARE
        v_new_rol_id INTEGER;
        v_count INTEGER;
    BEGIN
        -- Comprobar si ya existe un registro con el mismo nombre
        SELECT COUNT(*)
        INTO v_count
        FROM roles
        WHERE LOWER(name) = LOWER(p_name) AND company_id = p_company_id;
    
        -- Si no existe un registro con el mismo nombre, proceder con la inserción
        IF v_count = 0 THEN
            INSERT INTO roles (name, slug, description, created_by, created_at, company_id)
            VALUES (p_name, p_slug, p_description, p_created_by, now(), p_company_id)
            RETURNING id INTO v_new_rol_id;
    
            RETURN v_new_rol_id;
        ELSE
            -- Si ya existe un registro con el mismo nombre, devolver NULL
            RETURN NULL;
        END IF;
    END;
    $$;

ALTER FUNCTION auth.fn_create_rol(p_name character varying, p_slug character varying, p_description character varying, p_created_by integer, p_company_id integer) OWNER TO postgres;
