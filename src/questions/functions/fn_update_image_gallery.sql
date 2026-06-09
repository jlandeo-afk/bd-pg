-- Function: questions.fn_update_image_gallery(integer, jsonb, character varying, integer)

--

CREATE FUNCTION questions.fn_update_image_gallery(p_id integer, p_topics jsonb, p_description character varying, p_user_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$

        DECLARE
            v_topic_id INTEGER;
        BEGIN
            UPDATE questions.image_galery_topic AS igt
            SET fl_status = FALSE, updated_by = p_user_id, updated_at = NOW()
            WHERE igt.image_gallery_id = p_id
            AND igt.topic_id NOT IN (SELECT jsonb_array_elements_text(p_topics)::INTEGER);

            FOR v_topic_id IN SELECT jsonb_array_elements_text(p_topics)::INTEGER
            LOOP

                IF EXISTS (
                    SELECT 1
                    FROM questions.image_galery_topic AS igt
                    WHERE igt.image_gallery_id = p_id AND igt.topic_id = v_topic_id
                ) THEN

                    UPDATE questions.image_galery_topic AS igt
                    SET fl_status = TRUE, updated_by = p_user_id, updated_at = NOW()
                    WHERE igt.image_gallery_id = p_id AND igt.topic_id = v_topic_id;
                ELSE

                    INSERT INTO questions.image_galery_topic (image_gallery_id, topic_id, created_by, created_at)
                    VALUES (p_id, v_topic_id, p_user_id, NOW());
                END IF;
            END LOOP;
            UPDATE questions.image_gallery
            SET name = p_description
            WHERE id = p_id;
            END;
        $$;


ALTER FUNCTION questions.fn_update_image_gallery(p_id integer, p_topics jsonb, p_description character varying, p_user_id integer) OWNER TO postgres;

--
