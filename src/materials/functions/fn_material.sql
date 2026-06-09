-- Function: materials.fn_material(integer, integer, smallint, smallint, bigint, boolean, smallint, integer)

--

CREATE FUNCTION materials.fn_material(p_perpage integer, p_npage integer, p_university_id smallint, p_headquarters_id smallint, p_cycle_id bigint, p_cycle_active boolean, p_classroom_id smallint, p_company_id integer) RETURNS TABLE(id bigint, cycle_id bigint, code_cycle character varying, cycle character varying, university_id smallint, university character varying, headquarte_id smallint, code_headquarters character varying, headquarters character varying, headquarters_classroom_id smallint, classroom_id smallint, code_classroom character varying, classroom character varying, start_date date, created_at timestamp without time zone, company_id bigint, total bigint, has_inconsistencies text, last_update timestamp with time zone)
    LANGUAGE plpgsql
    AS $$
            DECLARE
                offset_val INTEGER;
            BEGIN
                offset_val := p_perpage * (p_npage - 1);

                RETURN QUERY
                WITH base_materials AS (
                    SELECT
                        m.id,
                        m.cycle_id,
                        c.code AS code_cycle,
                        c.description AS cycle,
                        m.university_id,
                        u.name AS university,
                        m.headquarte_id,
                        h.code AS code_headquarters,
                        h.name AS headquarters,
                        m.headquarters_classroom_id,
                        cl.id AS classroom_id,
                        cl.code AS code_classroom,
                        cl.number AS classroom,
                        c.start_date,
                        m.created_at,
                        co.id AS company_id,
                        COUNT(*) OVER () AS total
                    FROM material m
                    INNER JOIN cycle c ON m.cycle_id = c.id
                    INNER JOIN origin_university u ON m.university_id = u.id
                    INNER JOIN headquarters h ON m.headquarte_id = h.id
                    INNER JOIN headquarters_classroom hc ON m.headquarters_classroom_id = hc.id
                    INNER JOIN classroom cl ON hc.classroom_id = cl.id
                    INNER JOIN companies co ON co.id = m.company_id 
                    WHERE 1 = 1
                    AND m.fl_status = true
                    AND (p_company_id IS NULL OR m.company_id = p_company_id)
                    AND (p_university_id IS NULL OR m.university_id = p_university_id)
                    AND (p_headquarters_id IS NULL OR m.headquarte_id = p_headquarters_id)
                    AND (p_classroom_id IS NULL OR cl.id = p_classroom_id)
                    AND (p_cycle_id IS NULL OR m.cycle_id = p_cycle_id)
                    AND (p_cycle_active IS NULL OR c.active = p_cycle_active)
                    ORDER BY m.created_at DESC, m.university_id ASC, c.start_date ASC, m.headquarte_id ASC, m.headquarters_classroom_id ASC
                    LIMIT p_perpage 
                    OFFSET offset_val
                )
                SELECT 
                    bm.id,
                    bm.cycle_id,
                    bm.code_cycle,
                    bm.cycle,
                    bm.university_id,
                    bm.university,
                    bm.headquarte_id,
                    bm.code_headquarters,
                    bm.headquarters,
                    bm.headquarters_classroom_id,
                    bm.classroom_id,
                    bm.code_classroom,
                    bm.classroom,
                    bm.start_date,
                    bm.created_at,
                    bm.company_id,
                    bm.total,
                    CASE 
                        WHEN val.mat_status = 'with-observations' OR val.exam_status = 'with-observations' THEN 'with-observations'
                        WHEN val.mat_status = 'without-observations' OR val.exam_status = 'without-observations' THEN 'without-observations'
                        ELSE 'without-type-material'
                    END AS has_inconsistencies,
                    now() AS last_update
                    FROM base_materials bm
                    CROSS JOIN LATERAL (
                        SELECT 
                            fn_get_material_inconsistency_status(bm.headquarte_id, bm.cycle_id, bm.university_id, bm.company_id) AS mat_status,
                            fn_get_exam_inconsistency_status(bm.cycle_id, bm.university_id, bm.company_id) AS exam_status
                    ) val
                ORDER BY bm.created_at DESC, bm.university_id ASC, bm.start_date ASC, bm.headquarte_id ASC, bm.headquarters_classroom_id ASC;

            END;
            $$;


ALTER FUNCTION materials.fn_material(p_perpage integer, p_npage integer, p_university_id smallint, p_headquarters_id smallint, p_cycle_id bigint, p_cycle_active boolean, p_classroom_id smallint, p_company_id integer) OWNER TO postgres;

--
