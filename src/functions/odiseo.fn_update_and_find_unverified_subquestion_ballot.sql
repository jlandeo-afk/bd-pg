-- Function: odiseo.fn_update_and_find_unverified_subquestion_ballot(integer, integer)

--

CREATE FUNCTION odiseo.fn_update_and_find_unverified_subquestion_ballot(p_week_type_material_id integer, p_deleted_by integer) RETURNS TABLE(id bigint, material_distribution_id bigint, type_material_id smallint, week smallint, course_id smallint, code_course character varying, course character varying, subtopic_id smallint, code_subtopic character varying, subtopic character varying, topic_id smallint, code_topic character varying, topic character varying, question_id bigint)
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    RETURN QUERY
                    WITH ballot_question_unverified AS (
                        SELECT 
                            mbs.id AS id,
                            mbq.id AS material_distribution_id,
                            dwtm.type_material_id,
                            dwtm.week,
                            mbq.course_id,
                            c.code AS code_course,
                            c.name AS course,
                            mbq.subtopic_id,
                            st.code AS code_subtopic,
                            st.name AS subtopic,
                            mbq.topic_id,
                            t.code AS code_topic,
                            t.name AS topic,
                            q.id AS question_id
                        FROM odiseo.material_ballot_subquestions mbs
                        JOIN odiseo.material_ballot_question mbq ON mbq.id = mbs.material_ballot_question_id AND mbq.fl_status IS TRUE
                        INNER JOIN odiseo.detail_week_type_mat dwtm ON mbq.week_type_material_id = dwtm.id
                        JOIN odiseo.question q ON q.id = mbs.question_id AND q.fl_status IS TRUE
                        JOIN odiseo.course c ON mbq.course_id = c.id
                        JOIN odiseo.topic t ON mbq.topic_id = t.id
                        JOIN odiseo.subtopic st ON mbq.subtopic_id = st.id
                        WHERE mbs.fl_status IS TRUE
                        AND mbq.week_type_material_id = p_week_type_material_id
                        AND q.status NOT IN ('VERI', 'APRB')
                    ), 
                    distribution_to_update AS (
                        UPDATE odiseo.material_ballot_question mbq
                        SET
                        updated_at = NOW(),
                        updated_by = p_deleted_by
                        WHERE mbq.id IN (SELECT bbd.material_distribution_id FROM ballot_question_unverified bbd)
                    ), 
                    ballot_to_update AS (
                        UPDATE odiseo.material_ballot_subquestions mbs
                        SET fl_status = FALSE,
                            deleted_at = NOW()
                        WHERE mbs.id IN ( SELECT bbq.id FROM ballot_question_unverified bbq )
                        RETURNING mbs.id
                    ), 
                    question_history_cycle_to_update AS (
                        UPDATE odiseo.question_history_cycle qhc
                        SET
                            fl_status = FALSE,
                            deleted_by = p_deleted_by,
                            deleted_at = NOW()
                        WHERE qhc.question_id IN ( SELECT bbd.question_id FROM ballot_question_unverified bbd )
                          AND qhc.cycle_id = (SELECT m.cycle_id FROM odiseo.material m JOIN odiseo.detail_week_type_mat d ON d.material_id = m.id WHERE d.id = p_week_type_material_id LIMIT 1)
                          AND qhc.university_id = (SELECT m.university_id FROM odiseo.material m JOIN odiseo.detail_week_type_mat d ON d.material_id = m.id WHERE d.id = p_week_type_material_id LIMIT 1)
                          AND qhc.headquarters_id = (SELECT m.headquarte_id FROM odiseo.material m JOIN odiseo.detail_week_type_mat d ON d.material_id = m.id WHERE d.id = p_week_type_material_id LIMIT 1)
                          AND qhc.fl_status = TRUE
                    )
                    SELECT
                        *
                    FROM ballot_question_unverified;

                END;
            $$;


ALTER FUNCTION odiseo.fn_update_and_find_unverified_subquestion_ballot(p_week_type_material_id integer, p_deleted_by integer) OWNER TO postgres;

--
