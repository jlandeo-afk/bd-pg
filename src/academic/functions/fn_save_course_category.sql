-- Function: academic.fn_save_course_category(bigint, character varying, bigint)

--

CREATE FUNCTION academic.fn_save_course_category(p_course_id bigint, p_category_name character varying, p_user_id bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$ 
            DECLARE
                v_type_id INT;
                v_assigned_cat_id BIGINT;
            BEGIN
                INSERT INTO type_text (name, created_at, created_by) VALUES (p_category_name, CURRENT_TIMESTAMP, p_user_id) RETURNING id INTO v_type_id;

                INSERT INTO course_assigned_categories (
                    course_id, type_text_id, created_by, created_at, updated_at
                )
                VALUES (
                    p_course_id, v_type_id, p_user_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
                )
                RETURNING id INTO v_assigned_cat_id;

                RETURN v_assigned_cat_id;
            END;
            $$;


ALTER FUNCTION academic.fn_save_course_category(p_course_id bigint, p_category_name character varying, p_user_id bigint) OWNER TO postgres;

--
