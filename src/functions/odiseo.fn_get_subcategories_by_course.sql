-- Function: odiseo.fn_get_subcategories_by_course(bigint, bigint)

--

CREATE FUNCTION odiseo.fn_get_subcategories_by_course(p_course_id bigint, p_assigned_category_id bigint) RETURNS TABLE(id bigint, subcategory_name character varying)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                WITH excluded_subcategory_names AS (
                    SELECT tts."name"
                    FROM course_assigned_subcategories cas
                    JOIN type_text_subcategories tts ON tts.id = cas.subcategory_id 
                    WHERE cas.course_assigned_category_id = p_assigned_category_id
                    AND cas.deleted_at IS NULL
                ) 
                SELECT DISTINCT tts.id, tts."name" AS subcategory_name
                FROM course_assigned_categories cac
                JOIN course_assigned_subcategories cas ON cas.course_assigned_category_id = cac.id
                JOIN type_text_subcategories tts ON tts.id = cas.subcategory_id 
                WHERE cac.course_id = p_course_id
                AND cac.id != p_assigned_category_id
                AND cac.deleted_at IS NULL 
                AND cas.deleted_at IS NULL
                AND tts."name" NOT IN (SELECT "name" FROM excluded_subcategory_names)
                ORDER BY tts.id;
            END;
            $$;


ALTER FUNCTION odiseo.fn_get_subcategories_by_course(p_course_id bigint, p_assigned_category_id bigint) OWNER TO postgres;

--
