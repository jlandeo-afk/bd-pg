-- Function: questions.fn_get_verified_questions_summary_teacher(integer)

--

CREATE FUNCTION questions.fn_get_verified_questions_summary_teacher(f_teacher_id integer) RETURNS TABLE(start_date date, end_date date, statuses json)
    LANGUAGE plpgsql
    AS $$
                        DECLARE
                            v_cut_off_date INTEGER;
                        BEGIN
                            SELECT ads.cut_off_date INTO v_cut_off_date
                            FROM advanced_settings AS ads
                            WHERE ads.fl_status = TRUE
                            LIMIT 1;

                            RETURN QUERY
                            WITH date_range AS (
                                SELECT
                                    CURRENT_TIMESTAMP - INTERVAL '30 days' AS start_date,
                                    NOW() end_date
                            ),
                            first_verified_date AS (
                                SELECT
                                    qss.question_id,
                                    MIN(qss.created_at) created_at
                                FROM question_status qss
                                WHERE qss.status = 'VERI'
                                GROUP BY qss.question_id
                            ),
                            valid_questions_in_range AS (
                                SELECT
                                    vq.id,
                                    vq.parent_id,
                                    vq.status
                                FROM question vq
                                JOIN first_verified_date fvd ON fvd.question_id = vq.id
                                WHERE vq.fl_status = TRUE
                                AND vq.deleted_at IS NULL
                                AND fvd.created_at >= (SELECT dr.start_date FROM date_range dr)
                            ),
                            teacher_questions AS (
                                SELECT 
                                    vqr.id,
                                    vqr.parent_id,
                                    vqr.status
                                FROM valid_questions_in_range vqr
                                INNER JOIN employee_question eq ON eq.question_id = vqr.id
                                WHERE eq.teacher_id = f_teacher_id 
                                AND eq.fl_status = TRUE
                            ),
                            standalone_counts AS (
                                SELECT tq.status
                                FROM teacher_questions tq
                                WHERE tq.parent_id IS NULL
                                AND tq.status IN ('VERI','PEND','RESV', 'APRB')
                            ),
                            parent_counts AS (
                                SELECT pq.status
                                FROM parent_question pq
                                WHERE pq.id IN (SELECT DISTINCT parent_id FROM teacher_questions WHERE parent_id IS NOT NULL)
                                AND pq.status IN ('VERI','PEND','RESV', 'APRB')
                            ),
                            all_rows AS (
                                SELECT sc.status FROM standalone_counts sc
                                UNION ALL
                                SELECT pc.status FROM parent_counts pc
                            ),
                            base_statuses AS (
                                SELECT unnest(ARRAY['VERI', 'PEND', 'RESV', 'APRB']) AS status
                            ), result_status AS (
                                SELECT
                                    bs.status::varchar,
                                    COUNT(ar.status)::bigint AS total_count
                                FROM base_statuses bs
                                LEFT JOIN all_rows ar ON bs.status = ar.status
                                GROUP BY bs.status
                                ORDER BY bs.status
                            ) 
                            SELECT 
                                dr.start_date::date, 
                                dr.end_date::date, 
                                json_agg(
                                    json_build_object(
                                        'status', rs.status,
                                        'total_count', rs.total_count 
                                    )
                                ) AS statuses
                            FROM date_range dr, result_status rs
                            GROUP BY dr.start_date, dr.end_date;

                        END;
                        $$;


ALTER FUNCTION questions.fn_get_verified_questions_summary_teacher(f_teacher_id integer) OWNER TO postgres;

--
