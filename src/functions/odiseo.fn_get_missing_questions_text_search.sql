-- Function: odiseo.fn_get_missing_questions_text_search(bigint, smallint, smallint, smallint)

--

CREATE FUNCTION odiseo.fn_get_missing_questions_text_search(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint) RETURNS TABLE(id bigint, type_material_id smallint, material character varying, number_of_passages smallint, course_id smallint, code_course character varying, course_name character varying, category_id bigint, category character varying, subcategory_id bigint, subcategory character varying, week smallint, parent_question_id bigint, subquestion jsonb, level_id bigint, level character varying, position_initial bigint, position_text smallint, absolute_position smallint)
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    /*
                        ------------------------------------------------------------------------------------
                        -- HISTORIAL DE CAMBIOS
                        ------------------------------------------------------------------------------------
                        Versión: 1.1
                        Fecha: 2025-11-28
                        Autor: Junior Alcarraz
                        Descripción:
                            Trae preguntas texto a buscar para completar en material por periodo

                            Cambios:
                            - Se agrega la columna subquestion

                    */

                    RETURN QUERY
                    WITH type_material_ids AS (
                        SELECT
                            CASE
                                WHEN EXISTS ( SELECT 1 FROM type_material tmx WHERE tmx.parent_id = p_type_material_id )
                                THEN ARRAY( SELECT tmy.id FROM type_material tmy WHERE tmy.parent_id = p_type_material_id )
                                ELSE ARRAY[p_type_material_id]
                            END AS ids
                    ), weeks_in_type_material_ids AS (
                        SELECT
                            tmdt.week,
                            ttm.id AS child_type_material_id,
                            ttm.parent_id AS parent_type_material_id
                        FROM type_material_detail_template tmdt
                        LEFT JOIN (
                            SELECT tm.id, tm.parent_id FROM type_material tm
                            WHERE tm.id IN ( SELECT UNNEST(ids) FROM type_material_ids )
                        ) ttm ON 1 = 1
                        WHERE 1 = 1
                        AND tmdt.type_material_id = p_type_material_id
                        AND tmdt.week BETWEEN p_start_week AND p_end_week
                        AND tmdt.fl_status = true
                        ORDER BY tmdt.week ASC, ttm.id ASC
                    )
                    SELECT
                        mdbq.id,
                        dwtm.type_material_id,
                        tm.description AS material,
                        1::SMALLINT AS number_of_passages,
                        mdbq.course_id,
                        c.code AS code_course,
                        c.name AS course_name,
                        mdbq.type_text_id AS category_id,
                        tt.name AS category,
                        mdbq.type_text_subcategory_id AS subcategory_id,
                        tts.name AS subcategory,
                        mdbq.week,
                        mdbq.parent_question_id::BIGINT,
                        (SELECT JSONB_AGG(
                            JSONB_BUILD_OBJECT(
                                'question_id', mbs.question_id,
                                'position', mbs.position,
                                'topic_id', mbs.topic_id,
                                'course_id', mbs.course_id,
                                'subtopic_id', mbs.subtopic_id,
                                'status', CASE WHEN mbs.state = 'MISSING' THEN 'faltante' ELSE 'encontrado' END
                            ) ORDER BY mbs.position ASC
                        ) FROM material_ballot_subquestions mbs
                        WHERE mbs.material_ballot_question_id = mdbq.id AND mbs.fl_status = TRUE) AS subquestion,
                        mdbq.level_id,
                        l.name AS level,
                        (ROW_NUMBER() OVER (ORDER BY tt.position, tts.id) - 1) AS position_initial,
                        tt.position position_text,
                        mdbq.absolute_position
                    FROM material_ballot_question mdbq
                    JOIN detail_week_type_mat dwtm ON mdbq.week_type_material_id = dwtm.id
                    JOIN weeks_in_type_material_ids witmi ON dwtm.week = witmi.week
                        AND dwtm.type_material_id = witmi.child_type_material_id
                    JOIN type_material tm ON tm.id = dwtm.type_material_id
                    JOIN course c ON mdbq.course_id = c.id
                    JOIN type_text tt ON mdbq.type_text_id = tt.id
                    JOIN type_text_subcategories tts ON mdbq.type_text_subcategory_id = tts.id
                    JOIN level l ON mdbq.level_id = l.id
                    WHERE 1 = 1
                        AND dwtm.fl_status IS TRUE
                        AND mdbq.fl_status IS TRUE
                        AND dwtm.material_id = p_material_id
                        AND dwtm.type_material_id IN (SELECT UNNEST(ids) FROM type_material_ids)
                        AND mdbq.type_text_id IS NOT NULL
                    ORDER BY
                        dwtm.week ASC,
                        dwtm.type_material_id ASC,
                        mdbq.absolute_position ASC;
                END;
                $$;


ALTER FUNCTION odiseo.fn_get_missing_questions_text_search(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint) OWNER TO postgres;

--
