-- Function: odiseo.fn_update_and_find_excluded_questions(integer, integer)

--

CREATE FUNCTION odiseo.fn_update_and_find_excluded_questions(p_week_type_material_id integer, p_deleted_by integer) RETURNS TABLE(id bigint, material_distribution_id bigint, type_material_id smallint, week smallint, course_id smallint, code_course character varying, course character varying, subtopic_id smallint, code_subtopic character varying, subtopic character varying, topic_id smallint, code_topic character varying, topic character varying, level_id bigint, level_description character varying, level_name character varying, question_id bigint, type character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_material_id bigint;
    v_week smallint;
    v_type_material_id smallint;
    v_parent_type_material_id smallint;
    v_request_date timestamp;
    v_course_id smallint;
BEGIN
    -- 1. Obtener datos de contexto para la función de faltantes
    SELECT
        m.id,
        dwtm.week,
        dwtm.type_material_id,
        dwtm.parent_type_material_id,
        COALESCE(dwtm.updated_at, NOW()) INTO v_material_id,
        v_week,
        v_type_material_id,
        v_parent_type_material_id,
        v_request_date
    FROM
        detail_week_type_mat dwtm
        JOIN material m ON dwtm.material_id = m.id
    WHERE
        dwtm.id = p_week_type_material_id;
    -- 2. Ejecutar la lógica original con CTEs y guardar resultados en tabla temporal
    DROP TABLE IF EXISTS temp_excluded_questions_result;
    CREATE TEMP TABLE temp_excluded_questions_result AS
    WITH ballot_with_questions AS (
        SELECT
            mbq.id AS id,
            mbq.id AS material_distribution_id,
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
        FROM
            material_ballot_question mbq
            INNER JOIN detail_week_type_mat dwtm ON mbq.week_type_material_id = dwtm.id
            LEFT JOIN question q ON q.id = mbq.question_id
            INNER JOIN course c ON mbq.course_id = c.id
            LEFT JOIN topic t ON t.id = mbq.topic_id
            LEFT JOIN subtopic st ON mbq.subtopic_id = st.id
            LEFT JOIN level l ON mbq.level_id = l.id
        WHERE
            1 = 1
            AND mbq.fl_status IS TRUE
            AND mbq.week_type_material_id = p_week_type_material_id
            AND EXISTS (
                SELECT
                    1
                FROM
                    question_excluded_material qem
                WHERE
                    qem.question_id = mbq.question_id
                    AND qem.material_id = dwtm.material_id
                    AND qem.deleted_at IS NULL)
),
slot_to_update AS (
    UPDATE
        material_ballot_question mbqu
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
    WHERE
        1 = 1
        AND mbqu.fl_status IS TRUE
        AND mbqu.id IN (
            SELECT
                bbd.id
            FROM
                ballot_with_questions bbd)
        RETURNING mbqu.id
),
subquestions_to_delete AS (
    UPDATE material_ballot_subquestions mbs
    SET
        fl_status = FALSE,
        deleted_at = NOW()
    WHERE mbs.material_ballot_question_id IN (SELECT su.id FROM slot_to_update su)
      AND mbs.fl_status = TRUE
    RETURNING mbs.id
),
question_history_cycle_to_update AS (
    UPDATE
        question_history_cycle qhc
    SET
        fl_status = FALSE,
        deleted_by = p_deleted_by,
        deleted_at = NOW()
    WHERE
        1 = 1
        AND qhc.id IN (
            SELECT
                question_history_id
            FROM
                ballot_with_questions WHERE question_history_id IS NOT NULL)
            AND NOT EXISTS (
                SELECT
                    1
                FROM
                    material_ballot_question mqq
                WHERE
                    1 = 1
                    AND mqq.fl_status IS TRUE
                    AND mqq.question_history_id = qhc.id
                    AND (mqq.id NOT IN (
                            SELECT
                                stu.id
                            FROM
                                slot_to_update stu)))
                    AND NOT EXISTS (
                        SELECT
                            1
                        FROM
                            material_exam_question meq
                        WHERE
                            1 = 1
                            AND meq.fl_status IS TRUE
                            AND meq.question_history_id = qhc.id)
)
SELECT
    bwq.id,
    bwq.material_distribution_id,
    bwq.type_material_id,
    bwq.week,
    bwq.course_id,
    bwq.course_code,
    bwq.course,
    bwq.subtopic_id,
    bwq.subtopic_code,
    bwq.subtopic,
    bwq.topic_id,
    bwq.topic_code,
    bwq.topic,
    bwq.level_id,
    bwq.level_description,
    bwq.level_name,
    bwq.question_id,
    bwq.type
FROM
    ballot_with_questions bwq;

    RETURN QUERY
    SELECT
        *
    FROM
        temp_excluded_questions_result;
END;
$$;


ALTER FUNCTION odiseo.fn_update_and_find_excluded_questions(p_week_type_material_id integer, p_deleted_by integer) OWNER TO postgres;

--
