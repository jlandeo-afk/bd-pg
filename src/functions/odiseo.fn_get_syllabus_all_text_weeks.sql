-- Function: odiseo.fn_get_syllabus_all_text_weeks(integer, integer, integer)

--

CREATE FUNCTION odiseo.fn_get_syllabus_all_text_weeks(p_cycle_id integer, p_company_id integer, p_course_id integer) RETURNS TABLE(category character varying, category_id bigint, weeks jsonb)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH categories AS (
        SELECT tt.id, tt.name
        FROM course_assigned_categories cac
        JOIN type_text tt ON tt.id = cac.type_text_id AND cac.course_id = p_course_id
        WHERE cac.deleted_at IS NULL
        AND tt.fl_status = true
    ),
    cycle_weeks AS (
        SELECT cy.weeks
        FROM cycle cy
        WHERE cy.id = p_cycle_id
        AND cy.company_id = p_company_id
    ),
    weeks AS (
        SELECT generate_series(1, (SELECT cw.weeks FROM cycle_weeks cw)) AS week
    ),
    category_weeks AS (
        SELECT 
            c.id,
            c.name,
            w.week
        FROM categories c
        CROSS JOIN weeks w
    )

    SELECT
        cw.name AS category,
        cw.id AS category_id,
        jsonb_agg(
            jsonb_build_object(
                'week', cw.week,
                'subcategories', '[]'::jsonb
            )
            ORDER BY cw.week
        ) AS weeks
    FROM category_weeks cw
    GROUP BY cw.id, cw.name
    ORDER BY cw.id;
END;
$$;


ALTER FUNCTION odiseo.fn_get_syllabus_all_text_weeks(p_cycle_id integer, p_company_id integer, p_course_id integer) OWNER TO postgres;

--
