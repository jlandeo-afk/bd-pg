-- Function: odiseo.fn_update_course_category(bigint, character varying, bigint)

--

CREATE FUNCTION odiseo.fn_update_course_category(p_assigned_cat_id bigint, p_new_category_name character varying, p_user_id bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_type_text_id INT;
            BEGIN
                SELECT type_text_id INTO v_type_text_id 
                FROM course_assigned_categories 
                WHERE id = p_assigned_cat_id;

                UPDATE type_text 
                SET name = p_new_category_name 
                WHERE id = v_type_text_id;

                UPDATE course_assigned_categories 
                SET updated_by = p_user_id, 
                    updated_at = CURRENT_TIMESTAMP 
                WHERE id = p_assigned_cat_id;

                RETURN p_assigned_cat_id;
            END;
            $$;


ALTER FUNCTION odiseo.fn_update_course_category(p_assigned_cat_id bigint, p_new_category_name character varying, p_user_id bigint) OWNER TO postgres;

--
