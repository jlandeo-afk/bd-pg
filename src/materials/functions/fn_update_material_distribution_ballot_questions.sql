-- Function: materials.fn_update_material_distribution_ballot_questions(bigint, smallint, smallint, smallint, bigint, bigint, bigint, bigint, character varying, boolean, bigint)

--

CREATE FUNCTION materials.fn_update_material_distribution_ballot_questions(p_distribution_id bigint, p_position smallint, p_position_initial smallint, p_topic_id smallint, p_subtopic_id bigint, p_level_id bigint, p_usage_level_id bigint, p_question_id bigint, p_type character varying, p_usage_status boolean, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN
            UPDATE material_distribution_ballot_questions
            SET
                "position" = p_position,
                position_initial = p_position_initial,
                topic_id = p_topic_id,
                subtopic_id = p_subtopic_id,
                level_id = p_level_id,
                usage_level_id = p_usage_level_id,
                question_id = p_question_id,
                "type" = p_type,
                usage_status = p_usage_status,
                updated_by = p_updated_by,
                updated_at = NOW()
            WHERE id = p_distribution_id;
        END;
        $$;


ALTER FUNCTION materials.fn_update_material_distribution_ballot_questions(p_distribution_id bigint, p_position smallint, p_position_initial smallint, p_topic_id smallint, p_subtopic_id bigint, p_level_id bigint, p_usage_level_id bigint, p_question_id bigint, p_type character varying, p_usage_status boolean, p_updated_by bigint) OWNER TO postgres;

--
