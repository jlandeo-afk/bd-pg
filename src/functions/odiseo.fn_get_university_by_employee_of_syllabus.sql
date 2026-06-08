-- Function: odiseo.fn_get_university_by_employee_of_syllabus(bigint, bigint)

--

CREATE FUNCTION odiseo.fn_get_university_by_employee_of_syllabus(p_employee_id bigint, p_company_id bigint) RETURNS TABLE(id smallint, name text, university character varying, quantity bigint, fl_template boolean)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        SELECT DISTINCT
            originuniver.id,
            CONCAT('(', originuniver.slug, ') ', originuniver.name),
            originuniver.name AS university,
            COALESCE(syllab_count.quantity, 0) AS quantity,
            CASE WHEN COALESCE(syllab_count.quantity, 0) > 0 THEN true ELSE false END AS fl_template
        FROM origin_university originuniver
        LEFT JOIN employee_university employuniver
            ON employuniver.university_id = originuniver.id
            AND employuniver.fl_status IS true
        LEFT JOIN (
            SELECT s.university_id, COUNT(*) AS quantity
            FROM syllabus s
            WHERE s.fl_status = true AND s.company_id = p_company_id
            GROUP BY s.university_id
        ) syllab_count ON syllab_count.university_id = originuniver.id
        WHERE originuniver.deleted_by IS NULL
        AND (p_employee_id IS NULL OR employuniver.employee_id = p_employee_id)
        AND originuniver.fl_active = true
        ORDER BY fl_template DESC, university ASC, originuniver.id ASC;
    END;
    $$;


ALTER FUNCTION odiseo.fn_get_university_by_employee_of_syllabus(p_employee_id bigint, p_company_id bigint) OWNER TO postgres;

--
