-- Function: odiseo.fn_insert_material_ballot_question(bigint, smallint, smallint, bigint, smallint, smallint, smallint, bigint, smallint, bigint, bigint, bigint, character varying, boolean, bigint)

--

CREATE FUNCTION odiseo.fn_insert_material_ballot_question(p_material_id bigint, p_week smallint, p_type_material_id smallint, p_week_type_material_id bigint, p_course_id smallint, p_position smallint, p_position_initial smallint, p_subtopic_id bigint, p_topic_id smallint, p_level_id bigint, p_usage_level_id bigint, p_question_id bigint, p_type character varying, p_usage_status boolean, p_created_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN
            INSERT INTO material_ballot_question (
                material_id,
                week,
                type_material_id,
                week_type_material_id,
                course_id,
                position,
                position_initial,
                subtopic_id,
                topic_id,
                level_id,
                usage_level_id,
                question_id,
                type,
                usage_status,
                created_by,
                created_at
            )
            VALUES (
                p_material_id,
                p_week,
                p_type_material_id,
                p_week_type_material_id,
                p_course_id,
                p_position,
                p_position_initial,
                p_subtopic_id,
                p_topic_id,
                p_level_id,
                p_usage_level_id,
                p_question_id,
                p_type,
                p_usage_status,
                p_created_by,
                NOW()
            );
        END;
        $$;


ALTER FUNCTION odiseo.fn_insert_material_ballot_question(p_material_id bigint, p_week smallint, p_type_material_id smallint, p_week_type_material_id bigint, p_course_id smallint, p_position smallint, p_position_initial smallint, p_subtopic_id bigint, p_topic_id smallint, p_level_id bigint, p_usage_level_id bigint, p_question_id bigint, p_type character varying, p_usage_status boolean, p_created_by bigint) OWNER TO postgres;

--
