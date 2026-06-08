-- Function: odiseo.fn_delete_course_subcategory(bigint, bigint)

--

CREATE FUNCTION odiseo.fn_delete_course_subcategory(p_assigned_sub_id bigint, p_user_id bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
            BEGIN
                UPDATE course_assigned_subcategories
                SET deleted_at = CURRENT_TIMESTAMP, deleted_by = p_user_id
                WHERE id = p_assigned_sub_id;
            END;
            $$;


ALTER FUNCTION odiseo.fn_delete_course_subcategory(p_assigned_sub_id bigint, p_user_id bigint) OWNER TO postgres;

--
