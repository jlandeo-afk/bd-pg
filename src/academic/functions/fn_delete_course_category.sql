-- Function: academic.fn_delete_course_category(bigint, bigint)

--

CREATE FUNCTION academic.fn_delete_course_category(p_assigned_cat_id bigint, p_user_id bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
            BEGIN
                UPDATE course_assigned_categories
                SET deleted_at = CURRENT_TIMESTAMP, deleted_by = p_user_id
                WHERE id = p_assigned_cat_id;

                UPDATE course_assigned_subcategories
                SET deleted_at = CURRENT_TIMESTAMP, deleted_by = p_user_id
                WHERE course_assigned_category_id = p_assigned_cat_id;
            END;
            $$;


ALTER FUNCTION academic.fn_delete_course_category(p_assigned_cat_id bigint, p_user_id bigint) OWNER TO postgres;

--
