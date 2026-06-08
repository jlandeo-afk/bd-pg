-- Function: odiseo.fn_find_syllabus_text(bigint, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_find_syllabus_text(p_syllabus_id bigint, p_course_id bigint, p_company_id bigint) RETURNS TABLE(category character varying, category_id integer, weeks jsonb)
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    RETURN QUERY
                    WITH
                    distribution_counts AS (
                        SELECT
                            stw.week,
                            st.type_text_id category_id,
                            st.type_text_subcategory_id subcategory_id,
                            std.type_material_id,
                            COALESCE(SUM(stds.quantity), count(st.id)) AS total
                        FROM
                            syllabus_texts st
                        JOIN
                            syllabus_text_distributions std ON std.id = st.syllabus_text_distribution_id
                        JOIN
                            syllabus_text_weeks stw ON stw.id = std.syllabus_text_week_id
                        LEFT JOIN 
                            syllabus_text_detail stds ON st.id = stds.syllabus_text_id AND stds.deleted_by IS NULL
                        WHERE
                            stw.syllabus_id = p_syllabus_id
                            AND st.fl_status = true
                            AND std.fl_status = true
                            AND stw.fl_status = true
                            AND st.company_id = p_company_id
                        GROUP BY
                            stw.week, st.type_text_id, st.type_text_subcategory_id, std.type_material_id
                    ),
                    subcategories_with_distributions AS (
                        SELECT
                            dc.week,
                            dc.category_id,
                            dc.subcategory_id,
                            jsonb_agg(
                                jsonb_build_object('name', tm.description, 'total', dc.total)
                                ORDER BY tm.id
                            ) AS distributions_json
                        FROM
                            distribution_counts dc
                        JOIN
                            type_material tm ON tm.id = dc.type_material_id
                        GROUP BY
                            dc.week, dc.category_id, dc.subcategory_id
                    ),
                    weeks_with_subcategories AS (
                        SELECT
                            swd.week,
                            swd.category_id,
                            jsonb_agg(
                                jsonb_build_object(
                                    'name', tts.name,
                                    'distributions', swd.distributions_json,
                                    'id', tts.id
                                )
                                ORDER BY tts.id
                            ) AS subcategories_json
                        FROM
                            subcategories_with_distributions swd
                        JOIN
                            type_text_subcategories tts ON tts.id = swd.subcategory_id
                        GROUP BY
                            swd.week, swd.category_id
                    ),
                    course_assigned_categories_cte as (
                        SELECT 
                            cac.type_text_id, 
                            tt.name 
                        FROM course_assigned_categories cac
                        LEFT JOIN  type_text tt on tt.id = cac.type_text_id
                        WHERE cac.course_id = p_course_id
                            AND cac.deleted_at is null
                            and tt.fl_status = true
                    )
                    SELECT
                        cats.name AS category,
                        cats.type_text_id AS category_id,
                        jsonb_agg(
                            jsonb_build_object(
                                'week', all_weeks.week,
                                'subcategories', COALESCE(wws.subcategories_json, '[]'::jsonb)
                            ) ORDER BY all_weeks.week
                        ) AS weeks
                    FROM
                        (SELECT type_text_id, name FROM course_assigned_categories_cte) AS cats
                    CROSS JOIN
                        (SELECT generate_series(1, (SELECT cy.weeks FROM syllabus s JOIN cycle cy ON s.cycle_id = cy.id WHERE s.id = p_syllabus_id)) AS week) AS all_weeks
                    LEFT JOIN
                        weeks_with_subcategories wws ON wws.category_id = cats.type_text_id AND wws.week = all_weeks.week
                    GROUP BY
                        cats.type_text_id, cats.name
                    ORDER BY
                        cats.type_text_id;

                END;
            $$;


ALTER FUNCTION odiseo.fn_find_syllabus_text(p_syllabus_id bigint, p_course_id bigint, p_company_id bigint) OWNER TO postgres;

--
