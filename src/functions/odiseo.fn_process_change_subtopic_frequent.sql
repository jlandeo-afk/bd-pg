-- Function: odiseo.fn_process_change_subtopic_frequent(integer, integer, integer, character varying)

--

CREATE FUNCTION odiseo.fn_process_change_subtopic_frequent(p_question_id integer, p_new_subtopic_id integer, p_user_id integer, p_method_origin character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
                                DECLARE
                                    v_old_subtopic_id INT;
                                    v_is_subtopic_equal BOOLEAN;
                                    rec RECORD;
                                BEGIN
                                    SELECT qs.subtopic_id 
                                    INTO v_old_subtopic_id
                                    FROM question q
                                    LEFT JOIN question_subtopic qs ON qs.question_id = q.id AND qs.fl_status = true
                                    WHERE q.id = p_question_id
                                    LIMIT 1;

                                    v_is_subtopic_equal := (COALESCE(v_old_subtopic_id, -1) = COALESCE(p_new_subtopic_id, -1));

                                    IF NOT v_is_subtopic_equal THEN
                                        UPDATE frequent_university_subtopic fus
                                        SET fl_status = false,
                                            is_frequent = false
                                        FROM origin_question oq
                                        JOIN modality_options mo ON mo.id = oq.modality_option_id AND mo.deleted_at IS NULL
                                        JOIN option_university ou ON ou.university_id = oq.university_id AND ou.deleted_at IS NULL
                                        WHERE oq.question_id = p_question_id
                                        AND oq.fl_status = true
                                        AND fus.university_id = ou.university_id
                                        AND fus.subtopic_id = v_old_subtopic_id;
                                    END IF;

                                    FOR rec IN 
                                        SELECT DISTINCT ou.university_id
                                        FROM origin_question oq
                                        JOIN question q ON oq.question_id = q.id
                                        JOIN modality_options mo ON mo.id = oq.modality_option_id AND mo.deleted_at IS NULL
                                        JOIN option_university ou ON ou.university_id = oq.university_id AND ou.deleted_at IS NULL
                                        WHERE oq.question_id = p_question_id
                                        AND oq.fl_status = true
                                        AND q.fl_status = true
                                    LOOP
                                        PERFORM fn_change_subtopic_frequent_status(
                                            rec.university_id::int,
                                            p_new_subtopic_id::int,
                                            p_user_id::int,
                                            TRUE,
                                            p_method_origin
                                        );
                                    END LOOP;

                                END;
                                $$;


ALTER FUNCTION odiseo.fn_process_change_subtopic_frequent(p_question_id integer, p_new_subtopic_id integer, p_user_id integer, p_method_origin character varying) OWNER TO postgres;

--
