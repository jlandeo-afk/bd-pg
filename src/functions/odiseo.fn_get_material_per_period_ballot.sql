-- Function: odiseo.fn_get_material_per_period_ballot(bigint, smallint, smallint, smallint, bigint, boolean)

--

CREATE FUNCTION odiseo.fn_get_material_per_period_ballot(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint, p_employee_id bigint, p_has_permission_generar_por_curso_asignado boolean DEFAULT false) RETURNS TABLE(id bigint, material_id bigint, type_material_id smallint, fl_created boolean, material_period_id bigint, start_week smallint, end_week smallint, fl_config_type boolean, lower_level_limit smallint, upper_level_limit smallint, fl_missing_questions boolean, questions_missing_url character varying, fl_missing_courses boolean, courses_missing_url character varying, fl_missing_text boolean, text_missing_url character varying, url jsonb, lock_status boolean, locked_by_id bigint, locked_at timestamp without time zone, locked_by_name text, date_completed timestamp without time zone, employee_completed character varying, order_date timestamp without time zone, order_by_user_id bigint, order_by_name character varying, has_config_column boolean)
    LANGUAGE plpgsql
    AS $$
            DECLARE
                C_ROOT_ADMIN INTEGER DEFAULT 1;
                C_SUPER_ADMIN INTEGER DEFAULT 2;
            BEGIN
                RETURN QUERY
                WITH tbl_type_url (id, name) AS (
                    VALUES
                        (1, 'solution'::VARCHAR),
                        (2, 'without_solution'::VARCHAR),
                        (3, 'review_solution'::VARCHAR),
                        (4, 'review_without_solution'::VARCHAR),
                        (5, 'material_class'::VARCHAR)
                ), tbl_type_material AS (
                    SELECT
                        tm.id,
                        tm.fl_class_material
                    FROM type_material tm
                    WHERE tm.id = p_type_material_id
                ), type_material_ids AS (
                    SELECT UNNEST(
                        CASE
                            WHEN EXISTS (SELECT 1 FROM type_material tm WHERE tm.parent_id = p_type_material_id)
                            THEN ARRAY(SELECT tm.id FROM type_material tm WHERE tm.parent_id = p_type_material_id)
                            ELSE ARRAY[p_type_material_id]
                        END
                    ) AS id
                ), locked_status AS (
                    SELECT 
                        BOOL_AND(dwtm.locked) AS locked,
                        MIN(dwtm.locked_at) AS locked_at,
                        MIN(dwtm.locked_by) AS locked_by,
                        dwtm.material_id
                    FROM odiseo.detail_week_type_mat dwtm 
                    LEFT JOIN odiseo.employees e ON e.user_id = dwtm.locked_by
                    WHERE 1 = 1
                      AND dwtm.type_material_id IN (SELECT * FROM type_material_ids)
                      AND dwtm.week BETWEEN p_start_week AND p_end_week
                      AND dwtm.material_id = p_material_id
                      AND dwtm.fl_status = TRUE
                    GROUP BY dwtm.material_id
                ), locked_status_by AS (
                    SELECT
                        ls.*,
                        CASE
                            WHEN locked_by IS NULL THEN 'Sin acciones registradas'
                            WHEN locked_by IN (C_ROOT_ADMIN, C_SUPER_ADMIN) THEN 'Administrador'
                            ELSE CONCAT( e.first_surname, ' ', e.second_surname, ' ', e.first_name )
                        END AS locked_by_name
                    FROM locked_status ls
                    LEFT JOIN odiseo.employees e ON e.user_id = ls.locked_by
                ), refresh_fl_job_process_per_course_week AS (
                    SELECT 
                        mppc.type,
                        BOOL_OR(mppc.job_status = 'completed') AS has_completed
                    FROM material_per_period mpp
                    JOIN material_per_period_ballot mppb 
                        ON mppb.material_per_period_id = mpp.id
                    JOIN material_per_period_course mppc 
                        ON mppc.material_per_period_ballot_id = mppb.id
                    JOIN employee_course ec ON mppc.course_id = ec.course_id AND ec.teacher_id = p_employee_id
                    WHERE mpp.material_id = p_material_id
                    AND mpp.type_material_id = p_type_material_id
                    AND mppb.start_week = p_start_week
                    AND mppb.end_week = p_end_week
                    AND mpp.deleted_at IS NULL
                    AND mppb.deleted_at IS NULL
                    AND mppc.deleted_at IS NULL
                    GROUP BY mppc.type
                ), tbl_material_per_period AS (
                    SELECT
                        mpp.id,
                        m.id,
                        COALESCE(mpp.type_material_id, p_type_material_id) AS p_type_material_id,
                        CASE
                            WHEN mppb.start_week IS NOT NULL THEN TRUE
                            ELSE FALSE
                        END AS fl_created,
                        mppb.id AS material_period_id,
                        COALESCE(mppb.start_week, p_start_week) AS p_start_week,
                        COALESCE(mppb.end_week, p_end_week) AS end_week,
                        COALESCE(mppllc.fl_use_question_type, mppb.fl_config_type, true) AS fl_config_type,
                        COALESCE(mppllc.lower_level_limit, mppb.lower_level_limit, 1::SMALLINT) AS lower_level_limit,
                        COALESCE(mppllc.upper_level_limit, mppb.upper_level_limit, 1::SMALLINT) AS upper_level_limit,
                        mppb.fl_missing_questions,
                        mppb.questions_missing_url,
                        mppb.fl_missing_courses,
                        mppb.courses_missing_url,
                        mppb.fl_missing_text,
                        mppb.text_missing_url,
                        COALESCE((
                            SELECT jsonb_agg(
                                jsonb_build_object(
                                    'id', mppbu.id,
                                    'material_per_period_ballot_id', COALESCE(mppbu.material_per_period_ballot_id, mppb.id),
                                    'type_url', COALESCE(mppbu.type_url, ttu.name),
                                    'fl_job_process', COALESCE(mppbu.fl_job_process, 'unprocessed'::VARCHAR),
                                    'job_url', mppbu.job_url,
                                    'job_id', mppbu.job_id,
                                    'file_name', mppbu.file_name
                                )
                                ||
                                CASE 
                                    WHEN p_has_permission_generar_por_curso_asignado THEN
                                        jsonb_build_object(
                                            'fl_job_process_completed_by_employee_course',
                                            COALESCE(rf.has_completed, false)
                                        )
                                    ELSE '{}'::jsonb
                                END
                                ORDER BY ttu.id ASC
                            )
                            FROM tbl_type_url ttu
                            LEFT JOIN tbl_type_material ttm ON 1 = 1
                            LEFT JOIN material_per_period_ballot_url mppbu 
                                ON ttu.name = mppbu.type_url
                                AND mppbu.deleted_by IS NULL
                                AND mppbu.material_per_period_ballot_id = mppb.id

                            LEFT JOIN refresh_fl_job_process_per_course_week rf
                                ON rf.type = COALESCE(mppbu.type_url, ttu.name)

                            WHERE (
                                ttm.fl_class_material = TRUE
                                OR (ttm.fl_class_material = FALSE AND ttu.name <> 'material_class')
                            )
                        ), '[]'::JSONB) AS url,
                        lsb.locked lock_status,
                        lsb.locked_by AS locked_by_id,
                        lsb.locked_at,
                        lsb.locked_by_name,
                        mppb.date_completed,
                        CASE
                            WHEN u.id IS NULL THEN NULL::VARCHAR
                            WHEN e.user_id IS NULL THEN 'Administrador'::VARCHAR
                            ELSE CONCAT(e.first_name, ' ', e.first_surname, ' ', e.second_surname)::VARCHAR
                        END AS employee_completed,
                        mppb.order_date,
                        mppb.order_by_user_id,
                        CASE
                            WHEN uorder.id IS NULL THEN NULL::VARCHAR
                            WHEN eorder.user_id IS NULL THEN 'Administrador'::VARCHAR
                            ELSE CONCAT(eorder.first_name, ' ', eorder.first_surname, ' ', eorder.second_surname)::VARCHAR
                        END AS order_name,
                        tmt.has_config_column
                    FROM material m
                    join type_material tm ON tm.id = p_type_material_id and tm.deleted_by IS NULL
                    join type_material_template tmt ON tmt.id = tm.type_material_template_id and tmt.deleted_by IS NULL
                    LEFT JOIN material_per_period mpp ON m.id = mpp.material_id
                        AND mpp.deleted_by IS NULL
                        AND mpp.type_material_id = p_type_material_id
                    LEFT JOIN material_per_period_ballot mppb ON mpp.id = mppb.material_per_period_id
                        AND mppb.deleted_by IS NULL
                        AND mppb.start_week = p_start_week
                        AND mppb.end_week = p_end_week
                    LEFT JOIN material_per_period_level_limit_config mppllc ON mpp.id = mppllc.material_per_period_id
                        AND mppllc.deleted_by IS NULL
                        AND mppllc.start_week = p_start_week
                        AND mppllc.end_week = p_end_week
                    LEFT JOIN users uorder ON mppb.order_by_user_id = uorder.id
                    LEFT JOIN employees eorder ON uorder.id = eorder.user_id
                    LEFT JOIN locked_status_by lsb ON lsb.material_id = m.id
                    LEFT JOIN users u ON mppb.user_completed_id = u.id
                    LEFT JOIN employees e ON u.id = e.user_id
                    WHERE m.id = p_material_id
                )
                SELECT * FROM tbl_material_per_period tmpp;
            END;
            $$;


ALTER FUNCTION odiseo.fn_get_material_per_period_ballot(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint, p_employee_id bigint, p_has_permission_generar_por_curso_asignado boolean) OWNER TO postgres;

--
