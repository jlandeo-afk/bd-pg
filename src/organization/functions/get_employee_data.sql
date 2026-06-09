-- Function: organization.get_employee_data(uuid)

--

CREATE FUNCTION organization.get_employee_data(p_uuid uuid) RETURNS TABLE(id bigint, uuid uuid, code character varying, user_id bigint, first_name character varying, first_surname character varying, second_surname character varying, type_document_id bigint, document character varying, work_email odiseo.email_citext, personal_email odiseo.email_citext, phone character varying, limit_assigned_questions smallint, limit_assigned_questions_initial smallint, goal integer, level_id bigint, level_name character varying, fl_unlimit_questions boolean, rol_id bigint, charge_id bigint, lot smallint, employee_course jsonb, employee_universities jsonb)
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                        RETURN QUERY
                        SELECT 
                            e.id, 
                            e.uuid,
                            e.code,
                            e.user_id,
                            e.first_name, 
                            e.first_surname, 
                            e.second_surname,
                            e.type_document_id,
                            e.document, 
                            u.email  as work_email,
                            e.email as personal_email, 
                            e.phone, 
                            e.limit_assigned_questions,
                            e.limit_assigned_questions_initial,
                            e.goal,
                            lr.id as level_id,
                            lr.level_name as level_name,
                            e.fl_unlimit_questions,
                            ur.rol_id  as rol_id,
                            e.charge_id,
                            e.lot,
                            COALESCE(
                                (SELECT jsonb_agg(jsonb_build_object(
                                    'id', ec.course_id,
                                    'name', c.name,
                                    'created_at', ec.created_at
                                ))
                                FROM employee_course ec
                                JOIN course c ON ec.course_id = c.id
                                WHERE ec.teacher_id = e.id AND ec.fl_status = true),
                                '[]'::jsonb
                            ) as employee_course,
                            COALESCE(
                                (SELECT jsonb_agg(jsonb_build_object(
                                    'id', eu.university_id,
                                    'name', ou.name,
                                    'created_at', eu.created_at
                                ))
                                FROM employee_university eu
                                JOIN origin_university ou ON ou.id = eu.university_id
                                WHERE eu.employee_id = e.id AND eu.fl_status = true),
                                '[]'::jsonb
                            ) as employee_universities
                        FROM 
                            employees e 
                        LEFT JOIN 
                            users u ON e.user_id = u.id
                        LEFT JOIN 
                            users_roles ur ON ur.user_id = u.id
                        LEFT JOIN
                            level_rates lr ON lr.id = e.level_id
                        WHERE 
                            e.uuid = p_uuid
                        GROUP BY 
                            e.id, 
                            e.uuid, 
                            e.code,
                            e.user_id,
                            e.first_name, 
                            e.first_surname, 
                            e.second_surname,
                            e.type_document_id, 
                            e.document, 
                            u.email,
                            e.email, 
                            e.phone, 
                            e.limit_assigned_questions,
                            e.limit_assigned_questions_initial,
                            lr.level_name,
                            lr.id,
                            e.goal,
                            e.fl_unlimit_questions,
                            ur.id,
                            e.charge_id,
                            e.lot;
                    END;
                    $$;


ALTER FUNCTION organization.get_employee_data(p_uuid uuid) OWNER TO postgres;

--
