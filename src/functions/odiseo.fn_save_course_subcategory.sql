-- Function: odiseo.fn_save_course_subcategory(bigint, character varying, integer, bigint)

--

CREATE FUNCTION odiseo.fn_save_course_subcategory(p_assigned_cat_id bigint, p_subcategory_name character varying, p_subcategory_id integer, p_user_id bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_sub_id INT;
                v_assigned_sub_id BIGINT;
            BEGIN
                IF p_subcategory_id IS NOT NULL THEN
                    v_sub_id := p_subcategory_id;
                ELSE
                    INSERT INTO type_text_subcategories (name, created_at, created_by) 
                    VALUES (p_subcategory_name, CURRENT_TIMESTAMP, p_user_id) 
                    RETURNING id INTO v_sub_id;
                END IF;

                INSERT INTO course_assigned_subcategories (
                    course_assigned_category_id, subcategory_id, created_by, created_at, updated_at
                ) VALUES (
                    p_assigned_cat_id, v_sub_id, p_user_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
                )
                RETURNING id INTO v_assigned_sub_id;

                RETURN v_assigned_sub_id;
            END;
            $$;


ALTER FUNCTION odiseo.fn_save_course_subcategory(p_assigned_cat_id bigint, p_subcategory_name character varying, p_subcategory_id integer, p_user_id bigint) OWNER TO postgres;

--
