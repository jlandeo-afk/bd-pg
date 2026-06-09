-- Function: auth.fn_search_users(integer, integer, bigint, smallint, boolean, character varying, integer)

--

CREATE FUNCTION auth.fn_search_users(p_perpage integer, p_npage integer, f_rol_id bigint, f_charge_id smallint, f_status boolean, p_name_text character varying, p_company_id integer) RETURNS TABLE(id bigint, uuid uuid, username character varying, employee_id bigint, code character varying, usuario text, email odiseo.email_citext, image character varying, document character varying, type_document character varying, rol character varying, status boolean, suspended boolean, phone character varying, total integer, created_at timestamp without time zone, nq_status character varying, name_charge character varying, level_name character varying, level bigint, cost_per_question numeric, goal integer, courses jsonb)
    LANGUAGE plpgsql
    AS $$
    DECLARE
        total_count INTEGER;
        offset_val INTEGER;
    BEGIN
        offset_val := p_perpage * (p_npage - 1);

        SELECT COUNT(*)
        INTO total_count
        FROM users u
        LEFT JOIN users_roles ur ON ur.user_id = u.id
        LEFT JOIN roles r ON ur.rol_id = r.id
        LEFT JOIN employees e ON e.user_id = u.id
        WHERE 1 = 1 
        AND r.fl_admin = false AND r.fl_administrator = false
        AND (f_status IS NULL OR u.fl_suspended = f_status)
        AND u.fl_status IS TRUE
        AND (p_company_id IS NULL OR u.company_id = p_company_id)
        AND (f_rol_id IS NULL OR r.id = f_rol_id)
        AND (f_charge_id IS NULL OR e.charge_id = f_charge_id)
        AND (
            p_name_text IS NULL
            OR CONCAT(e.first_surname,' ', e.second_surname,' ', e.first_name) ILIKE '%' || p_name_text || '%'
            OR u."user" ILIKE '%' || p_name_text || '%'
            OR e.document ILIKE '%' || p_name_text || '%'
            );

        RETURN QUERY
        SELECT
            u.id AS id,
            u.uuid,
            u."user" AS username,
            e.id AS employee_id,
            e.code AS code,
            CONCAT(e.first_surname,' ', e.second_surname,' ', e.first_name) AS usuario,
            u.email,
            u.image,
            e.document,
            typ_doc.name as type_document,
            r.name AS rol,
            u.fl_status AS status,
            u.fl_suspended as suspended,
            e.phone,
            total_count AS total,
            u.created_at,
            CASE
                WHEN NOT fn_user_has_permission(u.id, 'neuro-quest.generar-pregunta-ia') OR NOT fn_has_user_nq_courses(u.id) THEN 'not_available'
                WHEN nur.id IS NULL THEN 'to_be_requested'
                ELSE nur.request_status
            END AS nq_status,
            c.name as name_charge,
            lr.level_name,
            lr.id,
            lr.cost_per_question,
            e.goal,
            coalesce(
            jsonb_agg(
                jsonb_build_object(
                    'id', cu.id,
                    'name', cu.name
                )
            )
            , '[]' ::jsonb) as courses
        FROM users u
        LEFT JOIN users_roles ur ON ur.user_id = u.id
        LEFT JOIN roles r ON ur.rol_id = r.id
        LEFT JOIN employees e ON e.user_id = u.id
        LEFT JOIN common.type_documents typ_doc ON typ_doc.id = e.type_document_id
        LEFT JOIN nq_user_request nur ON nur.user_id = u.id AND nur.deleted_at IS NULL
        LEFT JOIN charge c ON c.id = e.charge_id AND c.fl_status = true
        LEFT JOIN employee_course ec ON ec.teacher_id  = e.id AND ec.fl_status = true
        LEFT JOIN course cu ON cu.id = ec.course_id AND cu.fl_status = true
        LEFT JOIN level_rates lr ON lr.id = e.level_id
        WHERE 1 = 1
        AND r.fl_admin = false AND r.fl_administrator = false
        AND (f_status IS NULL OR u.fl_suspended = f_status)
        AND u.fl_status IS TRUE
        AND (p_company_id IS NULL OR u.company_id = p_company_id)
        AND (f_rol_id IS NULL OR r.id = f_rol_id)
        AND (f_charge_id IS NULL OR e.charge_id = f_charge_id)
        AND (
            p_name_text IS NULL
            OR CONCAT(e.first_surname,' ', e.second_surname,' ', e.first_name) ILIKE '%' || p_name_text || '%'
            OR u."user" ILIKE '%' || p_name_text || '%'
            OR e.document ILIKE '%' || p_name_text || '%'
        )
        GROUP BY u.id, e.id, typ_doc.id,r.id, nur.id, c.id, lr.id
        ORDER BY u."user" ASC
        LIMIT p_perpage
        OFFSET offset_val;
    END;
    $$;


ALTER FUNCTION auth.fn_search_users(p_perpage integer, p_npage integer, f_rol_id bigint, f_charge_id smallint, f_status boolean, p_name_text character varying, p_company_id integer) OWNER TO postgres;

--
