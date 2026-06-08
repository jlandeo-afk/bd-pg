-- Function: odiseo.fn_remove_question_from_material_ballot(integer, integer, integer)

--

CREATE FUNCTION odiseo.fn_remove_question_from_material_ballot(p_week_type_material_id integer, p_deleted_by integer, p_question_id integer) RETURNS TABLE(id bigint, material_distribution_id bigint, type_material_id smallint, week smallint, course_id smallint, code_course character varying, course character varying, subtopic_id smallint, code_subtopic character varying, subtopic character varying, topic_id smallint, code_topic character varying, topic character varying, level_id bigint, level_description character varying, level_name character varying, question_id bigint, type character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH ballot_with_questions AS (
        SELECT
            mbq.id AS id,
            mbq.id AS material_distribution_id,
            mbq.type_material_id,
            mbq.week,
            mbq.course_id,
            c.code::character varying AS course_code,
            c.name::character varying AS course,
            mbq.subtopic_id,
            st.code::character varying AS subtopic_code,
            st.name::character varying AS subtopic,
            mbq.topic_id,
            t.code::character varying AS topic_code,
            t.name::character varying AS topic,
            mbq.level_id,
            l.description::character varying AS level_description,
            l.name::character varying AS level_name,
            q.id AS question_id,
            (CASE WHEN mbq.parent_question_id IS NOT NULL THEN 'T'::varchar ELSE 'D'::varchar END)::character varying AS type,
            mbq.question_history_id
        FROM odiseo.material_ballot_question mbq
        INNER JOIN odiseo.detail_week_type_mat dwtm ON mbq.week_type_material_id = dwtm.id
        LEFT JOIN odiseo.question q ON q.id = mbq.question_id
        INNER JOIN odiseo.course c ON mbq.course_id = c.id
        LEFT JOIN odiseo.topic t ON t.id = mbq.topic_id
        LEFT JOIN odiseo.subtopic st ON st.id = mbq.subtopic_id
        LEFT JOIN odiseo.level l ON mbq.level_id = l.id
        WHERE mbq.fl_status IS TRUE
        AND mbq.week_type_material_id = p_week_type_material_id
        AND mbq.question_id = p_question_id
    ),
    slot_to_update AS (
        UPDATE odiseo.material_ballot_question mbqu
        SET
            usage_level_id = NULL,
            usage_status = TRUE,
            question_id = NULL,
            parent_question_id = NULL,
            state = 'MISSING',
            updated_by = p_deleted_by,
            updated_at = NOW(),
            added_in_completion = FALSE,
            removed_in_completion = FALSE
        WHERE mbqu.id IN (SELECT bq.id FROM ballot_with_questions bq)
        RETURNING mbqu.id
    ),
    subquestions_to_delete AS (
        UPDATE odiseo.material_ballot_subquestions mbs
        SET
            fl_status = FALSE,
            deleted_at = NOW()
        WHERE mbs.material_ballot_question_id IN (SELECT su.id FROM slot_to_update su)
          AND mbs.fl_status = TRUE
        RETURNING mbs.id
    ),
    question_history_cycle_to_update AS (
        UPDATE odiseo.question_history_cycle qhc
        SET
            fl_status = FALSE,
            deleted_by = p_deleted_by,
            deleted_at = NOW()
        WHERE qhc.id IN (SELECT bq.question_history_id FROM ballot_with_questions bq WHERE bq.question_history_id IS NOT NULL)
        AND NOT EXISTS ( 
            SELECT 1 FROM odiseo.material_ballot_question mqq
            WHERE mqq.fl_status IS TRUE
            AND mqq.question_history_id = qhc.id
            AND mqq.id NOT IN (SELECT su.id FROM slot_to_update su)
        )
        AND NOT EXISTS ( 
            SELECT 1 FROM odiseo.material_exam_question meq
            WHERE meq.fl_status IS TRUE
            AND meq.question_history_id = qhc.id
        )
        RETURNING qhc.id
    )
    SELECT
        bq.id,
        bq.material_distribution_id,
        bq.type_material_id,
        bq.week,
        bq.course_id,
        bq.course_code,
        bq.course,
        bq.subtopic_id,
        bq.subtopic_code,
        bq.subtopic,
        bq.topic_id,
        bq.topic_code,
        bq.topic,
        bq.level_id,
        bq.level_description,
        bq.level_name,
        bq.question_id,
        bq.type
    FROM ballot_with_questions bq;
END;
$$;


ALTER FUNCTION odiseo.fn_remove_question_from_material_ballot(p_week_type_material_id integer, p_deleted_by integer, p_question_id integer) OWNER TO postgres;

--
