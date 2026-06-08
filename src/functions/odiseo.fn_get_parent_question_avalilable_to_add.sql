-- Function: odiseo.fn_get_parent_question_avalilable_to_add(integer, integer, character varying, smallint, integer[], integer[], smallint, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_get_parent_question_avalilable_to_add(p_perpage integer, p_npage integer, p_search character varying, p_course_id smallint, p_category_id integer[], p_subcategory_id integer[], p_level_id smallint, p_material_id bigint, p_distribution_id bigint) RETURNS TABLE(code character varying, subquestion jsonb, id bigint, category_id bigint, category character varying, subcategory_id bigint, subcategory character varying, level_id bigint, level smallint, course_id smallint, course text, history jsonb, expected_subquestion jsonb, type_question text, total_count bigint)
    LANGUAGE plpgsql
    AS $$
                        DECLARE
                            offset_val INTEGER;
                        BEGIN
                            offset_val := p_perpage * (p_npage - 1);
                            
                            RETURN QUERY
                            WITH 
                            base_data_cte AS (
                                SELECT 
                                    fpqvm.code, fpqvm.subquestion, fpqvm.parent_id AS id, fpqvm.category_id, fpqvm.category,
                                    fpqvm.subcategory_id, fpqvm.subcategory, fpqvm.level_id, l.name::SMALLINT AS level,
                                    fpqvm.course_id, CONCAT(c.code, '-', c.name) AS course, fpqvm.history,
                                    COALESCE(
                                        (SELECT JSONB_AGG(
                                            JSONB_BUILD_OBJECT(
                                                'question_id', mbs.question_id,
                                                'topic_id', mbs.topic_id,
                                                'course_id', mbs.course_id,
                                                'subtopic_id', mbs.subtopic_id
                                            ) ORDER BY mbs.position ASC
                                        ) FROM material_ballot_subquestions mbs
                                        WHERE mbs.material_ballot_question_id = p_distribution_id AND mbs.fl_status = TRUE),
                                        '[]'::jsonb
                                    ) AS expected_subquestion
                                FROM fn_parent_question_verified_material(p_material_id, 'T') fpqvm
                                JOIN course c ON fpqvm.course_id = c.id
                                JOIN level l ON l.id = fpqvm.level_id
                            ),
                            question_verified_cte AS (
                                SELECT *
                                FROM base_data_cte AS bdc
                                WHERE 
                                    (p_search IS NULL OR bdc.code ILIKE '%' || p_search || '%') AND
                                    (p_course_id IS NULL OR bdc.course_id = p_course_id) AND
                                    (p_category_id IS NULL OR bdc.category_id = ANY(p_category_id)) AND
                                    (p_subcategory_id IS NULL OR bdc.subcategory_id = ANY(p_subcategory_id)) AND
                                    (p_level_id IS NULL OR bdc.level_id = p_level_id)
                                    AND EXISTS (
                                        SELECT 1 FROM jsonb_array_elements(bdc.expected_subquestion) AS expected(item)
                                        WHERE EXISTS (
                                            SELECT 1 FROM jsonb_array_elements(bdc.subquestion) AS available(item)
                                            WHERE (expected.item ->> 'topic_id')::INTEGER = (available.item ->> 'topic_id')::INTEGER
                                            AND (expected.item ->> 'course_id')::INTEGER = (available.item ->> 'course_id')::INTEGER
                                            AND EXISTS (
                                                SELECT 1 FROM jsonb_array_elements(available.item -> 'subtopics') AS sub(item)
                                                WHERE (sub.item ->> 'id')::INTEGER = (expected.item ->> 'subtopic_id')::INTEGER
                                            )
                                        )
                                    )
                            ),
                            question_with_subquestion AS (
                                SELECT 
                                    qvc.id, qvc.code, qvc.category_id, qvc.category, qvc.subcategory_id, qvc.subcategory, qvc.level_id, qvc.level, qvc.course_id, qvc.course, qvc.history,
                                    ( SELECT jsonb_agg( sq.item || jsonb_build_object( 'topic', COALESCE(t.name, '-'), 'level', COALESCE(l.name, '-') ) )
                                        FROM jsonb_array_elements(qvc.subquestion) AS sq(item)
                                        LEFT JOIN topic t ON (sq.item ->> 'topic_id')::INTEGER = t.id
                                        LEFT JOIN level l ON (sq.item ->> 'level_id')::INTEGER = l.id
                                    ) AS subquestion,
                                    ( SELECT jsonb_agg( sq.item || jsonb_build_object('topic', COALESCE(t.name, '-'), 'level', COALESCE(l.name, '-'), 'subtopic', COALESCE(s.name, '-')) )
                                        FROM jsonb_array_elements(qvc.expected_subquestion) AS sq(item)
                                        LEFT JOIN topic t ON (sq.item ->> 'topic_id')::INTEGER = t.id
                                        LEFT JOIN level l ON (sq.item ->> 'level_id')::INTEGER = l.id
                                        LEFT JOIN subtopic s ON (sq.item ->> 'subtopic_id')::INTEGER = s.id
                                    ) AS expected_subquestion,
                                    'T' AS type_question
                                FROM question_verified_cte qvc
                            ),
                            counted_questions AS (
                                SELECT *, COUNT(*) OVER () as total_count
                                FROM question_with_subquestion
                            )
                            SELECT
                                cq.code, cq.subquestion, cq.id, cq.category_id, cq.category, cq.subcategory_id, cq.subcategory,
                                cq.level_id, cq.level, cq.course_id, cq.course, cq.history, cq.expected_subquestion,
                                cq.type_question, cq.total_count
                            FROM counted_questions cq
                            ORDER BY cq.id, cq.code
                            LIMIT p_perpage
                            OFFSET offset_val;
                        END;
                        $$;


ALTER FUNCTION odiseo.fn_get_parent_question_avalilable_to_add(p_perpage integer, p_npage integer, p_search character varying, p_course_id smallint, p_category_id integer[], p_subcategory_id integer[], p_level_id smallint, p_material_id bigint, p_distribution_id bigint) OWNER TO postgres;

--
