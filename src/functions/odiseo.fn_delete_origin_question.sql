-- Function: odiseo.fn_delete_origin_question(integer, integer)

--

CREATE FUNCTION odiseo.fn_delete_origin_question(p_origin_question_id integer, p_user_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_university_id INT;
                v_question_id INT;
                v_subtopic_id INT;
                v_has_active_questions BOOLEAN;
            BEGIN

                UPDATE origin_question
                SET fl_status = false,
                    deleted_by = p_user_id,
                    deleted_at = NOW()
                WHERE id = p_origin_question_id
                RETURNING university_id, question_id INTO v_university_id, v_question_id;

                IF NOT FOUND THEN
                    RETURN;
                END IF;

                SELECT subtopic_id INTO v_subtopic_id
                FROM question_subtopic
                WHERE question_id = v_question_id
                AND fl_status = true
                LIMIT 1;

                IF v_subtopic_id IS NULL THEN
                    RETURN;
                END IF;

                SELECT EXISTS (
                    SELECT 1
                    FROM origin_question oq
                    JOIN modality m ON m.id = oq.modality_id
                    JOIN question_subtopic qs ON qs.question_id = oq.question_id
                    WHERE oq.university_id = v_university_id
                    AND qs.subtopic_id = v_subtopic_id
                    AND oq.fl_status = true
                    AND m.fl_allows_mark_frequent_topic = true
                ) INTO v_has_active_questions;

                IF NOT v_has_active_questions THEN
                    UPDATE frequent_university_subtopic
                    SET is_frequent = false,
                        updated_by = p_user_id,
                        updated_at = NOW(),
                        method = 'system' 
                    WHERE university_id = v_university_id
                    AND subtopic_id = v_subtopic_id;
                END IF;
            END;
            $$;


ALTER FUNCTION odiseo.fn_delete_origin_question(p_origin_question_id integer, p_user_id integer) OWNER TO postgres;

--
