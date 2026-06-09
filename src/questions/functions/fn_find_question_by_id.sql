-- Function: questions.fn_find_question_by_id(integer)

--

CREATE FUNCTION questions.fn_find_question_by_id(p_question_id integer) RETURNS TABLE(id bigint, question_id bigint, code character varying, number character varying, description text, answer_id bigint, column_question smallint, parent_id bigint, parent_description text, parent_description_b text, parent_traduction text, config_alternative smallint, course_id smallint, code_course character varying, course character varying, course_agreement_url character varying, area_agreement_url character varying, topic_id smallint, status character varying, url_pdf character varying, alternatives json, images json, parent_images json, question_maths json, alternative_maths json, type_question character varying)
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
            q.id AS id,
            q.id AS question_id,
            q.code,
            q.number,
            q.description,
            q.answer_id,
            q.columns AS column_question,
            q.parent_id,
            tbl_pi.parent_description::text,
            tbl_pi.parent_description_b::text,
            tbl_pi.parent_traduction::text,
            ca.columns AS config_alternative,
            c.id AS course_id,
            c.code AS code_course,
            c.name AS course,
            c.agreement_url as course_agreement_url,
            a.agreement_url as area_agreement_url,
            q.topic_id,
            q.status,
            q.url_pdf,
            -- Alternativas
            COALESCE(tbl_a.alternatives::JSON, '[]'::JSON) AS alternatives,
            -- Imágenes de la pregunta
            COALESCE(tbl_qi.images::JSON, '[]'::JSON) AS images,
            COALESCE(tbl_pi.parent_images::JSON, '[]'::JSON) AS parent_images,
            -- Maths de pregunta y alternativas
            COALESCE(tbl_qm.question_maths::JSON, '[]'::JSON) AS question_maths,
            COALESCE(tbl_am.alternative_maths::JSON, '[]'::JSON) AS alternative_maths,
            CASE WHEN q.parent_id IS NOT NULL THEN 'S'::character varying ELSE 'P'::character varying END AS type_question
        FROM
            question q
        LEFT JOIN course c ON q.course_id = c.id
        LEFT JOIN area a ON c.area_id = a.id
        LEFT JOIN configuration_alternative ca ON q.config_alternative_id = ca.id
        LEFT JOIN tbl_alternative tbl_a ON tbl_a.question_id = q.id
        LEFT JOIN tbl_question_images tbl_qi ON tbl_qi.question_id = q.id
        LEFT JOIN tbl_parent_img AS tbl_pi ON tbl_pi.id = q.id
        LEFT JOIN tbl_question_math tbl_qm ON tbl_qm.question_id = q.id
        LEFT JOIN tbl_alternative_math tbl_am ON tbl_am.question_id = q.id
        WHERE 1 = 1 
        AND q.id = p_question_id;
        END;
$$;


ALTER FUNCTION questions.fn_find_question_by_id(p_question_id integer) OWNER TO postgres;

--
