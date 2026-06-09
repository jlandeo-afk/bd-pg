-- Function: questions.fn_parent_question_detail()

--

CREATE FUNCTION questions.fn_parent_question_detail() RETURNS TABLE(id bigint, code character varying, course_id smallint, status character varying, fl_status boolean, questions json)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    pq.id,
                    pq.code,
					pq.course_id,
                    pq.status,
                    pq.fl_status,
                    CASE
                        WHEN count(q.id) > 0 THEN json_agg(q.* ORDER BY
                            CASE
                                WHEN q.type_material_id = 3 THEN 1
                                WHEN q.type_material_id = 2 THEN 2
                                WHEN q.type_material_id = 1 THEN 3
                                WHEN q.type_material_id IS NOT NULL THEN 4
                                ELSE 5
                            END,
                            q.type_material_id ASC,
                            q.id ASC
                        )
                        ELSE '[]'::json
                    END AS questions
                FROM questions.parent_question pq
                LEFT JOIN (
                    SELECT q.id, q.code, q.course_id, q.status, q.parent_id, q.fl_status, qt.type_material_id, t.description
                    FROM questions.question q
					LEFT JOIN questions.question_temporary qt ON qt.question_id = q.id
					LEFT JOIN odiseo.type_material t ON qt.type_material_id = t.id
                    WHERE q.status IN ('SASI', 'DUPL')
                    AND q.fl_status IS TRUE
                    AND (
                        q.number_question IS NULL OR
                        q.number_question NOT ILIKE 'D%'
                    )
                ) q ON pq.id = q.parent_id
                WHERE pq.fl_status IS TRUE
                AND pq.status IN ('SASI', 'ASIG')
                AND (
                    pq.number_question IS NULL OR
                    pq.number_question NOT ILIKE 'D%'
                )
                GROUP BY
                    pq.id,
                    pq.code,
					pq.course_id,
                    pq.status,
                    pq.fl_status
                HAVING jsonb_array_length(CASE
                    WHEN count(q.id) > 0 THEN json_agg(q.*)::jsonb
                    ELSE '[]'::jsonb
                    END) <> 0
                ORDER BY pq.id ASC;
            END;
            $$;


ALTER FUNCTION questions.fn_parent_question_detail() OWNER TO postgres;

--
