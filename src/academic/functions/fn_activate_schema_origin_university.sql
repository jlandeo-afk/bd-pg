-- Function: academic.fn_activate_schema_origin_university(bigint, bigint)

--

CREATE FUNCTION academic.fn_activate_schema_origin_university(p_id bigint, p_updated_by bigint) RETURNS TABLE(v_validated boolean, v_id bigint)
    LANGUAGE plpgsql
    AS $$
    DECLARE
        v_exists_id BIGINT;
        v_material_id BIGINT;
    BEGIN
        SELECT id INTO v_exists_id
        FROM origin_university
        WHERE id = p_id
        AND deleted_by IS NULL
        LIMIT 1;

        SELECT id INTO v_material_id FROM material
        WHERE university_id = p_id
        AND fl_status = true
        LIMIT 1;

        IF v_exists_id IS NOT NULL AND v_material_id IS NULL THEN
            UPDATE origin_university
            SET fl_active = NOT fl_active,
                updated_by = p_updated_by,
                updated_at = now()
            WHERE id = p_id
            RETURNING id INTO v_id;
            RETURN QUERY SELECT TRUE, v_id;
        ELSE
            RETURN QUERY SELECT FALSE, 0::BIGINT;
        END IF;
    END;
    $$;


ALTER FUNCTION academic.fn_activate_schema_origin_university(p_id bigint, p_updated_by bigint) OWNER TO postgres;

--
