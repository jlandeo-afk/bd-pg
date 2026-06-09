-- Function: exams.fn_create_area(character varying, character varying, character varying, integer)

--

CREATE FUNCTION exams.fn_create_area(p_code character varying, p_slug character varying, p_description character varying, p_created_by integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_new_area_id INTEGER;
                v_count INTEGER;
            BEGIN
                SELECT COUNT(*)
                INTO v_count
                FROM exams.area
                WHERE LOWER(description) = LOWER(p_description)
                AND fl_status = true;

                IF v_count = 0 THEN
                    INSERT INTO exams.area (code, slug, description, created_by, created_at)
                    VALUES (p_code, p_slug, p_description, p_created_by, now())
                    RETURNING id INTO v_new_area_id;

                    RETURN v_new_area_id;
                ELSE
                    RETURN NULL;
                END IF;
            END;
            $$;


ALTER FUNCTION exams.fn_create_area(p_code character varying, p_slug character varying, p_description character varying, p_created_by integer) OWNER TO postgres;

--
