-- Function: odiseo.fn_find_parent_question(bigint)

--

CREATE FUNCTION odiseo.fn_find_parent_question(p_parent_question_id bigint) RETURNS TABLE(subquestion jsonb, parent_id bigint, category_id bigint, category character varying, subcategory_id bigint, subcategory character varying, level_id bigint, course_id smallint)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            WITH cte_question_verified AS (
                SELECT  
                    pq.id AS parent_id,
                    q.id question_id,
                    ROW_NUMBER () OVER (
                        PARTITION BY 
                            q.parent_id, 
                            CASE 
                                WHEN q.status = 'APRB' THEN 'VERI'
                                ELSE q.status 
                            END
                    ) AS total_veri,
                    pq.type_text_id,
                    pq.type_text_subcategory_id,
                    pq.level_id,
                    pq.course_id,
                    pq.code,
                    tt.name category,
                    tts.name subcategory
                FROM parent_question pq 
                JOIN question q ON q.parent_id = pq.id
                JOIN type_text tt ON tt.id = pq.type_text_id
                JOIN type_text_subcategories tts ON tts.id = pq.type_text_subcategory_id
                WHERE q.status IN ('VERI', 'APRB')
                AND pq.status NOT IN ('ARCH', 'DUPL')
                ORDER BY pq.id
            ), cte_validate_min_verified AS (
            SELECT 
                cqv.parent_id,
                cqv.type_text_id category_id,
                cqv.type_text_subcategory_id subcategory_id,
                cqv.level_id,
                cqv.course_id,
                cqv.code,
                cqv.category,
                cqv.subcategory
            FROM cte_question_verified cqv
            WHERE cqv.total_veri >= 2
            AND cqv.type_text_id IS NOT NULL
            AND cqv.type_text_subcategory_id IS NOT NULL
            GROUP BY 
            cqv.parent_id,
            cqv.type_text_id,
            cqv.type_text_subcategory_id,
            cqv.level_id,
            cqv.course_id,
            cqv.code,
            cqv.category,
            cqv.subcategory
            ), subtopics_agg AS (
                SELECT
                    qs.question_id,
                    JSONB_AGG(JSONB_BUILD_OBJECT('id', qs.subtopic_id)) AS subtopics_json
                FROM question_subtopic qs
                WHERE qs.fl_status = true
                GROUP BY qs.question_id
            )
            SELECT
                JSONB_AGG(
                    JSONB_BUILD_OBJECT(
                        'code', q.code,
                        'question_id', q.id,
                        'topic_id', q.topic_id,
                        'course_id', q.course_id,
                        'level_id', q.level_id,
                        'subtopics', COALESCE(sa.subtopics_json, '[]'::jsonb)
                    )
                ) AS subquestion,
                cvmv.parent_id,
                cvmv.category_id,
                cvmv.category,
                cvmv.subcategory_id,
                cvmv.subcategory,
                cvmv.level_id,
                cvmv.course_id
            FROM cte_validate_min_verified cvmv
            JOIN question q ON q.parent_id = cvmv.parent_id
            LEFT JOIN subtopics_agg sa ON q.id = sa.question_id
            WHERE q.status IN ('VERI', 'APRB')
            AND cvmv.parent_id = p_parent_question_id
            GROUP BY 
                cvmv.parent_id,
                cvmv.category_id,
                cvmv.subcategory_id,
                cvmv.level_id,
                cvmv.course_id,
                cvmv.code,
                cvmv.category, 
                cvmv.subcategory;
        END;
    $$;


ALTER FUNCTION odiseo.fn_find_parent_question(p_parent_question_id bigint) OWNER TO postgres;

--
