-- Function: odiseo.fn_didi_questions_totals_v2(bigint)

--

CREATE FUNCTION odiseo.fn_didi_questions_totals_v2(f_didi_id bigint) RETURNS TABLE(assigned_to_didi bigint, observed_digitalized bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        SUM(
            CASE
                WHEN q.status = 'DASI' THEN 1
                ELSE 0
            END
        ) AS assigned_to_didi,
            SUM(
                CASE
                    WHEN q.status = 'OBSE' THEN 1
                    ELSE 0
                END
        ) AS observed_digitalized
    FROM odiseo.employee_didi_question edq
    JOIN odiseo.question q
      ON edq.question_id = q.id
     AND q.fl_status IS TRUE
     AND edq.fl_status IS TRUE
     AND ( f_didi_id IS NULL OR edq.employee_id = f_didi_id );
END;
$$;


ALTER FUNCTION odiseo.fn_didi_questions_totals_v2(f_didi_id bigint) OWNER TO postgres;

--
