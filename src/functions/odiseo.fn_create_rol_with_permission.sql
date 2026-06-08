-- Function: odiseo.fn_create_rol_with_permission(character varying, character varying, character varying, jsonb, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_create_rol_with_permission(p_name character varying, p_slug character varying, p_description character varying, p_permissions jsonb, p_created_by bigint, p_company_id bigint) RETURNS TABLE(id bigint)
    LANGUAGE plpgsql
    AS $$
    DECLARE
        v_count INTEGER;
    BEGIN
        -- Comprobar si ya existe un registro con el mismo nombre
        SELECT COUNT(*)
        INTO v_count
        FROM roles r
        WHERE LOWER(r.name) = LOWER(p_name)
            AND r.company_id = p_company_id;

        IF v_count > 0 THEN
            RAISE EXCEPTION 'El rol % ya existe.', p_name;
        END IF;

        RETURN QUERY
        WITH create_rol AS (
            INSERT INTO roles as r (
                name,
                slug,
                description,
                created_by,
                company_id
            )
            VALUES (
                p_name,
                p_slug,
                p_description,
                p_created_by,
                p_company_id
            )
            RETURNING r.id
        ), insert_permissions AS (
            INSERT INTO roles_permissions (
                rol_id,
                permission_id,
                created_by,
                company_id
            )
            SELECT
                create_rol.id,
                (p.value)::BIGINT,
                p_created_by,
                p_company_id
            FROM create_rol
            CROSS JOIN jsonb_array_elements(p_permissions) p(value)
        )
        SELECT cr.id FROM create_rol cr;

    END;
    $$;


ALTER FUNCTION odiseo.fn_create_rol_with_permission(p_name character varying, p_slug character varying, p_description character varying, p_permissions jsonb, p_created_by bigint, p_company_id bigint) OWNER TO postgres;

--
