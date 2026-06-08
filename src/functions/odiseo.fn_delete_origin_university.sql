-- Function: odiseo.fn_delete_origin_university(smallint, bigint)

--

CREATE FUNCTION odiseo.fn_delete_origin_university(p_id smallint, p_deleted_by bigint) RETURNS TABLE(v_validated boolean, v_id smallint)
    LANGUAGE plpgsql
    AS $$
    DECLARE
        v_exits_id BIGINT;
        v_material_id BIGINT;
    BEGIN
        SELECT id INTO v_exits_id FROM origin_question
        WHERE university_id = p_id
        AND fl_status = true
        LIMIT 1;

        SELECT id INTO v_material_id FROM material
        WHERE university_id = p_id
        AND fl_status = true
        LIMIT 1;

        IF v_exits_id IS NULL AND v_material_id IS NULL THEN
            UPDATE origin_university
            SET deleted_by = p_deleted_by, deleted_at = now()
            WHERE id = p_id
            RETURNING id INTO v_id;

            UPDATE "option" SET university_ids = array_remove(university_ids, p_id);
            UPDATE modality SET university_ids = array_remove(university_ids, p_id);

            RETURN QUERY SELECT TRUE, v_id;
        ELSE
            RETURN QUERY SELECT FALSE, 0::SMALLINT;
        END IF;
    END;
    $$;


ALTER FUNCTION odiseo.fn_delete_origin_university(p_id smallint, p_deleted_by bigint) OWNER TO postgres;

--
