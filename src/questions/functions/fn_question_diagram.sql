-- Function: questions.fn_question_diagram(bigint)

--

CREATE FUNCTION questions.fn_question_diagram(p_id bigint) RETURNS TABLE(id bigint, code character varying, description text, course_id smallint, code_course character varying, course character varying, document_solution text, answer_id bigint, answer text, editor_content text, editor_content_images jsonb, alternatives jsonb, images jsonb, file_solution jsonb, topic_name character varying, subtopic_name character varying, subtopics jsonb, diagrammed jsonb, diagrammed_images jsonb, config_alternative_id bigint, columns smallint, question_columns smallint, url_pdf character varying, type_text_id bigint, type_text_template_id smallint, type_text_template_name character varying, description_text character varying, description_subquestion character varying, text_attributes character varying, subquestion_attributes character varying, topic_code character varying, subtopic_code character varying)
    LANGUAGE plpgsql
    AS $$
                        BEGIN
                            RETURN QUERY
                            WITH tbl_diagrammed AS (
                                SELECT
                                    ed.question_id,
                                    jsonb_agg(jsonb_build_object(
                                        'id', edf.id,
                                        'question_id', ed.question_id,
                                        'setting_diagrammed_course_id', edf.setting_diagrammed_course_id,
                                        'value', edf.value,
                                        'position', sd.position,
                                        'diagram_id', sd.id,
                                        'field_diagram', fd.name,
                                        'updated_at', edf.updated_at,
                                        'fl_optional', sd.fl_optional
                                    ))::TEXT AS diagrammed
                                FROM employee_didi_question ed
                                INNER JOIN question q ON ed.question_id = q.id AND q.fl_status IS TRUE
                                INNER JOIN employee_didi_question_field edf ON ed.id = edf.employee_didi_question_id AND edf.fl_status = true
                                INNER JOIN setting_diagrammed_courses sd ON edf.setting_diagrammed_course_id = sd.id
                                INNER JOIN field_diagrammed fd ON sd.field_diagram_id = fd.id
                                WHERE ed.fl_status = true
                                GROUP BY ed.question_id
                            ), tbl_diagrammed_image AS (
                                SELECT
                                    ed.question_id,
                                    jsonb_agg(jsonb_build_object(
                                        'id', edfi.id,
                                        'question_id', ed.question_id,
                                        'code', edfi.code,
                                        'image', edfi.image,
                                        'extension', edfi.extension
                                    ))::TEXT AS diagrammed_images
                                FROM employee_didi_question ed
                                INNER JOIN question q ON ed.question_id = q.id AND q.fl_status IS TRUE
                                INNER JOIN employee_didi_question_field_image edfi ON ed.id = edfi.employee_didi_question_id AND edfi.fl_status = true
                                WHERE ed.fl_status = true
                                GROUP BY ed.question_id
                            )

                            SELECT
                                q.id,
                                q.code,
                                q.description,
                                q.course_id,
                                c.code AS code_course,
                                c.name AS course,
                                eq.document_solution,
                                q.answer_id,
                                a.description AS answer,
                                eq.editor_content,
                                COALESCE((
                                    SELECT jsonb_agg(DISTINCT eqi.*)
                                    FROM employee_question_image eqi
                                    WHERE eqi.employee_question_id = eq.id AND eqi.fl_status = TRUE
                                ), '[]'::jsonb) AS editor_content_images,
                                COALESCE((
                                    SELECT jsonb_agg(at.* ORDER BY at.id ASC)
                                    FROM alternative at
                                    WHERE at.question_id = q.id
                                ), '[]'::jsonb) AS alternatives,
                                COALESCE((
                                    SELECT jsonb_agg(DISTINCT qi.*)
                                    FROM question_image qi
                                    WHERE qi.question_id = q.id
                                    AND qi.fl_status = true
                                ), '[]'::jsonb) AS images,
                                COALESCE((
                                    SELECT jsonb_agg(DISTINCT eqd.*)
                                    FROM employee_question_document eqd
                                    WHERE eqd.employee_question_id = eq.id
                                    AND eqd.fl_status = true
                                ), '[]'::jsonb) AS file_solution,
                                t.name AS topic_name,
                                st.name AS subtopic_name,
                                COALESCE((
                                    SELECT jsonb_agg(
                                        DISTINCT JSONB_BUILD_OBJECT(
                                            'name', st.name,
                                            'code', st.code
                                        )
                                    )
                                    FROM subtopic st
                                    JOIN question_subtopic qst ON qst.subtopic_id = st.id
                                    WHERE qst.question_id = q.id
                                    AND qst.fl_status = true
                                    AND st.fl_status = true
                                ), '[]'::jsonb) AS subtopics,
                                COALESCE(td.diagrammed::JSONB, '[]'::JSONB),
                                COALESCE(tdi.diagrammed_images::JSONB, '[]'::JSONB),
                                q.config_alternative_id,
                                ca.columns,
                                q.columns AS question_columns,
                                q.url_pdf,
                                pq.type_text_id,
                                c.type_text_template_id,
                                ttt.name as type_text_template_name,
                                ttt.description_text,
                                ttt.description_subquestion,
                                ttt.text_attributes,
                                ttt.subquestion_attributes,
                                t.code AS topic_code,
                                st.code AS subtopic_code
                            FROM question q
                            LEFT JOIN alternative a ON q.answer_id = a.id
                            LEFT JOIN course c ON q.course_id = c.id
                            LEFT JOIN type_text_templates ttt on ttt.id = c.type_text_template_id
                            LEFT JOIN employee_question eq ON q.id = eq.question_id AND eq.fl_status = true
                            LEFT JOIN topic t ON t.id = q.topic_id AND t.fl_status = true
                            LEFT JOIN question_subtopic qst ON qst.question_id = q.id AND qst.fl_status = true
                            LEFT JOIN subtopic st ON qst.subtopic_id = st.id AND st.fl_status = true
                            INNER JOIN configuration_alternative ca ON q.config_alternative_id = ca.id
                            LEFT JOIN tbl_diagrammed td ON q.id = td.question_id
                            LEFT JOIN tbl_diagrammed_image tdi ON q.id = tdi.question_id
                            LEFT JOIN parent_question pq ON pq.id = q.parent_id
                            WHERE q.id = p_id;
                        END;
                    $$;


ALTER FUNCTION questions.fn_question_diagram(p_id bigint) OWNER TO postgres;

--
