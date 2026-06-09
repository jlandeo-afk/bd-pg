-- Function: exams.fn_exam_type(character varying)

--

CREATE FUNCTION exams.fn_exam_type(p_description character varying) RETURNS TABLE(id bigint, name character varying)
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    RETURN QUERY
                    SELECT
                        tmt.id,
                        tmt.name
                    FROM materials.type_material tm

                    INNER JOIN academic.detail_week_type_mat AS dwtm
                        ON tm.id = dwtm.type_material_id AND dwtm.fl_status = TRUE

                    INNER JOIN materials.material_exam_area_week meaw
                        ON dwtm.id = meaw.week_type_material_id AND meaw.fl_status = TRUE

                    INNER JOIN materials.type_material_template tmt
                        ON tm.type_material_template_id = tmt.id AND tmt.fl_status = TRUE

                    WHERE tm.fl_status = true
                    AND (
                        p_description IS NULL
                        OR LOWER(tm.description) LIKE '%' || LOWER(p_description) || '%'
                    )
                    GROUP BY tmt.id, tmt.name
                    ORDER BY tmt.id ASC;
                END;
            $$;


ALTER FUNCTION exams.fn_exam_type(p_description character varying) OWNER TO postgres;

--
