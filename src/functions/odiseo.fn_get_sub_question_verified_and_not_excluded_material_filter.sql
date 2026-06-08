-- Function: odiseo.fn_get_sub_question_verified_and_not_excluded_material_filter(integer, integer, integer, bigint, integer, integer, character varying, integer, character varying)

--

CREATE FUNCTION odiseo.fn_get_sub_question_verified_and_not_excluded_material_filter(p_perpage integer, p_npage integer, p_parent_question_id integer, p_material_id bigint, p_topic_id integer, p_subtopic_id integer, p_search character varying, p_distribution_id integer, p_status character varying) RETURNS TABLE(code text, parent_id bigint, topic_id integer, topic character varying, question_id bigint, course_id smallint, course text, subtopics jsonb, history jsonb, status character varying, total_count bigint)
    LANGUAGE plpgsql
    AS $$
                    DECLARE
                        offset_val INTEGER;
                        v_fl_exam BOOLEAN;
                    BEGIN
                        offset_val := p_perpage * (p_npage - 1);

                        RETURN QUERY
                        WITH subquestion_cte AS (
                            SELECT 
                                subq->>'code' AS code,
                                fpqvm.parent_id,
                                (subq->>'topic_id')::int AS topic_id,
                                t.name AS topic_name,
                                (subq->>'question_id')::bigint AS question_id,
                                fpqvm.course_id AS course_id,
                                CONCAT(c.code, '-', c.name) AS course,
                                (
                                    SELECT jsonb_agg(
                                            jsonb_build_object(
                                                'id', (st_json->>'id')::int,
                                                'name', st.name
                                            )
                                        )
                                    FROM jsonb_array_elements(subq->'subtopics') st_json
                                    LEFT JOIN subtopic st ON (st_json->>'id')::int = st.id
                                ) AS subtopics,
                                fpqvm.history,
                                q.status
                            FROM fn_parent_question_verified_material(p_material_id, 'S') fpqvm
                            CROSS JOIN LATERAL jsonb_array_elements(fpqvm.subquestion::jsonb) subq
                            JOIN course c ON fpqvm.course_id = c.id
                            JOIN topic t ON (subq->>'topic_id')::int = t.id
                            JOIN question q ON q.id = (subq->>'question_id')::bigint
                            WHERE fpqvm.parent_id = p_parent_question_id
                            AND (p_topic_id IS NULL OR (subq->>'topic_id')::int = p_topic_id)
                                                AND (
                                p_subtopic_id IS NULL OR EXISTS (
                                    SELECT 1
                                    FROM jsonb_array_elements(subq->'subtopics') st_json
                                    WHERE (st_json->>'id')::int = p_subtopic_id
                                )
                            )
                            AND (p_search IS NULL OR subq->>'code' ILIKE '%' || p_search || '%')
                            AND (p_status IS NULL OR q.status = p_status)
                        ), question_found_cte AS (
                            SELECT 
                                mbs.question_id::int AS question_id
                            FROM material_ballot_subquestions mbs
                            WHERE mbs.material_ballot_question_id = p_distribution_id
                            AND mbs.state = 'GENERATED'
                            AND mbs.fl_status = TRUE
                        ), validate_subquestion_cte AS (
                            SELECT sc.*
                            FROM subquestion_cte sc
                            LEFT JOIN question_found_cte qfc 
                            ON sc.question_id = qfc.question_id
                            WHERE qfc.question_id IS NULL
                        )
                        SELECT vsc.*, COUNT(*) OVER () AS total_count
                        FROM validate_subquestion_cte as vsc
                        LIMIT p_perpage
                        OFFSET offset_val;

                    END;
                $$;


ALTER FUNCTION odiseo.fn_get_sub_question_verified_and_not_excluded_material_filter(p_perpage integer, p_npage integer, p_parent_question_id integer, p_material_id bigint, p_topic_id integer, p_subtopic_id integer, p_search character varying, p_distribution_id integer, p_status character varying) OWNER TO postgres;

--
