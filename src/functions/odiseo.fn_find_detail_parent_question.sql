-- Function: odiseo.fn_find_detail_parent_question(integer, boolean)

--

CREATE FUNCTION odiseo.fn_find_detail_parent_question(p_question_id integer, p_status boolean) RETURNS TABLE(id bigint, code character varying, description text, short_description text, text_traduction text, short_text_traduction text, description_b text, short_description_b text, number_question character varying, number character varying, course_id smallint, code_course character varying, course character varying, status character varying, url_pdf character varying, observation text, similitaries text, type_text_id bigint, level_id bigint, type_text_subcategory_id bigint, subquestions jsonb, question_columns smallint, type_text_template_id smallint, type_text_template_name character varying, description_text character varying, text_attributes character varying, subquestion_attributes character varying, priority integer, category_assigned_id bigint)
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                        RETURN QUERY
                        SELECT
                            pq.id,
                            pq.code,
                            pq.description,
                            pq.short_description,
                            pq.text_traduction,
                            pq.short_text_traduction,
                            pq.description_b,
                            pq.short_description_b,
                            pq.number_question,
                            pq.number,
                            pq.course_id,
                            c.code AS code_course,
                            c.name AS course,
                            pq.status,
                            pq.url_pdf,
                            po.description  as observation,
                            po.similitaries  as similitaries,
                            pq.type_text_id,
                            pq.level_id,
                            pq.type_text_subcategory_id,
                            (SELECT jsonb_agg(
                                (SELECT to_jsonb(fnp.*)
                                FROM fn_find_question_for_previewer(q.id::integer, qs.id::integer) fnp)
                            )
                            FROM question q 
                            LEFT JOIN question_subtopic qs ON q.id = qs.question_id
                            WHERE q.parent_id = pq.id) AS subquestions,
                            pq.columns,
                            ttt.id,
                            ttt.name as type_text_template_name,
                            ttt.description_text as description_text,
                            ttt.text_attributes,
                            ttt.subquestion_attributes,
                            pq.priority,
                            cac.id as category_assigned_id 
                        FROM parent_question pq
                        LEFT JOIN parent_observation po ON pq.id = po.parent_id AND po.fl_status = true AND po.type = pq.status
                        LEFT JOIN course c ON pq.course_id = c.id
                        LEFT JOIN users u ON pq.created_by = u.id
                        LEFT JOIN type_text_templates ttt on c.type_text_template_id = ttt.id
                        LEFT JOIN course_assigned_categories cac on cac.course_id = c.id AND cac.type_text_id = pq.type_text_id AND cac.deleted_at IS NULL
                        WHERE pq.id = p_question_id
                        AND pq.fl_status = p_status
                        AND pq.deleted_at IS NULL;
                    END;
                    $$;


ALTER FUNCTION odiseo.fn_find_detail_parent_question(p_question_id integer, p_status boolean) OWNER TO postgres;

--
