-- Function: questions.get_question_alternatives_and_file_solution(bigint)

--

CREATE FUNCTION questions.get_question_alternatives_and_file_solution(p_question_id bigint) RETURNS TABLE(question_id bigint, question_description text, number character varying, code_course character varying, name_course character varying, topic character varying, subtopics jsonb, type_question character varying, ter numeric, level character varying, answer_id bigint, document_solution text, editor_content text, editor_images jsonb, url_pdf_question_solution character varying, alternatives jsonb, file_solution jsonb, question_image jsonb, config_alternative smallint, column_question smallint, description_observation text, boards_observation text, question_attributes jsonb)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                WITH
                alternatives_data AS (
                    SELECT
                        a.question_id,
                        jsonb_agg(
                            jsonb_build_object(
                            'id_answer', a.id,
                            'alternative_description', a.description
                            ) ORDER BY a.created_at ASC, a.id ASC
                        ) AS alternatives
                    FROM alternative a
                    WHERE a.question_id = p_question_id
                    GROUP BY a.question_id
                ),
                file_solution_data AS (
                    SELECT
                        eq2.question_id,
                        jsonb_agg(jsonb_build_object(
                            'question_id', eq2.question_id,
                            'file_document', eqc.document,
                            'document_solution', eq2.document_solution,
                            'type_archive_id', eqc.type_archive_id
                        )) AS file_solution
                    FROM employee_question eq2
                    INNER JOIN employee_question_document eqc
                        ON eqc.employee_question_id = eq2.id
                    WHERE eq2.question_id = p_question_id
                    GROUP BY eq2.question_id
                ),
                question_image_data AS (
                    SELECT
                        qi.question_id,
                        jsonb_agg(jsonb_build_object(
                            'code', qi.code,
                            'image', qi.image
                        )) AS question_image
                    FROM question_image qi
                    WHERE qi.question_id = p_question_id
                    GROUP BY qi.question_id
                ),
                observed_question AS (
                    SELECT qo.id, qo.question_id, qo.description, qo.boards_observation
                    FROM question_observation qo
                    LEFT JOIN users u  on qo.created_by = u.id
                    LEFT JOIN employees e on e.user_id = u.id
                    WHERE qo.question_id = p_question_id  and qo."type" = 'OBSE' and qo.fl_status = true
                    LIMIT 1
                )
                ,
                question_subtopic_data AS (
                    SELECT
                        q.id AS question_id,
                        jsonb_agg(jsonb_build_object(
                            'id', s.id,
                            'subtopic', s."name"
                        )) AS subtopics
                    FROM question q
                    LEFT JOIN question_subtopic qs
                        ON qs.question_id = q.id
                        AND qs.fl_status = true
                        AND qs.deleted_at IS null
                    LEFT JOIN subtopic s
                        ON qs.subtopic_id = s.id
                    AND q.fl_status = true
                    GROUP BY q.id
                ),
                editor_images_data AS (
                    SELECT
                        eqi.employee_question_id,
                        jsonb_agg(jsonb_build_object(
                            'code', eqi.code,
                            'extension', eqi.extension,
                            'image', eqi.image
                        )) AS editor_images
                    FROM employee_question_image eqi
                    GROUP BY eqi.employee_question_id
                ), course_question AS (
                    SELECT
                        q.course_id,
                        CASE
                            WHEN q.parent_id IS NULL THEN 'P'
                            ELSE 'S'
                        END type
                    FROM question q
                    WHERE q.id = p_question_id
                ), attributes_course AS (
                    SELECT
                        qatc.course_id,
                        qat.id AS question_attribute_type_id,
                        qat.name,
                        qatv.label,
                        qatv.description,
                        qatv.value
                    FROM question_attributes_type_course qatc
                    JOIN course_question cq ON cq.course_id = qatc.course_id
                    JOIN question_attributes_type qat ON qatc.question_attributes_type_id = qat.id
                        AND qat.deleted_at IS NULL
                    LEFT JOIN question_attributes qa ON qatc.id = qa.question_attributes_type_id
                        AND qa.deleted_at IS NULL
                        AND qa.question_id = p_question_id
                    LEFT JOIN question_attributes_types_values qatv ON qat.id = qatv.question_attributes_type_id
                        AND qatv.deleted_at IS NULL
                        AND qatv.value = qa.value
                    WHERE qatc.types_questions ILIKE '%' || cq.type || '%'
                        AND qatc.deleted_at IS NULL
                )
                SELECT
                    q.id AS question_id,
                    q.description AS question_description,
                    q.number,
                    c.code AS code_course,
                    c.name AS name_course,
                    t."name" AS topic,
                    qsd.subtopics AS subtopics,
                    q.type AS type_question,
                    q.ter AS ter,
                    l.description AS level,
                    q.answer_id,
                    eq.document_solution,
                    eq.editor_content::text,
                    eid.editor_images AS editor_images,
                    eq.url_pdf_question_solution,
                    alt.alternatives,
                    fs.file_solution,
                    qi.question_image,
                    ca."columns" AS config_alternative,
                    q."columns" AS column_question,
                    oq.description description_observation,
                    oq.boards_observation,
                    COALESCE(
                        JSONB_AGG(
                            JSONB_BUILD_OBJECT (
                                'question_attribute_type_id', ac.question_attribute_type_id,
                                'name', ac.name,
                                'label', ac.label,
                                'description', ac.description,
                                'value', ac.value
                            ) ORDER BY ac.question_attribute_type_id
                        ) FILTER (WHERE ac.question_attribute_type_id IS NOT NULL), '[]'::jsonb
                    ) AS question_attributes
                FROM employee_question eq
                LEFT JOIN editor_images_data eid
                    ON eid.employee_question_id = eq.id
                INNER JOIN question q
                    ON eq.question_id = q.id
                LEFT JOIN topic t
                    ON q.topic_id = t.id
                INNER JOIN course c
                    ON q.course_id = c.id
                LEFT JOIN level l
                    ON q.level_id = l.id
                LEFT JOIN configuration_alternative ca
                    ON q.config_alternative_id = ca.id
                LEFT JOIN alternatives_data alt
                    ON alt.question_id = q.id
                LEFT JOIN file_solution_data fs
                    ON fs.question_id = q.id
                LEFT JOIN question_image_data qi
                    ON qi.question_id = q.id
                LEFT JOIN question_subtopic_data qsd
                    ON qsd.question_id = q.id
                LEFT JOIN observed_question oq
                    ON oq.question_id = q.id
                LEFT JOIN attributes_course ac
                    ON ac.course_id = q.course_id
                WHERE eq.question_id = p_question_id
                AND eq.fl_status = TRUE
                GROUP BY q.id,
                    c.code, c.name,
                    t."name",
                    eq.document_solution, eq.editor_content,
                    eid.editor_images,
                    eq.url_pdf_question_solution,
                    ca."columns", alt.alternatives, fs.file_solution, qi.question_image, qsd.subtopics, l.description,
                    oq.description, oq.boards_observation;
            END;
            $$;


ALTER FUNCTION questions.get_question_alternatives_and_file_solution(p_question_id bigint) OWNER TO postgres;

--
