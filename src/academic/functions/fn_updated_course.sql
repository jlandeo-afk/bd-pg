-- Function: academic.fn_updated_course(bigint, character varying, bigint, jsonb, bigint, bigint)

--

CREATE FUNCTION academic.fn_updated_course(p_id bigint, p_name character varying, p_area_id bigint, p_courses jsonb, p_type_text_template_id bigint, p_updated_by bigint) RETURNS TABLE(v_validated boolean, v_id bigint)
    LANGUAGE plpgsql
    AS $$
    DECLARE
        v_exists_id BIGINT;
        v_code VARCHAR;
        v_new_id BIGINT;
        v_fl_pseudo_course BOOLEAN;
        v_course_id SMALLINT;
        v_validate_course BIGINT;
        v_count SMALLINT := 1;
    BEGIN
        SELECT id INTO v_exists_id
        FROM course
        WHERE unaccent( name) = unaccent(p_name)
        AND id <> p_id
        AND fl_status = true
        LIMIT 1;

        IF v_exists_id IS NULL THEN
            UPDATE course
            SET name = p_name, area_id = COALESCE(p_area_id, area_id), updated_by = p_updated_by, updated_at = now(), type_text_template_id = p_type_text_template_id, apply_text = CASE 
                WHEN p_type_text_template_id IS NULL THEN FALSE
                ELSE TRUE
                END
            WHERE id = p_id
            RETURNING id, fl_pseudo_course INTO v_new_id, v_fl_pseudo_course;

            if v_fl_pseudo_course THEN
                -- Eliminar los que no se manda
                UPDATE course_pseudo_courses cpc
                SET fl_status = false, deleted_by = p_updated_by, deleted_at = NOW()
                WHERE cpc.course_id NOT IN (SELECT value::SMALLINT FROM jsonb_array_elements_text(p_courses))
                AND cpc.pseudo_course_id = p_id
                AND cpc.fl_status IS TRUE;

                FOR v_course_id IN
                    SELECT * FROM jsonb_array_elements(p_courses)
                LOOP
                    SELECT cpcv.id INTO v_validate_course
                    FROM course_pseudo_courses cpcv
                    WHERE cpcv.pseudo_course_id = p_id AND cpcv.course_id = v_course_id;

                    IF v_validate_course IS NULL THEN
                        INSERT INTO course_pseudo_courses
                        (pseudo_course_id, course_id, "order", created_by, created_at)
                        VALUES (v_new_id, v_course_id, v_count, p_updated_by, now());
                    ELSE
                        UPDATE course_pseudo_courses cpcu
                        SET fl_status = true, "order" = v_count, deleted_by = null, deleted_at = null
                        WHERE cpcu.id = v_validate_course;
                    END IF;

                    -- Incrementa el contador
                    v_count := v_count + 1;
                END LOOP;
            END IF;

            RETURN QUERY SELECT TRUE, v_new_id;
        ELSE
            RETURN QUERY SELECT FALSE, 0::BIGINT;
        END IF;
    END;     
    $$;


ALTER FUNCTION academic.fn_updated_course(p_id bigint, p_name character varying, p_area_id bigint, p_courses jsonb, p_type_text_template_id bigint, p_updated_by bigint) OWNER TO postgres;

--
