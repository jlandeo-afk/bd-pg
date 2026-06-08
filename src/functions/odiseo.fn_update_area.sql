-- Function: odiseo.fn_update_area(integer, character varying, character varying, integer)

--

CREATE FUNCTION odiseo.fn_update_area(p_id integer, p_slug character varying, p_description character varying, p_updated_by integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_area_id INTEGER;
                v_count INTEGER;
            BEGIN
                SELECT COUNT(*)
                INTO v_count
                FROM odiseo.area
                WHERE LOWER(description) = LOWER(p_description) AND id <> p_id;

                IF v_count = 0 THEN
                    UPDATE odiseo.area
                    SET
                    slug = p_slug,
                    description = p_description,
                    updated_by = p_updated_by,
                    updated_at = now()
                    WHERE
                        id = p_id
                    RETURNING id INTO v_area_id;

                    RETURN v_area_id;
                ELSE
                    RETURN NULL;
                END IF;

            END;
            $$;


ALTER FUNCTION odiseo.fn_update_area(p_id integer, p_slug character varying, p_description character varying, p_updated_by integer) OWNER TO postgres;

--
