-- Function: questions.fn_find_question_digitalized_for_download(integer)

--

CREATE FUNCTION questions.fn_find_question_digitalized_for_download(p_question_id integer) RETURNS TABLE(question_id bigint, code character varying, description text, number character varying, parent_id bigint, config_alternative smallint, code_course character varying, name_course character varying, url_file_digitalized_solution character varying, url_file_digitalized_images text, answer_id bigint, alternatives jsonb, question_images jsonb, diagram_fields jsonb, field_images jsonb, column_question smallint)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            SELECT
                q.id as question_id,
                q.code,
                q.description,
                q.number,
                q.parent_id,
                ca."columns" AS config_alternative,
                c.code AS code_course,
                c.name AS name_course,
                edq.url_file_digitalized_solution,
                edq.url_file_digitalized_images,
                q.answer_id,
                -- Alternativas
                COALESCE(
			            jsonb_agg(
			                DISTINCT jsonb_build_object(
			                    'id_anwer', sub_a.id,
			                    'alternative_description', sub_a.description
			                )
			            )
			            FILTER (WHERE sub_a.id IS NOT NULL),
			            '[]'::jsonb
			        ) AS alternatives,

                -- Imágenes de la pregunta
                COALESCE(
                    jsonb_agg(DISTINCT jsonb_build_object('id', qi.id, 'code', qi.code, 'image', qi.image))
                    FILTER (WHERE qi.id IS NOT NULL),
                    '[]'::jsonb
                ) AS question_images,

                -- Campos de diagramar
			    COALESCE(
			        jsonb_agg(
			            DISTINCT jsonb_build_object('field', tbl_field_diagrammed.field, 'value', tbl_field_diagrammed.field_value, 'created_at', tbl_field_diagrammed.created_at, 'field_digrammed_id',tbl_field_diagrammed.id)
			        )
			        FILTER (WHERE tbl_field_diagrammed.field IS NOT NULL),
			        '[]'::jsonb
			    ) AS diagram_fields,

                -- Imágenes adicionales
                COALESCE(
                    jsonb_agg(
                        DISTINCT jsonb_build_object('id', edqfi.id, 'code', edqfi.code, 'image', edqfi.image)
                    )
                    FILTER (WHERE edqfi.id IS NOT NULL AND edqfi.fl_status = true),
                    '[]'::jsonb
                ) AS field_images,
                q.columns AS column_question
            FROM
                questions.employee_didi_question edq
            LEFT JOIN
                questions.employee_didi_question_field_image edqfi ON edqfi.employee_didi_question_id = edq.id AND edqfi.fl_status = true
	       LEFT JOIN (
	        SELECT  DISTINCT
	            edqf.employee_didi_question_id,
	            fd."name" AS field,
	            edqf.value AS field_value,
	            edqf.created_at,
	            edqf.id
	        FROM
	            questions.employee_didi_question_field edqf
	        LEFT JOIN
	            academic.setting_diagrammed_courses sdc ON edqf.setting_diagrammed_course_id = sdc.id
	        LEFT JOIN
	            questions.field_diagrammed fd ON sdc.field_diagram_id = fd.id
	        where edqf.fl_status = true
	        ORDER BY
	            edqf.created_at ASC, edqf.id ASC
	    ) AS tbl_field_diagrammed ON edq.id = tbl_field_diagrammed.employee_didi_question_id
            JOIN
                questions.question q ON q.id = edq.question_id
            LEFT JOIN
                academic.course c ON q.course_id = c.id
            LEFT JOIN
                questions.configuration_alternative ca ON q.config_alternative_id = ca.id
            LEFT JOIN (
		        SELECT *
		        FROM questions.alternative AS a
		        ORDER BY a.created_at ASC, a.id ASC  -- Cambia el criterio de orden si es necesario
		    ) AS sub_a ON sub_a.question_id = q.id
            LEFT JOIN
                questions.question_image qi ON qi.question_id = q.id

            WHERE q.id = p_question_id AND edq.fl_status = true
            GROUP BY
                q.id,
                q.code,
                q.description,
                q.number,
                q.parent_id,
                ca."columns",
                c.code,
                c.name,
                edq.url_file_digitalized_solution,
                edq.url_file_digitalized_images,
                q.answer_id;
        END;
        $$;


ALTER FUNCTION questions.fn_find_question_digitalized_for_download(p_question_id integer) OWNER TO postgres;

--
