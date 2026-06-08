-- Function: odiseo.fn_update_level(integer, character varying, character varying, jsonb, integer)

--

CREATE FUNCTION odiseo.fn_update_level(p_id integer, p_name character varying, p_description character varying, p_courses jsonb, p_updated_by integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_exits_id INTEGER;
                v_exits_cl INTEGER;
                v_course_id INTEGER;
				v_code TEXT;
                v_fl_status BOOL;
            BEGIN
                SELECT id
                INTO v_exits_id
                FROM odiseo.level
                WHERE LOWER(name) = LOWER(p_name)
				AND LOWER(description) = LOWER(p_description)
                AND fl_status = true
                AND id <> p_id;

                IF v_exits_id IS NULL THEN
					UPDATE odiseo.level
					SET name = p_name, description = p_description, updated_by = p_updated_by, updated_at = now()
					WHERE id = p_id;

					FOR v_course_id IN SELECT * FROM jsonb_array_elements_text(p_courses) LOOP
						SELECT cl.id, cl.fl_status
                        INTO v_exits_cl, v_fl_status
						FROM odiseo.course_level cl
						WHERE cl.course_id = v_course_id
						AND cl.level_id = p_id;

						IF v_exits_cl IS NULL THEN
							SELECT CONCAT(c.code, '-', LPAD(CAST(COUNT(cl.*) + 1 AS TEXT), 3, '0')) INTO v_code
							FROM odiseo.course_level cl
							RIGHT JOIN odiseo.course c ON cl.course_id = c.id
							WHERE c.id = v_course_id::SMALLINT
							GROUP BY c.code;

							INSERT INTO odiseo.course_level (code, level_id, course_id, created_by, created_at)
							VALUES (v_code, p_id, v_course_id::SMALLINT, p_updated_by, now());
                        ELSE
                            IF v_fl_status IS FALSE THEN
                                UPDATE odiseo.course_level SET fl_status = true, updated_by = p_updated_by, updated_at = now(), deleted_by = null, deleted_at = null
                                WHERE id = v_exits_cl;
                            END IF;
						END IF;
	                END LOOP;

                    UPDATE odiseo.course_level SET fl_status = false, deleted_by = p_updated_by, deleted_at = now()
                    WHERE course_id NOT IN (
                        SELECT jsonb_array_elements_text(p_courses)::SMALLINT
                    )
                    AND level_id = p_id;

                    RETURN p_id;
                ELSE
                    RETURN NULL;
                END IF;
            END;
            $$;


ALTER FUNCTION odiseo.fn_update_level(p_id integer, p_name character varying, p_description character varying, p_courses jsonb, p_updated_by integer) OWNER TO postgres;

--
