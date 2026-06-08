-- Function: odiseo.fn_search_exam_area(integer, integer, character varying, integer, boolean, integer, integer)

--

CREATE FUNCTION odiseo.fn_search_exam_area(p_perpage integer, p_npage integer, p_name_text character varying, f_cycle_id integer, f_cycle_active boolean, f_type_material_id integer, p_company_id integer) RETURNS TABLE(id smallint, cycle_id bigint, cycle character varying, type_material_id smallint, type_material character varying, created_at timestamp without time zone, created_by text, is_exam_material_configured boolean, total_count bigint)
    LANGUAGE plpgsql
    AS $$
    DECLARE
        offset_val INTEGER;
    BEGIN
        -- Calcula el offset para la paginación
        offset_val := p_perpage * (p_npage - 1);

        RETURN QUERY
        WITH tbl_exam_material_configurations AS (
            SELECT emc.id , c.id as cycle_id, c.description as cycle, tm.id as type_material_id, tm.description as type_material,
            tm.created_at,
            CASE
                WHEN e.first_name IS NOT NULL AND e.first_surname IS NOT NULL THEN
                    CONCAT(
                        initcap(split_part(e.first_name, ' ', 1)), ' ',
                        upper(left(e.first_surname, 1)), '. ',
                        initcap(e.second_surname)
                    )
                ELSE
                    NULL
            END AS created_by,
            CASE
                WHEN (
                    SELECT COUNT(*)
                    FROM course c2
                    WHERE c2.fl_status = true AND c2.deleted_at is NULL
                ) = (
                    SELECT count(*)
                    FROM exam_material_config_area_courses emcac2
                    LEFT JOIN exam_material_configurations emc2
                    on emcac2.exam_material_config_id = emc2.id
                    WHERE emc2.id = emc.id
                ) THEN TRUE
                ELSE FALSE
            END AS is_exam_material_configured
            FROM exam_material_configurations emc
            LEFT JOIN cycle c
            on emc.cycle_id = c.id
            LEFT JOIN type_material tm
            on emc.type_material_id = tm.id
            LEFT JOIN users u on emc.created_by = u.id
            LEFT JOIN employees e ON e.user_id = u.id
            WHERE emc.fl_status = true
            AND emc.company_id = p_company_id
            AND emc.deleted_at is NULL
            AND (
                p_name_text IS NULL
                OR LOWER(c.description) LIKE '%' || LOWER(p_name_text) || '%'
                OR LOWER(tm.description) LIKE '%' || LOWER(p_name_text) || '%'
            )
            AND (f_type_material_id IS NULL OR tm.id = f_type_material_id)
            AND (f_cycle_id IS NULL OR c.id = f_cycle_id)
            AND (f_cycle_active IS NULL OR c.active = f_cycle_active)
        )
        SELECT *, count(*) OVER () AS total_count
        FROM tbl_exam_material_configurations
        ORDER BY created_at DESC, type_material ASC
        LIMIT p_perpage
        OFFSET offset_val;
    END;
    $$;


ALTER FUNCTION odiseo.fn_search_exam_area(p_perpage integer, p_npage integer, p_name_text character varying, f_cycle_id integer, f_cycle_active boolean, f_type_material_id integer, p_company_id integer) OWNER TO postgres;

--
