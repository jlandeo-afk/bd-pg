-- Function: odiseo.fn_delete_level(integer, integer)

--

CREATE FUNCTION odiseo.fn_delete_level(p_id integer, p_deleted_by integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_level_id INTEGER;
            BEGIN
                UPDATE odiseo.level
                SET
                    fl_status = false,
                    deleted_by = p_deleted_by,
                    deleted_at = now()
                WHERE
                    id = p_id
                RETURNING id INTO v_level_id;

                RETURN v_level_id;
            END;
            $$;


ALTER FUNCTION odiseo.fn_delete_level(p_id integer, p_deleted_by integer) OWNER TO postgres;

--
