-- Function: questions.fn_find_question_digitalized_by_id(integer)

--

CREATE FUNCTION questions.fn_find_question_digitalized_by_id(p_question_id integer) RETURNS TABLE(question_id bigint, code character varying, number character varying, description text, answer_id bigint, column_question smallint, parent_id bigint, parent_description text, parent_traduction text, parent_description_b text, config_alternative smallint, code_course character varying, name_course character varying, url_file_digitalized_solution character varying, url_file_digitalized_images text, alternatives json, images json, diagrammed json, diagrammed_images json, question_maths json, alternative_maths json, didi_maths json, parent_images json)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                WITH tbl_alternative AS (
                    SELECT
                        a.question_id,
                        jsonb_agg(
                            jsonb_build_object(
                                'id', a.id,
                                'description', a.description,
                                'created_ar', created_at
                            ) ORDER BY a.created_at ASC, a.id ASC
                        ) FILTER (WHERE a.id IS NOT NULL)::TEXT AS alternatives
                    FROM
                        alternative AS a
                    WHERE 1 = 1
                    AND a.question_id = p_question_id
                    AND a.fl_status = true
                    GROUP BY a.question_id
                ), tbl_question_images AS (
                    SELECT
                        qi.question_id,
                        jsonb_agg(
                            jsonb_build_object(
                                'id', qi.id,
                                'code', qi.code,
                                'image', qi.image
                            )
                        ) FILTER (WHERE qi.id IS NOT NULL)::TEXT AS images
                    FROM
                        question_image qi
                    WHERE 1 = 1
                    AND qi.question_id = p_question_id
                    AND qi.fl_status = true
                    GROUP BY qi.question_id
                ), tbl_question_math AS (
                    SELECT
                        qm.question_id,
                        jsonb_agg(
                            json_build_object(
                                'id', qm.id,
                                'code', qm.code,
                                'path', qm.path,
                                'properties', qm.properties
                            )
                        )::TEXT AS question_maths
                    FROM
                        question_maths qm
                    JOIN question q ON q.id = qm.question_id
                    WHERE 1 = 1
                    AND q.fl_status = true 
                    AND q.id = p_question_id
                    AND qm.fl_status = true
                    GROUP BY qm.question_id
                ), tbl_alternative_math AS (
                    SELECT
                        a.question_id,
                        jsonb_agg(
                            json_build_object(
                                'id', am.id,
                                'code', am.code,
                                'path', am.path,
                                'properties', am.properties
                            )
                        )::TEXT AS alternative_maths
                    FROM
                        alternative_maths am
                    JOIN alternative a on a.id = am.alternative_id
                    JOIN question q on q.id = a.question_id
                    WHERE q.id = p_question_id
                    GROUP BY a.question_id
                ), tbl_field_diagrammed AS (
                    SELECT
                        edq.question_id,
                        jsonb_agg(
                            json_build_object(
                                'field', fd.name,
                                'value', edqf.value,
                                'created_at', edqf.created_at,
                                'position', sdc.position, 
                                'field_digrammed_id', edqf.id
                            ) ORDER BY sdc.position ASC
                        )::TEXT AS diagrammed
                    FROM employee_didi_question edq
                    LEFT JOIN employee_didi_question_field edqf ON edqf.employee_didi_question_id = edq.id
                    LEFT JOIN setting_diagrammed_courses sdc ON edqf.setting_diagrammed_course_id = sdc.id
                    LEFT JOIN field_diagrammed fd ON sdc.field_diagram_id = fd.id
                    WHERE 1 = 1
                    AND edq.fl_status IS TRUE
                    AND edqf.fl_status = true
                    AND edq.question_id = p_question_id
                    GROUP BY edq.question_id
                ), tbl_field_diagrammed_images AS (
                    SELECT
                        edq.question_id,
                        jsonb_agg(
                            jsonb_build_object(
                                'id', edqfi.id,
                                'code', edqfi.code,
                                'image', edqfi.image
                            )
                        ) FILTER (WHERE edqfi.id IS NOT NULL AND edqfi.fl_status = true)::TEXT AS diagrammed_images
                    FROM employee_didi_question edq
                    LEFT JOIN employee_didi_question_field_image edqfi ON edqfi.employee_didi_question_id = edq.id
                    WHERE 1 = 1
                      AND edq.fl_status IS TRUE
                      AND edqfi.fl_status = true
                      AND edq.question_id = p_question_id
                    GROUP BY edq.question_id
                ), tbl_didi_math AS (
                    SELECT
                        edq.question_id,
                        jsonb_agg(json_build_object(
                            'id', dm.id,
                            'code', dm.code,
                            'path', dm.path,
                            'properties', dm.properties
                        ))::TEXT AS didi_maths
                    FROM
                        didi_maths dm
                    LEFT JOIN employee_didi_question_field edqf on edqf.id = dm.didi_question_id
                    LEFT JOIN employee_didi_question edq on edq.id = edqf.employee_didi_question_id 
                    LEFT JOIN question q on q.id = edq.question_id
                    WHERE 1 = 1
                    AND q.id = p_question_id
                    --AND dm.fl_status = true
                    GROUP BY edq.question_id
                ), tbl_parent_img AS (
                    SELECT
                        q.id,
                        pq.description AS parent_description,
                        pq.text_traduction AS parent_traduction,
						pq.description_b AS parent_description_b,
                        jsonb_agg(
                            jsonb_build_object(
                                'id', pi2.id,
                                'code', pi2.code,
                                'image', pi2.image
                            )
                        ) FILTER (WHERE pi2.id IS NOT NULL AND pi2.fl_status = TRUE)::TEXT AS parent_images
					FROM
                        parent_question pq
					LEFT JOIN parent_image pi2 ON pi2.parent_id = pq.id AND pi2.fl_status = TRUE
					LEFT JOIN question q ON q.parent_id = pq.id
					WHERE q.id = p_question_id
					AND pq.fl_status = TRUE
					GROUP BY q.id, pq.description, pq.text_traduction, pq.description_b
                )

                SELECT
                    q.id as question_id,
                    q.code,
                    q.number,
                    q.description,
                    q.answer_id,
                    q.columns AS column_question,
                    q.parent_id,
                    tbl_pi.parent_description,
                    tbl_pi.parent_traduction,
					tbl_pi.parent_description_b,
                    ca.columns AS config_alternative,
                    c.code AS code_course,
                    c.name AS name_course,
                    edq.url_file_digitalized_solution,
                    edq.url_file_digitalized_images,
                    -- Alternativas
                    COALESCE(tbl_a.alternatives::JSON, '[]'::JSON) AS alternatives,
                    -- Imágenes de la pregunta
                    COALESCE(tbl_qi.images::JSON, '[]'::JSON) AS images,
                    -- Campos de diagramacion
                    COALESCE(tbl_fd.diagrammed::JSON, '[]'::JSON) AS diagrammed,
                    -- Imágenes de diagramacion
                    COALESCE(tbl_fdi.diagrammed_images::JSON, '[]'::JSON) AS diagrammed_images,
                    -- Maths de pregunta, alternativas y diagramaccion
                    COALESCE(tbl_qm.question_maths::JSON, '[]'::JSON) AS question_maths,
                    COALESCE(tbl_am.alternative_maths::JSON, '[]'::JSON) AS alternative_maths,
                    COALESCE(tbl_dm.didi_maths::JSON, '[]'::JSON) AS didi_maths,
                    COALESCE(tbl_pi.parent_images::JSON, '[]'::JSON) AS parent_images
                FROM employee_didi_question edq
                LEFT JOIN question q ON q.id = edq.question_id
                LEFT JOIN course c ON q.course_id = c.id
                LEFT JOIN configuration_alternative ca ON q.config_alternative_id = ca.id
                LEFT JOIN tbl_alternative tbl_a ON tbl_a.question_id = q.id
                LEFT JOIN tbl_question_images tbl_qi ON tbl_qi.question_id = q.id
                LEFT JOIN tbl_field_diagrammed tbl_fd ON tbl_fd.question_id = q.id
                LEFT JOIN tbl_field_diagrammed_images tbl_fdi ON tbl_fdi.question_id = q.id
                LEFT JOIN tbl_question_math tbl_qm ON tbl_qm.question_id = q.id
                LEFT JOIN tbl_alternative_math tbl_am ON tbl_am.question_id = q.id
                LEFT JOIN tbl_didi_math tbl_dm ON tbl_dm.question_id = q.id
                LEFT JOIN tbl_parent_img AS tbl_pi ON tbl_pi.id = q.id
                WHERE 1 = 1 
                AND q.id = p_question_id 
                AND edq.fl_status = true
                GROUP BY
                    q.id,
                    q.code,
                    q.number,
                    q.description,
                    q.answer_id,
                    q.columns,
                    q.parent_id,
                    tbl_pi.parent_description,
                    tbl_pi.parent_traduction,
					tbl_pi.parent_description_b,
                    ca.columns,
                    c.code,
                    c.name,
                    edq.url_file_digitalized_solution,
                    edq.url_file_digitalized_images,
                    tbl_qi.images,
                    tbl_a.alternatives,
                    tbl_fd.diagrammed,
                    tbl_fdi.diagrammed_images,
                    tbl_qm.question_maths,
                    tbl_am.alternative_maths,
                    tbl_dm.didi_maths,
                    tbl_pi.parent_images;
                END;
            $$;


ALTER FUNCTION questions.fn_find_question_digitalized_by_id(p_question_id integer) OWNER TO postgres;

--
