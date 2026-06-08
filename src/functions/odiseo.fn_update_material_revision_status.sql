-- Function: odiseo.fn_update_material_revision_status(bigint, character varying, bigint)

--

CREATE FUNCTION odiseo.fn_update_material_revision_status(p_revision_id bigint, p_new_status character varying, p_user_id bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_old_status varchar;
    v_course_rec record;
BEGIN
    SELECT status INTO v_old_status
    FROM material_revisions
    WHERE id = p_revision_id AND deleted_at IS NULL
    FOR UPDATE;

    IF v_old_status IS DISTINCT FROM p_new_status THEN
        UPDATE material_revisions
        SET status = p_new_status,
            updated_at = NOW(),
            updated_by = p_user_id,
            verify_date = CASE WHEN p_new_status = 'verified' THEN NOW() ELSE verify_date END,
            verified_by = CASE WHEN p_new_status = 'verified' THEN p_user_id ELSE verified_by END
        WHERE id = p_revision_id;

        INSERT INTO material_revision_histories (
            material_revision_id, old_status, new_status, changed_by, changed_at
        ) VALUES (
            p_revision_id, v_old_status, p_new_status, p_user_id, NOW()
        );
    END IF;

    -- Propagación a hijos "Confirmar Todo"
    IF p_new_status = 'verified' THEN
        FOR v_course_rec IN 
            SELECT id, status, course_id
            FROM material_revision_courses
            WHERE material_revision_id = p_revision_id 
              AND status != 'verified' 
              AND deleted_at IS NULL
            FOR UPDATE
        LOOP
            UPDATE material_revision_courses
            SET status = 'verified',
                verify_date = NOW(),
                verified_by = p_user_id,
                updated_at = NOW(),
                updated_by = p_user_id
            WHERE id = v_course_rec.id;
        END LOOP;
    END IF;
END;
$$;


ALTER FUNCTION odiseo.fn_update_material_revision_status(p_revision_id bigint, p_new_status character varying, p_user_id bigint) OWNER TO postgres;

--
