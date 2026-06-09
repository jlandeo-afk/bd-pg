-- Function: questions.fn_find_approved_question_for_word_download(integer)

--

CREATE FUNCTION questions.fn_find_approved_question_for_word_download(p_question_id integer) RETURNS TABLE(id bigint, description text, number character varying, parent_id bigint, config_alternative smallint, code_course character varying, name_course character varying, answer_id bigint, alternatives jsonb, question_image jsonb, theory_base text, data_unknown text, development text, answer text, url_file_digitalized_solution character varying, question_image_digitalized jsonb)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    q.id as question_id,
                    q.description,
                    q.number,
                    q.parent_id,
                    ca."columns" as config_alternative,
                    c.code  as code_course,
                    c.name as name_course,
                    q.answer_id,
                    (
                        SELECT jsonb_agg(jsonb_build_object('id_anwer', a.id, 'alternative_description', a.description))
                        FROM questions.alternative a
                        WHERE a.question_id = q.id
                    ) as alternatives,
                    (
                        SELECT jsonb_agg(
                            jsonb_build_object(
                                'id', qi.id,
                                'code', qi.code,
                                'image', qi.image
                            )
                        )
                        FROM questions.question_image qi
                        WHERE qi.question_id = q.id
                    ) as question_image,
                    edq.theory_base,
                    edq.data_unknown,
                    edq."development " as development,
                    edq.answer,
                    edq.url_file_digitalized_solution,
                    COALESCE(
                        jsonb_agg(
                            jsonb_build_object(
                                'code', edqi.code,
                                'image', edqi.image
                            )
                        ) FILTER (WHERE edqi.employee_didi_question_id IS NOT NULL),
                        '[]'::jsonb
                    ) as question_image_digitalized
                FROM
                    questions.question q
                    left join questions.configuration_alternative ca on q.config_alternative_id = ca.id
                    LEFT JOIN academic.course c ON q.course_id = c.id
                    LEFT JOIN questions.employee_didi_question edq ON edq.question_id = q.id
                    LEFT JOIN questions.employee_didi_question_image edqi ON edqi.employee_didi_question_id = edq.id
                WHERE  q.id = p_question_id
                GROUP BY
                    q.id,
                    q.description,
                    q.number,
                    q.parent_id,
                    ca."columns",
                    c.code,
                    c.name,
                    q.answer_id,
                    alternatives,
                    question_image,
                    edq.theory_base,
                    edq.data_unknown,
                    edq."development ",
                    edq.url_file_digitalized_solution,
                    edq.answer;
            END;
            $$;


ALTER FUNCTION questions.fn_find_approved_question_for_word_download(p_question_id integer) OWNER TO postgres;

--
