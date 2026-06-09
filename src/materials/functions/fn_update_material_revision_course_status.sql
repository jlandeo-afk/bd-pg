-- Function: materials.fn_update_material_revision_course_status(bigint, character varying, bigint)

--

CREATE FUNCTION materials.fn_update_material_revision_course_status(p_id bigint, p_new_status character varying, p_user_id bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_old_status varchar;
    v_revision_id bigint;
    v_course_id smallint;
BEGIN
    -- Fetch current state and lock for update
    SELECT status, material_revision_id, course_id 
    INTO v_old_status, v_revision_id, v_course_id
    FROM material_revision_courses
    WHERE id = p_id AND deleted_at IS NULL
    FOR UPDATE;

    IF v_old_status IS DISTINCT FROM p_new_status THEN
        -- Update the course record
        UPDATE material_revision_courses
        SET status = p_new_status,
            updated_at = NOW(),
            updated_by = p_user_id,
            verify_date = CASE WHEN p_new_status = 'verified' THEN NOW() ELSE verify_date END,
            verified_by = CASE WHEN p_new_status = 'verified' THEN p_user_id ELSE verified_by END
        WHERE id = p_id;

        -- Check if all courses for this revision are now verified
        IF p_new_status = 'verified' THEN
            IF NOT EXISTS (
                SELECT 1 
                FROM material_revision_courses 
                WHERE material_revision_id = v_revision_id 
                  AND status != 'verified' 
                  AND deleted_at IS NULL
            ) THEN
                -- Update parent revision
                UPDATE material_revisions
                SET status = 'verified',
                    verify_date = NOW(),
                    verified_by = p_user_id,
                    updated_at = NOW(),
                    updated_by = p_user_id
                WHERE id = v_revision_id;

                -- Record parent history
                INSERT INTO material_revision_histories (
                    material_revision_id, old_status, new_status, changed_by, changed_at
                ) VALUES (
                    v_revision_id, 'pdf_delivered', 'verified', p_user_id, NOW()
                );
            END IF;
        END IF;
    END IF;
END;
$$;


ALTER FUNCTION materials.fn_update_material_revision_course_status(p_id bigint, p_new_status character varying, p_user_id bigint) OWNER TO postgres;

--
