-- Function: organization.fn_get_search_employees(integer, integer, character varying, boolean, integer, integer)

--

CREATE FUNCTION organization.fn_get_search_employees(p_perpage integer, p_npage integer, p_name_text character varying, f_status boolean, f_charge_id integer, p_company_id integer) RETURNS TABLE(id bigint, uuid uuid, charge_id bigint, name_charge character varying, type_document character varying, document character varying, courses json, code character varying, first_name text, last_name text, level_id bigint, level_name character varying, goal integer, cost_per_question numeric, email text, phone character varying, fl_status boolean, created_at timestamp without time zone, total_count bigint)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            offset_val INTEGER;
        BEGIN
            offset_val := p_perpage * (p_npage - 1);

            RETURN QUERY
            WITH tbl_employee as (
                SELECT
                    e.id,
                    e.uuid,
                    e.charge_id,
                    c.name as name_charge,
                    tp."name" as type_document,
                    e.document,
                    COALESCE(json_agg(c2.name) FILTER (WHERE c2.name IS NOT NULL), '[]') AS courses,
                    e.code AS code,
                    UPPER(e.first_name) AS first_name,
                    CONCAT(e.first_surname,' ', e.second_surname) AS last_name,
                    e.level_id,
                    lr.level_name as level_name,
                    e.goal,
                    lr.cost_per_question,
                    LOWER(e.email) as email,
                    e.phone,
                    e.fl_status,
                    e.created_at
                FROM
                    employees e
                LEFT JOIN common.type_documents tp ON e.type_document_id = tp.id
                LEFT JOIN charge c ON e.charge_id = c.id
                LEFT JOIN employee_course ec ON ec.teacher_id = e.id AND ec.fl_status = true
                LEFT JOIN course c2 ON ec.course_id = c2.id
                LEFT JOIN level_rates lr ON e.level_id = lr.id
                WHERE 1 = 1
                AND e.fl_status = true
                AND (p_company_id IS NULL OR e.company_id = p_company_id)
                AND (f_status IS NULL OR e.fl_status = f_status)
                AND (f_charge_id is NULL or e.charge_id = f_charge_id)
                AND (
                    p_name_text IS NULL
                    OR e.document ILIKE '%' || p_name_text || '%'
                    OR e.first_name ILIKE '%' || p_name_text || '%'
                    OR e.first_surname ILIKE '%' || p_name_text || '%'
                    OR COALESCE(e.second_surname, '') ILIKE '%' || p_name_text || '%'
                    OR CONCAT(e.first_name, ' ', e.first_surname) ILIKE '%' || p_name_text || '%'
                )
                GROUP BY
                    e.id,
                    e.uuid,
                    e.charge_id,
                    c.name,
                    tp.name,
                    e.document,
                    e.code,
                    e.first_name,
                    e.first_surname,
                    e.second_surname,
                    e.level_id,
                    lr.level_name,
                    e.goal,
                    lr.cost_per_question,
                    e.email,
                    e.phone,
                    e.fl_status,
                    e.created_at
            )
            SELECT *, count(*) OVER () AS total_count
            FROM tbl_employee as tbl
            ORDER by  tbl.first_name asc, CASE when tbl.fl_status THEN 0 ELSE 1 END asc, tbl.created_at desc
            LIMIT p_perpage
            OFFSET offset_val;
        END;
        $$;


ALTER FUNCTION organization.fn_get_search_employees(p_perpage integer, p_npage integer, p_name_text character varying, f_status boolean, f_charge_id integer, p_company_id integer) OWNER TO postgres;

--
