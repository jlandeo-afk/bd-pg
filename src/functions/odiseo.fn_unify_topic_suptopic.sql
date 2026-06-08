-- Function: odiseo.fn_unify_topic_suptopic(jsonb, integer)

--

CREATE FUNCTION odiseo.fn_unify_topic_suptopic(p_detail jsonb, p_user_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
        WITH 
        groups_layer AS (
            SELECT value AS group_data
            FROM jsonb_array_elements(p_detail)
        ),

        flat_items AS (
            SELECT 
                sub.ordinality AS pair_index,
                (g.group_data->>'course_id')::INT as final_course,
                (g.group_data->>'topic_id')::INT as final_topic,
                (g.group_data->>'new_name_topic') as new_name_topic,
                (g.group_data->>'last_name_topic') as last_name_topic,
                (sub.value->>'subtopic_id')::INT as final_subtopic,
                (sub.value->>'new_name_subtopic') as new_name_subtopic,
                (sub.value->>'last_name_subtopic') as last_name_subtopic
            FROM groups_layer g,
                jsonb_array_elements(g.group_data->'subtopic') WITH ORDINALITY sub
        ),

        existing_rows AS (
            SELECT 
                f.pair_index,
                n.uuid
            FROM flat_items f
            JOIN network_course_topic_subtopic n
                ON n.course_id = f.final_course
                AND n.topic_id = f.final_topic
                AND n.subtopic_id = f.final_subtopic
        ),

        pair_uuid_map AS (
            SELECT 
                p.pair_index,
                COALESCE(
                    (
                        SELECT er.uuid
                        FROM existing_rows er
                        WHERE er.pair_index = p.pair_index
                        AND er.uuid IS NOT NULL
                        LIMIT 1
                    ),
                    gen_random_uuid()
                ) as pair_uuid
            FROM (
                SELECT DISTINCT pair_index
                FROM flat_items
            ) p
        ),

        new_records AS (
            SELECT 
                m.pair_uuid,
                f.final_course,
                f.final_topic,
                f.final_subtopic,
                f.new_name_topic,
                f.last_name_topic,
                f.new_name_subtopic,
                f.last_name_subtopic
            FROM flat_items f
            JOIN pair_uuid_map m ON m.pair_index = f.pair_index
            WHERE NOT EXISTS (
                SELECT 1
                FROM network_course_topic_subtopic n
                WHERE n.course_id = f.final_course
                AND n.topic_id = f.final_topic
                AND n.subtopic_id = f.final_subtopic
            )
        ),

        inserted AS (
            INSERT INTO network_course_topic_subtopic (
                uuid, course_id, topic_id, subtopic_id, created_by, created_at,
                new_name_topic, last_name_topic, new_name_subtopic, last_name_subtopic
            )
            SELECT 
                pair_uuid,
                final_course,
                final_topic,
                final_subtopic,
                p_user_id,
                NOW(),
                new_name_topic,
                last_name_topic,
                new_name_subtopic,
                last_name_subtopic
            FROM new_records
            RETURNING topic_id, subtopic_id, new_name_topic, new_name_subtopic
        ),

        topics_to_update AS (
            SELECT DISTINCT topic_id, new_name_topic
            FROM inserted
            WHERE new_name_topic IS NOT NULL
            AND new_name_topic <> ''
        ),

        subtopics_to_update AS (
            SELECT DISTINCT subtopic_id, new_name_subtopic
            FROM inserted
            WHERE new_name_subtopic IS NOT NULL
            AND new_name_subtopic <> ''
        ),

        update_topics AS (
            UPDATE topic t
            SET name = u.new_name_topic,
                updated_at = NOW(),
                updated_by = p_user_id
            FROM topics_to_update u
            WHERE t.id = u.topic_id
            RETURNING t.id
        )

        UPDATE subtopic s
        SET name = u.new_name_subtopic,
            updated_at = NOW(),
            updated_by = p_user_id
        FROM subtopics_to_update u
        WHERE s.id = u.subtopic_id;

    END;
    $$;


ALTER FUNCTION odiseo.fn_unify_topic_suptopic(p_detail jsonb, p_user_id integer) OWNER TO postgres;

--
