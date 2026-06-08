-- Function: odiseo.fn_validate_parent_type_mat(smallint, jsonb)

--

CREATE FUNCTION odiseo.fn_validate_parent_type_mat(p_parent_type_mat_id smallint, p_type_materials jsonb) RETURNS TABLE(not_type_materials smallint[])
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_type_material_id SMALLINT;
            v_p_type_material_template_id SMALLINT;
            v_type_material_template_id SMALLINT;
            v_validate_relation BIGINT;
            v_ids SMALLINT[] := ARRAY[]::SMALLINT[];
        BEGIN
            SELECT tmp.type_material_template_id INTO v_p_type_material_template_id
            FROM type_material tmp
            WHERE tmp.id = p_parent_type_mat_id LIMIT 1;

            FOR v_type_material_id IN SELECT * FROM jsonb_array_elements(p_type_materials) LOOP
                SELECT tm.type_material_template_id INTO v_type_material_template_id
                FROM type_material tm
                WHERE id = v_type_material_id LIMIT 1;

                IF p_parent_type_mat_id <> v_type_material_id THEN
                    SELECT id INTO v_validate_relation FROM type_material_bound
                    WHERE type_material_template_id = v_p_type_material_template_id
                    AND type_material_template_extra_id = v_type_material_template_id
                    AND fl_status = true LIMIT 1;

                    IF v_validate_relation IS NULL THEN
                        v_ids := array_append(v_ids, v_type_material_id);
                    END IF;
                END IF;
            END LOOP;

            RETURN QUERY SELECT v_ids;
        END;
        $$;


ALTER FUNCTION odiseo.fn_validate_parent_type_mat(p_parent_type_mat_id smallint, p_type_materials jsonb) OWNER TO postgres;

--
