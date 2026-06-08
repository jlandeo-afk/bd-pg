-- Function: odiseo.fn_delete_cycle(integer, integer)

--

CREATE FUNCTION odiseo.fn_delete_cycle(p_id integer, p_deleted_by integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_cycle_id INTEGER;
            BEGIN
                UPDATE odiseo.cycle
                SET
                    fl_status = false,
                    deleted_by = p_deleted_by,
                    deleted_at = now()
                WHERE
                    id = p_id
                RETURNING id INTO v_cycle_id;

                RETURN v_cycle_id;
            END;
            $$;


ALTER FUNCTION odiseo.fn_delete_cycle(p_id integer, p_deleted_by integer) OWNER TO postgres;

--
