-- Function: academic.fn_get_nq_courses_by_user_uuid(uuid)

--

CREATE FUNCTION academic.fn_get_nq_courses_by_user_uuid(p_uuid uuid) RETURNS TABLE(username character varying, email character varying, first_name character varying, last_name character varying, courses jsonb, role_id bigint, role_name character varying)
    LANGUAGE plpgsql
    AS $$
    DECLARE C_SUPER_ADMIN SMALLINT DEFAULT 1;
    DECLARE C_ADMIN SMALLINT DEFAULT 2;
            
    BEGIN
        RETURN QUERY
        WITH nq_courses AS (
            SELECT
                c.id,
                c.code,
                c.name,
                c.alias_nq
            FROM academic.course c
            WHERE 1 = 1
              AND c.fl_status IS TRUE
              AND c.deleted_at IS NULL
              AND c.alias_nq IS NOT NULL
        ) SELECT
            u.user::CHARACTER VARYING username,
            u.email::CHARACTER VARYING email,
            CASE
                WHEN u.id IN (C_SUPER_ADMIN, C_ADMIN) THEN 'admin'::CHARACTER VARYING
                ELSE  COALESCE(e.first_surname, 'admin')::CHARACTER VARYING
            END AS first_name,
            CASE
                WHEN u.id IN (C_SUPER_ADMIN, C_ADMIN) THEN 'admin'::CHARACTER VARYING
                ELSE CONCAT(e.first_surname, ' ', e.second_surname)::CHARACTER VARYING
            END AS last_name,
            COALESCE(
                JSONB_AGG(
                    JSONB_BUILD_OBJECT(
                        'course_id', nc.id,
                        'course_code', nc.code,
                        'course_name', nc.name,
                        'alias_nq', nc.alias_nq
                    )
                    ORDER BY nc.alias_nq
                ) FILTER (WHERE nc.id IS NOT NULL),
                '[]'::JSONB
            ) AS courses,
            r.id AS role_id,
            r.name::CHARACTER VARYING AS role_name
        FROM auth.users u
        LEFT JOIN odiseo.employees e ON u.id = e.user_id
        LEFT JOIN auth.users_roles ur ON ur.user_id = e.user_id
        LEFT JOIN auth.roles r ON r.id = ur.rol_id
        LEFT JOIN odiseo.employee_course ec ON ec.teacher_id = e.id AND ec.deleted_at IS NULL AND ec.fl_status IS TRUE
        LEFT JOIN nq_courses nc ON ( nc.id = ec.course_id OR u.id IN (C_SUPER_ADMIN, C_ADMIN)) AND nc.alias_nq IS NOT NULL
        WHERE u.uuid = p_uuid
        GROUP BY e.id, u.id, r.id;
    END;
    $$;


ALTER FUNCTION academic.fn_get_nq_courses_by_user_uuid(p_uuid uuid) OWNER TO postgres;

--
