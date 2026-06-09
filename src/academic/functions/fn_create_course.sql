-- Function: academic.fn_create_course(character varying, bigint, boolean, jsonb, bigint, bigint)

--

CREATE FUNCTION academic.fn_create_course(p_name character varying, p_area_id bigint, p_fl_pseudo_course boolean, p_courses jsonb, p_type_text_template_id bigint, p_created_by bigint) RETURNS TABLE(v_validated boolean, v_id bigint)
    LANGUAGE plpgsql
    AS $$
    DECLARE
        v_exists_id BIGINT;
        v_code VARCHAR;
        v_new_id BIGINT;
        v_course_id SMALLINT;
        v_count SMALLINT := 1;
        v_type_text_template_id BIGINT;
    BEGIN
        SELECT id INTO v_exists_id
        FROM course
        WHERE LOWER(
                REGEXP_REPLACE(
                    TRIM(unaccent(name)),
                    '\s+',
                    ' ',
                    'g'
                )
            ) = LOWER(
                REGEXP_REPLACE(
                    TRIM(unaccent(p_name)),
                    '\s+',
                    ' ',
                    'g'
                )
            )
        AND fl_status = true
        LIMIT 1;

        IF v_exists_id IS NULL THEN
            SELECT COALESCE(MAX(CAST(code AS INTEGER) + 1), 0) INTO v_code FROM course;

            INSERT INTO course (code, name, area_id, fl_pseudo_course, created_by, created_at, type_text_template_id,apply_text)
            VALUES (v_code, REGEXP_REPLACE(p_name,'\s+',
                    ' ',
                    'g'
                ), p_area_id, p_fl_pseudo_course, p_created_by, now(), p_type_text_template_id, CASE 
                WHEN p_type_text_template_id IS NULL THEN false
                ELSE true
            END)
            RETURNING id,type_text_template_id INTO v_new_id,v_type_text_template_id;

            INSERT INTO question_correlative(
                course_id,
                correlative,
                created_at,
                apply_text
            )VALUES (
                v_new_id,
                0,
                now(),
                CASE WHEN p_type_text_template_id IS NULL THEN false ELSE true END
            );


            if p_fl_pseudo_course THEN
                FOR v_course_id IN
                    SELECT * FROM jsonb_array_elements(p_courses)
                LOOP
                    INSERT INTO course_pseudo_courses
                    (pseudo_course_id, course_id, "order", created_by, created_at)
                    VALUES (v_new_id, v_course_id, v_count, p_created_by, now());

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


ALTER FUNCTION academic.fn_create_course(p_name character varying, p_area_id bigint, p_fl_pseudo_course boolean, p_courses jsonb, p_type_text_template_id bigint, p_created_by bigint) OWNER TO postgres;

--
