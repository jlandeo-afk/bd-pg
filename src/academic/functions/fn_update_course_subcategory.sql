-- Function: academic.fn_update_course_subcategory(bigint, character varying, bigint)

--

CREATE FUNCTION academic.fn_update_course_subcategory(p_assigned_sub_id bigint, p_new_subcategory_name character varying, p_user_id bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_subcategory_id INT;
            BEGIN
                SELECT subcategory_id INTO v_subcategory_id 
                FROM course_assigned_subcategories 
                WHERE id = p_assigned_sub_id;

                UPDATE type_text_subcategories 
                SET name = p_new_subcategory_name 
                WHERE id = v_subcategory_id;

                UPDATE course_assigned_subcategories 
                SET updated_by = p_user_id, 
                    updated_at = CURRENT_TIMESTAMP 
                WHERE id = p_assigned_sub_id;

                RETURN p_assigned_sub_id;
            END;
            $$;


ALTER FUNCTION academic.fn_update_course_subcategory(p_assigned_sub_id bigint, p_new_subcategory_name character varying, p_user_id bigint) OWNER TO postgres;

--
