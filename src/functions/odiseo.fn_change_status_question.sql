-- Function: odiseo.fn_change_status_question(integer, character varying, integer)

--

CREATE FUNCTION odiseo.fn_change_status_question(p_id integer, p_status character varying, p_updated_by integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_question_id INTEGER;
            BEGIN
                UPDATE odiseo.question
                SET
                    status = p_status,
                    teacher_id = CASE
                                    WHEN p_status = 'SASI' THEN NULL
                                    ELSE teacher_id
                                END,
                    updated_by = p_updated_by,
                    updated_at = now()
                WHERE
                    id = p_id
                RETURNING id INTO v_question_id;

                IF p_status = 'SASI' THEN
                    UPDATE odiseo.employee_question
                    SET
                        fl_status = false,
                        deleted_by = p_updated_by,
                        deleted_at = now()
                    WHERE
                        question_id = p_id;
                END IF;

                RETURN v_question_id;
            END;
            $$;


ALTER FUNCTION odiseo.fn_change_status_question(p_id integer, p_status character varying, p_updated_by integer) OWNER TO postgres;

--
