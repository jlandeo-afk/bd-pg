-- Function: academic.fn_get_all_university_by_employee(bigint, integer, integer, character varying, bigint)

--

CREATE FUNCTION academic.fn_get_all_university_by_employee(p_employee_id bigint, p_perpage integer, p_npage integer, p_search character varying, p_company_id bigint) RETURNS TABLE(id smallint, name text, university character varying, quantity bigint, fl_template boolean, total bigint)
    LANGUAGE plpgsql
    AS $$
    DECLARE offset_val INTEGER;
    BEGIN
        offset_val := p_perpage * (p_npage - 1);
        RETURN QUERY
        WITH universities AS (
            SELECT DISTINCT
                originuniver.id,
                CONCAT('(', originuniver.slug, ') ', originuniver.name) AS name,
                originuniver.name AS university,
                COALESCE(syllab_count.quantity, 0) AS quantity,
                CASE WHEN COALESCE(syllab_count.quantity, 0) > 0 THEN true ELSE false END AS fl_template
            FROM origin_university originuniver
            LEFT JOIN employee_university employuniver
                ON employuniver.university_id = originuniver.id
                AND employuniver.fl_status IS true
            LEFT JOIN (
                SELECT university_id, COUNT(*) AS quantity
                FROM syllabus_template
                WHERE fl_status = true
                AND company_id = p_company_id
                GROUP BY university_id
            ) syllab_count
                ON syllab_count.university_id = originuniver.id
            WHERE originuniver.deleted_by IS NULL
            AND (p_employee_id IS NULL OR employuniver.employee_id = p_employee_id)
            AND originuniver.fl_active = true
            ORDER BY fl_template DESC, university ASC, originuniver.id ASC
        ),
        counted_universities AS (
            SELECT *, COUNT(*) OVER () AS total
            FROM universities
            WHERE (p_search IS NULL OR universities.university ILIKE '%' || p_search || '%')
        )
        SELECT * FROM counted_universities
        LIMIT p_perpage OFFSET offset_val;
    END;
    $$;


ALTER FUNCTION academic.fn_get_all_university_by_employee(p_employee_id bigint, p_perpage integer, p_npage integer, p_search character varying, p_company_id bigint) OWNER TO postgres;

--
