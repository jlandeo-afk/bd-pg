-- Function: materials.fn_type_material_course(integer, integer, smallint, character varying)

--

CREATE FUNCTION materials.fn_type_material_course(p_perpage integer, p_npage integer, p_type_material_id smallint, p_search character varying) RETURNS TABLE(id bigint, course_id smallint, code_course character varying, course character varying, type_material_id smallint, code_type_material character varying, type_material character varying, amount_question integer, fl_status boolean, total bigint)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            offset_val INTEGER;
        BEGIN
            -- Calculate the offset
            offset_val := p_perpage * (p_npage - 1);
            RETURN QUERY
            WITH tbl_type_material_course AS (
                SELECT
                    tc.id,
                    tc.course_id,
                    c.code AS code_course,
                    c.name AS course,
                    tc.type_material_id,
                    t.code AS code_type_material,
                    t.description AS type_material,
                    tc.amount_question,
                    tc.fl_status
                FROM materials.type_material_course tc
                INNER JOIN academic.course c ON c.id = tc.course_id
                INNER JOIN materials.type_material t ON t.id = tc.type_material_id
                WHERE t.fl_status = true AND tc.type_material_id = p_type_material_id
                AND (
                    p_search IS NULL
                    OR (c.code ILIKE '%' || p_search || '%'
                    OR c.name ILIKE '%' || p_search || '%')
                )
            ),
            counted_type_material AS (
                SELECT *, COUNT(*) OVER () AS total
                FROM tbl_type_material_course
                ORDER BY tbl_type_material_course.code_course ASC, tbl_type_material_course.course ASC
            )
            SELECT * FROM counted_type_material
            LIMIT p_perpage
            OFFSET offset_val;
        END;
        $$;


ALTER FUNCTION materials.fn_type_material_course(p_perpage integer, p_npage integer, p_type_material_id smallint, p_search character varying) OWNER TO postgres;

--
