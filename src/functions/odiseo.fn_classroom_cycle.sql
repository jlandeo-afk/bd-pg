-- Function: odiseo.fn_classroom_cycle(integer, integer, smallint, smallint, bigint, smallint)

--

CREATE FUNCTION odiseo.fn_classroom_cycle(p_perpage integer, p_npage integer, f_university_id smallint, f_headquarters_id smallint, f_cycle_id bigint, f_classroom_id smallint) RETURNS TABLE(cycle_id bigint, code_cycle character varying, description_cycle character varying, university_id smallint, university character varying, headquarters_id smallint, code_headquarters character varying, headquarters character varying, slug_headquarters character varying, classroom_id smallint, code_classroom character varying, classroom character varying, total bigint)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            offset_val INTEGER;
        BEGIN
            -- Calculate the offset
            offset_val := p_perpage * (p_npage - 1);

            RETURN QUERY
            WITH tbl_university AS (
                SELECT
                    u.id AS university_id,
                    u.name AS university,
                    uh.headquarters_id,
                    h.code AS code_headquarters,
                    h.name AS headquarters,
                    h.slug AS slug_headquarters,
                    hc.classroom_id,
                    c.code AS code_classroom,
                    c.number AS classroom
                FROM odiseo.origin_university u
                INNER JOIN odiseo.university_headquarters uh ON u.id = uh.university_id AND uh.fl_status = true
                INNER JOIN odiseo.headquarters h ON uh.headquarters_id = h.id
                INNER JOIN odiseo.headquarters_classroom hc ON h.id = hc.headquarters_id
                INNER JOIN odiseo.classroom c ON hc.classroom_id = c.id AND c.id = 1
                WHERE (f_university_id IS NULL OR u.id = f_university_id)
                AND (f_headquarters_id IS NULL OR uh.headquarters_id = f_headquarters_id)
                AND (f_classroom_id IS NULL OR hc.classroom_id = f_classroom_id)
            ),
            tbl_cycle_university AS (
                SELECT
                    cy.id AS cycle_id,
                    cy.code AS code_cycle,
                    cy.description AS description_cycle,
                    u.university_id,
                    u.university,
                    u.headquarters_id,
                    u.code_headquarters,
                    u.headquarters,
                    u.slug_headquarters,
                    u.classroom_id,
                    u.code_classroom,
                    u.classroom
                FROM odiseo.cycle cy
                CROSS JOIN tbl_university u
                WHERE (f_cycle_id IS NULL OR cy.id = f_cycle_id)
            ),
            counted_cycle_university AS (
                SELECT *, COUNT(*) OVER () AS total
                FROM tbl_cycle_university
                ORDER BY cycle_id ASC, university ASC, headquarters_id ASC, classroom_id ASC
            )

            SELECT * FROM counted_cycle_university
            LIMIT p_perpage
            OFFSET offset_val;
        END;
        $$;


ALTER FUNCTION odiseo.fn_classroom_cycle(p_perpage integer, p_npage integer, f_university_id smallint, f_headquarters_id smallint, f_cycle_id bigint, f_classroom_id smallint) OWNER TO postgres;

--
