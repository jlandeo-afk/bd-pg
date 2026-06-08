-- Function: odiseo.fn_configuration_alternative_delete(bigint, bigint)

--

CREATE FUNCTION odiseo.fn_configuration_alternative_delete(p_id bigint, p_user_id bigint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
                DECLARE
                    v_delete_id integer;
                BEGIN
                    UPDATE odiseo.configuration_alternative
                    SET
                        fl_status = false,
                        deleted_by = p_user_id,
                        deleted_at = now()
                    WHERE
                        id = p_id
                    RETURNING id INTO v_delete_id;

                    RETURN v_delete_id;
                END;
            $$;


ALTER FUNCTION odiseo.fn_configuration_alternative_delete(p_id bigint, p_user_id bigint) OWNER TO postgres;

--
