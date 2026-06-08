-- Function: odiseo.fn_delete_headquarter(bigint, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_delete_headquarter(p_headquarter_id bigint, p_company_id bigint, p_deleted_by bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_company_count BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_company_count
    FROM company_headquarters
    WHERE headquarter_id = p_headquarter_id AND deleted_at IS NULL;

    UPDATE company_headquarters
    SET deleted_by = p_deleted_by,
        deleted_at = NOW()
    WHERE headquarter_id = p_headquarter_id
      AND company_id = p_company_id
      AND deleted_at IS NULL;

    IF v_company_count <= 1 THEN
        UPDATE headquarters
        SET fl_status = false,
            deleted_by = p_deleted_by,
            deleted_at = NOW()
        WHERE id = p_headquarter_id;
    END IF;

    RETURN FOUND;
END;
$$;


ALTER FUNCTION odiseo.fn_delete_headquarter(p_headquarter_id bigint, p_company_id bigint, p_deleted_by bigint) OWNER TO postgres;

--
