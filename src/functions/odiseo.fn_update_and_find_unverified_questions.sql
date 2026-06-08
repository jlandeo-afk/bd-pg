-- Function: odiseo.fn_update_and_find_unverified_questions(integer, integer)

--

CREATE FUNCTION odiseo.fn_update_and_find_unverified_questions(p_week_type_material_id integer, p_deleted_by integer) RETURNS TABLE(id bigint, material_distribution_id bigint, type_material_id smallint, week smallint, course_id smallint, code_course character varying, course character varying, subtopic_id smallint, code_subtopic character varying, subtopic character varying, topic_id smallint, code_topic character varying, topic character varying, level_id bigint, level_description character varying, level_name character varying, question_id bigint, type character varying)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            WITH unverified_slots AS (
                SELECT
                    mbq.id AS id,
                    dwtm.type_material_id,
                    dwtm.week,
                    mbq.course_id,
                    c.code AS course_code,
                    c.name AS course,
                    mbq.subtopic_id,
                    st.code AS subtopic_code,
                    st.name AS subtopic,
                    mbq.topic_id,
                    t.code AS topic_code,
                    t.name AS topic,
                    mbq.level_id,
                    l.description AS level_description,
                    l.name AS level_name,
                    q.id AS question_id,
                    mbq.type AS type,
                    mbq.question_history_id
                FROM material_ballot_question mbq
                INNER JOIN detail_week_type_mat dwtm ON mbq.week_type_material_id = dwtm.id
                LEFT JOIN question q ON q.id = COALESCE(mbq.question_id, mbq.parent_question_id)
                INNER JOIN course c ON mbq.course_id = c.id
                LEFT JOIN topic t ON t.id = mbq.topic_id
                LEFT JOIN subtopic st ON mbq.subtopic_id = st.id
                LEFT JOIN level l ON mbq.level_id = l.id
                WHERE 1 = 1
                  AND mbq.fl_status IS TRUE
                  AND mbq.week_type_material_id = p_week_type_material_id
                  AND q.status NOT IN ('VERI', 'APRB')
            ), slot_to_update AS (
                UPDATE material_ballot_question mbqu
                   SET
                    usage_level_id = NULL,
                    usage_status = TRUE,
                    question_id = NULL,
                    parent_question_id = NULL,
                    state = 'MISSING',
                    updated_by = p_deleted_by,
                    updated_at = NOW()
                WHERE 1 = 1
                  AND mbqu.fl_status IS TRUE
                  AND mbqu.id IN ( SELECT us.id FROM unverified_slots us )
                RETURNING mbqu.id, mbqu.question_history_id
            ), subquestions_to_delete AS (
                UPDATE material_ballot_subquestions mbs
                SET fl_status = FALSE, deleted_at = NOW()
                WHERE material_ballot_question_id IN ( SELECT id FROM slot_to_update )
                  AND fl_status = TRUE
            ), question_history_cycle_to_update AS (
                UPDATE question_history_cycle qhc
                  SET
                    fl_status = FALSE,
                    deleted_by = p_deleted_by,
                    deleted_at = NOW()
                WHERE 1 = 1
                  AND qhc.id IN ( SELECT us.question_history_id FROM unverified_slots us WHERE us.question_history_id IS NOT NULL )
                  AND NOT EXISTS( -- Que no existan question_history_id en preguntas activas de materiales balotario distintas a las que han salido en esta operación
                    SELECT 1 FROM material_ballot_question mqq
                    WHERE 1 = 1 
                      AND mqq.fl_status IS TRUE
                      AND mqq.question_history_id = qhc.id
                      AND ( mqq.id NOT IN ( SELECT id FROM slot_to_update ) )
                  )
                  AND NOT EXISTS( -- Que no existan question_history_id en preguntas activas de materiales examen distintas a las que han salido en esta operación
                    SELECT 1 FROM material_exam_question meq
                    WHERE 1 = 1
                      AND meq.fl_status IS TRUE
                      AND meq.question_history_id = qhc.id
                  )
            )
            SELECT
                us.id,
                us.id AS material_distribution_id,
                us.type_material_id,
                us.week,
                us.course_id,
                us.course_code,
                us.course,
                us.subtopic_id,
                us.subtopic_code,
                us.subtopic,
                us.topic_id,
                us.topic_code,
                us.topic,
                us.level_id,
                us.level_description,
                us.level_name,
                us.question_id,
                us.type
            FROM unverified_slots us;
        END;
        $$;


ALTER FUNCTION odiseo.fn_update_and_find_unverified_questions(p_week_type_material_id integer, p_deleted_by integer) OWNER TO postgres;

--
