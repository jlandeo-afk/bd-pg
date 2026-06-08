-- Function: odiseo.fn_exam_key_generation(integer, integer, integer, integer, jsonb, integer, integer, integer, integer, integer)

--

CREATE FUNCTION odiseo.fn_exam_key_generation(p_perpage integer, p_npage integer, p_cycle_id integer, p_exam_area_id integer, p_week jsonb, p_cycle_type_id integer, p_cycle_active integer, p_university_id integer, p_exam_type_template_id integer, p_company_id integer) RETURNS TABLE(id bigint, integer_date integer, cycle character varying, cycle_name character varying, formated_date character varying, week smallint, area character varying, exam_type character varying, cycle_type character varying, code character varying, total_count bigint)
    LANGUAGE plpgsql
    AS $$
                DECLARE
                    offset_val INTEGER;
                BEGIN
                    offset_val := p_perpage * (p_npage - 1);

                    RETURN QUERY
                    WITH tbl_exams AS(
                        SELECT
                            meaw.id,
                            (EXTRACT(DAY FROM meaw.created_at - '1900-01-01'::timestamp) + 2)::integer AS integer_date,
                            c.code AS cycle,
                            c.description AS cycle_name,
                            TO_CHAR(meaw.created_at, 'DD/MM/YYYY HH24:MI:SS')::varchar AS formated_date,
                            dwtm.week,
                            COALESCE(ea.short_description, '') AS area,
                            COALESCE(UPPER(CASE 
                                WHEN POSITION(' ' IN tm.description) > 0 THEN 
                                    SUBSTRING(split_part(tm.description, ' ', 1) FROM length(split_part(tm.description, ' ', 1)) - 1 FOR 2)
                                ELSE 
                                    SUBSTRING(tm.description FROM length(tm.description) - 1 FOR 2)
                            END), '')::varchar AS exam_type,
                            COALESCE(ct.name, '') AS cycle_type
                        FROM material_exam_area_week meaw
                        LEFT JOIN exam_area ea
                            ON meaw.area_id = ea.id
                        LEFT JOIN detail_week_type_mat dwtm
                            ON meaw.week_type_material_id = dwtm.id AND dwtm.fl_status IS TRUE
                        INNER JOIN material m ON m.id = dwtm.material_id
                        LEFT JOIN type_material tm
                            ON dwtm.type_material_id = tm.id
                        INNER JOIN type_material_template tmt
                            ON tm.type_material_template_id = tmt.id AND tmt.fl_status = TRUE
                        LEFT JOIN exam_material_configurations emc
                            ON tm.id = emc.type_material_id AND emc.cycle_id = m.cycle_id
                        LEFT JOIN cycle c
                            ON m.cycle_id = c.id
                        LEFT JOIN cycle_types ct
                            ON c.cycle_type_id = ct.id
                        WHERE meaw.fl_status = TRUE
                            AND m.company_id = p_company_id
                            AND (p_cycle_id IS NULL OR c.id = p_cycle_id)
                            AND (
                            p_cycle_active IS NULL
                            OR c.active = CASE WHEN p_cycle_active = 1 THEN TRUE ELSE FALSE END
                            )
                            AND (p_cycle_type_id IS NULL OR ct.id = p_cycle_type_id)
                            AND (p_exam_area_id IS NULL OR ea.id = p_exam_area_id)
                            AND (p_week IS NULL OR dwtm.week = ANY(SELECT (jsonb_array_elements_text(p_week))::bigint))
                            AND (p_university_id IS NULL OR m.university_id = p_university_id)
                            AND (p_exam_type_template_id IS NULL OR tmt.id = p_exam_type_template_id)
                        GROUP BY meaw.id, meaw.created_at, c.code, c.description, dwtm.week, ea.short_description, tm.description, ct.name
                        ORDER BY meaw.created_at DESC
                    )
                    SELECT 
                        tbl.*, 
                        CONCAT(tbl.integer_date, tbl.exam_type, tbl.cycle_type, tbl.area)::varchar as code,
                        count(*) OVER () AS total_count
                    FROM tbl_exams as tbl
                    LIMIT p_perpage
                    OFFSET offset_val;
                END;
            $$;


ALTER FUNCTION odiseo.fn_exam_key_generation(p_perpage integer, p_npage integer, p_cycle_id integer, p_exam_area_id integer, p_week jsonb, p_cycle_type_id integer, p_cycle_active integer, p_university_id integer, p_exam_type_template_id integer, p_company_id integer) OWNER TO postgres;

--
