-- Function: odiseo.fn_save_image_gallery(jsonb, jsonb, character varying, integer)

--

CREATE FUNCTION odiseo.fn_save_image_gallery(p_topics jsonb, p_images jsonb, p_description character varying, p_user integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
            DECLARE
                image_element JSONB;
                topic_element INTEGER;
                new_id INTEGER;
            BEGIN
                BEGIN
                    FOR image_element IN
                        SELECT * FROM jsonb_array_elements(p_images)
                    LOOP
                        INSERT INTO odiseo.image_gallery(name,extension, image, width, height,path_full_version,path_short_version,created_by, created_at)
                        VALUES (
                        	p_description,
                            image_element->>'extension',
                            image_element->>'name',
                            (image_element->>'width')::INTEGER,
                            (image_element->>'height')::INTEGER,
                            image_element->>'path_full_version',
                            image_element->>'path_short_version',
                            p_user,
                            now()
                        )
                        RETURNING id INTO new_id;
                        FOR topic_element IN
                            SELECT (jsonb_array_elements_text(p_topics))::INTEGER
                        LOOP
                            INSERT INTO odiseo.image_galery_topic (image_gallery_id, topic_id, created_by, created_at)
                            VALUES (new_id, topic_element, p_user, now());
                        END LOOP;
                    END LOOP;

                END;
            END;
            $$;


ALTER FUNCTION odiseo.fn_save_image_gallery(p_topics jsonb, p_images jsonb, p_description character varying, p_user integer) OWNER TO postgres;

--
