-- Function: odiseo.fn_insert_question_status(integer, character varying, character varying, character varying, bigint)

--

CREATE FUNCTION odiseo.fn_insert_question_status(p_question_id integer, p_status character varying, process character varying, description character varying, p_created_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
            BEGIN
                UPDATE odiseo.question_status
                SET fl_active = false
                WHERE question_id = p_question_id;

                INSERT INTO odiseo.question_status (question_id, status, process, description, created_by, created_at)
                VALUES (p_question_id, p_status, process, description, p_created_by, now());
            END;
            $$;


ALTER FUNCTION odiseo.fn_insert_question_status(p_question_id integer, p_status character varying, process character varying, description character varying, p_created_by bigint) OWNER TO postgres;

--
