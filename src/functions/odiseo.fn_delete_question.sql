-- Function: odiseo.fn_delete_question(bigint, bigint)

--

CREATE FUNCTION odiseo.fn_delete_question(p_id_question bigint, p_deleted_by bigint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
            BEGIN
                UPDATE odiseo.question SET fl_status = false, deleted_by = p_deleted_by, deleted_at = now() WHERE id = p_id_question;

                RETURN p_id_question;
            END;
            $$;


ALTER FUNCTION odiseo.fn_delete_question(p_id_question bigint, p_deleted_by bigint) OWNER TO postgres;

--
