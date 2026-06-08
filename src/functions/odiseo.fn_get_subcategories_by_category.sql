-- Function: odiseo.fn_get_subcategories_by_category(bigint)

--

CREATE FUNCTION odiseo.fn_get_subcategories_by_category(p_assigned_cat_id bigint) RETURNS TABLE(id bigint, subcategory_name character varying, subcategory_assigned_id bigint)
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                        RETURN QUERY
                        SELECT tts.id, tts.name AS subcategory_name, s.id AS subcategory_assigned_id
                        FROM course_assigned_subcategories s
                        JOIN type_text_subcategories tts ON s.subcategory_id = tts.id
                        WHERE s.course_assigned_category_id = p_assigned_cat_id 
                        AND s.deleted_at IS NULL;
                    END;
                    $$;


ALTER FUNCTION odiseo.fn_get_subcategories_by_category(p_assigned_cat_id bigint) OWNER TO postgres;

--
