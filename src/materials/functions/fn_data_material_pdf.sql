-- Function: materials.fn_data_material_pdf(bigint)

--

CREATE FUNCTION materials.fn_data_material_pdf(p_material_id bigint) RETURNS TABLE(id bigint, code_cycle character varying, start_date date, end_date date, code_cycle_template character varying, cycle_name character varying, alias_cycle_template character varying, university_id smallint, university character varying, slug_university character varying, headquarters character varying, slug_headquarters character varying, code_classroom character varying, classroom character varying)
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    RETURN QUERY
                    SELECT
                        m.id,
                        c.code as code_cycle,
                        c.start_date,
                        c.end_date,
                        c.code AS code_cycle_template,
                        c.description AS cycle_name,
                        c.code AS alias_cycle_template,
                        m.university_id,
                        u.name AS university,
                        u.slug AS slug_university,
                        h.name AS headquarters,
                        h.slug AS slug_headquarters,
                        cl.code AS code_classroom,
                        cl.number AS classroom
                    FROM material m
                    INNER JOIN cycle c ON m.cycle_id = c.id
                    INNER JOIN origin_university u ON m.university_id = u.id
                    INNER JOIN headquarters h ON m.headquarte_id = h.id
                    INNER JOIN headquarters_classroom hc ON m.headquarters_classroom_id = hc.id
                    INNER JOIN classroom cl ON hc.classroom_id = cl.id
                    WHERE m.id = p_material_id;
                END;
                $$;


ALTER FUNCTION materials.fn_data_material_pdf(p_material_id bigint) OWNER TO postgres;

--
