-- Function: exams.fn_delete_area(integer, integer)

--

CREATE FUNCTION exams.fn_delete_area(p_id integer, p_deleted_by integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_area_id INTEGER;
            BEGIN
                UPDATE exams.area
                SET
                    fl_status = false,
                    deleted_by = p_deleted_by,
                    deleted_at = now()
                WHERE
                    id = p_id
                RETURNING id INTO v_area_id;

                RETURN v_area_id;
            END;
            $$;


ALTER FUNCTION exams.fn_delete_area(p_id integer, p_deleted_by integer) OWNER TO postgres;

--
