-- Function: questions.fn_find_question_for_previewer(integer, integer)

--

CREATE FUNCTION questions.fn_find_question_for_previewer(p_question_id integer, p_subtopic_id integer) RETURNS TABLE(id bigint, code character varying, description text, columns smallint, config_alternative smallint, answer_id bigint, parent_id bigint, parent_description text, parent_traduction text, parent_description_b text, alternatives json, images json, parent_images json, diagrammed json, diagrammed_images json, type_question text)
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
                                                    ), tbl_field_diagrammed AS (
                                                        SELECT
                                                            edq.question_id,
                                                            jsonb_agg(
                                                                json_build_object(
                                                                    'field', fd.name,
                                                                    'value', edqf.value,
                                                                    'created_at', edqf.created_at,
                                                                    'position', sdc.position, 
                                                                    'field_digrammed_id', edqf.id,
                                                                    'fl_optional', sdc.fl_optional
                                                                ) ORDER BY sdc.position ASC
                                                            )::TEXT AS diagrammed
                                                        FROM
                                                            employee_didi_question edq
                                                        LEFT JOIN employee_didi_question_field edqf ON edqf.employee_didi_question_id = edq.id
                                                        LEFT JOIN setting_diagrammed_courses sdc ON edqf.setting_diagrammed_course_id = sdc.id
                                                        LEFT JOIN field_diagrammed fd ON sdc.field_diagram_id = fd.id
                                                        WHERE 1 = 1
                                                        AND edqf.fl_status = true
                                                        AND edq.question_id = p_question_id
                                                        AND edqf.value IS NOT NULL
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
                                                        FROM
                                                            employee_didi_question edq
                                                        LEFT JOIN employee_didi_question_field_image edqfi ON edqfi.employee_didi_question_id = edq.id
                                                        WHERE 1 = 1
                                                        AND edq.fl_status IS TRUE
                                                        AND edqfi.fl_status = true
                                                        AND edq.question_id = p_question_id
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
                                                        COALESCE(qs.code, q.code) AS code,
                                                        q.description,
                                                        q.columns,
                                                        ca.columns AS config_alternative,
                                                        q.answer_id,
                                                        q.parent_id,
                                                        tbl_pi.parent_description,
                                                        tbl_pi.parent_traduction,
                                                        tbl_pi.parent_description_b,
                                                        -- Alternativas
                                                        COALESCE(tbl_a.alternatives::JSON, '[]'::JSON) AS altern,
                                                        -- Imágenes de la pregunta
                                                        COALESCE(tbl_qi.images::JSON, '[]'::JSON) AS images,
                                                        COALESCE(tbl_pi.parent_images::JSON, '[]'::JSON) AS parent_images,
                                                        -- Campos de diagramacion
                                                        COALESCE(tbl_fd.diagrammed::JSON, '[]'::JSON) AS diagrammed,
                                                        -- Imágenes de diagramacion
                                                        COALESCE(tbl_fdi.diagrammed_images::JSON, '[]'::JSON) AS diagrammed_images,
                                                        CASE
                                                            WHEN q.parent_id IS NULL THEN 'P'
                                                            ELSE 'S'
                                                        END AS type_question
                                                    FROM 
                                                        question q
                                                    LEFT JOIN employee_didi_question edq ON q.id = edq.question_id
                                                    LEFT JOIN configuration_alternative ca ON q.config_alternative_id = ca.id
                                                    LEFT JOIN tbl_question_images tbl_qi ON tbl_qi.question_id = q.id
                                                    LEFT JOIN tbl_alternative tbl_a ON tbl_a.question_id = q.id
                                                    LEFT JOIN tbl_field_diagrammed tbl_fd ON tbl_fd.question_id = q.id
                                                    LEFT JOIN tbl_field_diagrammed_images tbl_fdi ON tbl_fdi.question_id = q.id
                                                    LEFT JOIN tbl_parent_img AS tbl_pi ON tbl_pi.id = q.id
                                                    LEFT JOIN question_shares qs ON qs.question_id = q.id AND qs.subtopic_id = p_subtopic_id AND qs.deleted_at IS NULL
                                                    WHERE 1 = 1
                                                    AND q.id = p_question_id;
                                                END;
                                            $$;


ALTER FUNCTION questions.fn_find_question_for_previewer(p_question_id integer, p_subtopic_id integer) OWNER TO postgres;

--
