-- Function: questions.fn_delete_parent_question(bigint, bigint)

--

CREATE FUNCTION questions.fn_delete_parent_question(p_parent_id bigint, p_deleted_by bigint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
            BEGIN
                UPDATE questions.parent_question SET status = 'ARCH', fl_status = false, deleted_by = p_deleted_by, deleted_at = now() WHERE id = p_parent_id;

                UPDATE questions.question SET fl_status = false, deleted_by = p_deleted_by, deleted_at = now() WHERE parent_id = p_parent_id;

                RETURN p_parent_id;
            END;
            $$;


ALTER FUNCTION questions.fn_delete_parent_question(p_parent_id bigint, p_deleted_by bigint) OWNER TO postgres;

--
