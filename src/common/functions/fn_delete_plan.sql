-- Function: common.fn_delete_plan(bigint, bigint)

--

CREATE FUNCTION common.fn_delete_plan(p_id bigint, p_deleted_by bigint) RETURNS TABLE(v_id bigint)
    LANGUAGE plpgsql
    AS $$
			DECLARE
				v_exits_id BIGINT;
            BEGIN
                UPDATE odiseo."plans"
                SET fl_status = false, deleted_by = p_deleted_by, deleted_at = now()
                WHERE id = p_id
                RETURNING id INTO v_id;

                RETURN QUERY SELECT v_id;
            END;
            $$;


ALTER FUNCTION common.fn_delete_plan(p_id bigint, p_deleted_by bigint) OWNER TO postgres;

--
