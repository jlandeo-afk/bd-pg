-- Function: odiseo.fn_validate_frequent_university_subtopic(integer, smallint, integer)

--

CREATE FUNCTION odiseo.fn_validate_frequent_university_subtopic(p_question_id integer, p_university smallint, p_updated_by integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_subtopic_id INTEGER;
            v_subtopic_has_more_source_layer_completed_questions BOOLEAN DEFAULT FALSE;
        BEGIN
            DROP TABLE IF EXISTS current_question_subtopics;
            CREATE TEMP TABLE current_question_subtopics AS
            SELECT
                subtopic_id
            FROM question_subtopic qs
            WHERE qs.question_id = p_question_id
                AND qs.fl_status IS TRUE
                AND qs.deleted_at IS NULL;

            DROP TABLE IF EXISTS previous_question_subtopics;
            CREATE TEMP TABLE previous_question_subtopics AS
            SELECT
                qs.subtopic_id
            FROM question_subtopic qs
            WHERE qs.question_id = p_question_id
                AND ( qs.fl_status IS FALSE OR qs.deleted_at IS NOT NULL )
                AND qs.subtopic_id NOT IN (SELECT subtopic_id FROM current_question_subtopics)
            GROUP BY qs.subtopic_id;

            FOR v_subtopic_id IN (SELECT pqs.subtopic_id FROM previous_question_subtopics pqs)
            LOOP
                SELECT EXISTS (
                    SELECT
                        q.id
                    FROM question q
                    JOIN question_subtopic qs ON q.id = qs.question_id AND qs.fl_status IS TRUE AND qs.deleted_at IS NULL
                    JOIN frequent_university_subtopic fus ON fus.subtopic_id = qs.subtopic_id
                        AND fus.subtopic_id = v_subtopic_id
                        AND fus.university_id = p_university
                    WHERE 1 = 1
                        AND qs.deleted_at IS NULL
                        AND qs.fl_status IS TRUE
                        AND fus.is_frequent IS TRUE
                        AND fus.fl_status IS TRUE
                        AND q.id != p_question_id
                        AND q.region IS NOT NULL
                        AND q.year IS NOT NULL
                        AND q.option_id IS NOT NULL
                        AND q.modality_id IS NOT NULL
                        AND q.area IS NOT NULL
                        AND q.version IS NOT NULL
                )
                INTO v_subtopic_has_more_source_layer_completed_questions;

                IF v_subtopic_has_more_source_layer_completed_questions IS FALSE THEN
                    UPDATE frequent_university_subtopic
                        SET is_frequent = FALSE
                    WHERE 1 = 1
                        AND university_id = p_university
                        AND subtopic_id = v_subtopic_id
                        AND method = 'system';
                END IF;
            END LOOP;

            FOR v_subtopic_id IN (SELECT cqs.subtopic_id FROM current_question_subtopics cqs)
            LOOP
                INSERT INTO frequent_university_subtopic (
                    university_id,
                    subtopic_id,
                    created_at,
                    updated_by
                )
                VALUES (
                    p_university,
                    v_subtopic_id,
                    NOW(),
                    p_updated_by
                )
                ON CONFLICT (university_id, subtopic_id)
                DO UPDATE SET
                    is_frequent = TRUE,
                    fl_status = TRUE,
                    updated_at = NOW(),
                    updated_by = p_updated_by;
            END LOOP;
        END;
        $$;


ALTER FUNCTION odiseo.fn_validate_frequent_university_subtopic(p_question_id integer, p_university smallint, p_updated_by integer) OWNER TO postgres;

--
