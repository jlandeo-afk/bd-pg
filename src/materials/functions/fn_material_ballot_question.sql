-- Function: materials.fn_material_ballot_question(bigint, smallint, smallint, bigint)

--

CREATE FUNCTION materials.fn_material_ballot_question(p_material_id bigint, p_week smallint, p_type_material_id smallint, p_week_type_material_id bigint) RETURNS TABLE(id bigint, material_id bigint, week smallint, type_material_id smallint, week_type_material_id bigint, course_id smallint, code_course character varying, course character varying, "position" smallint, position_initial smallint, subtopic_id smallint, code_subtopic character varying, subtopic character varying, topic_id smallint, code_topic character varying, topic character varying, level_id bigint, level_description character varying, level_name character varying, usage_level_id bigint, question_id bigint, type character varying, usage_status boolean)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            SELECT
                mbq.id,
                mbq.material_id,
                mbq.week,
                mbq.type_material_id,
                mbq.week_type_material_id,
                mbq.course_id,
                c.code AS course_code,
                c.name AS course,
                mbq.position,
                mbq.position_initial,
                mbq.subtopic_id,
                st.code AS subtopic_code,
                st.name AS subtopic,
                mbq.topic_id,
                t.code AS topic_code,
                t.name AS topic,
                mbq.level_id,
                l.description AS level_description,
                l.name AS level_name,
                mbq.usage_level_id,
                mbq.question_id,
                mbq.type,
                mbq.usage_status
            FROM materials.material_ballot_question AS mbq
            INNER JOIN academic.course AS c ON mbq.course_id = c.id
            LEFT JOIN academic.topic AS t ON mbq.topic_id = t.id
            LEFT JOIN academic.subtopic AS st ON mbq.subtopic_id = st.id
            LEFT JOIN academic.level AS l ON mbq.level_id = l.id
            WHERE
                mbq.material_id = p_material_id
                AND mbq.week = p_week
                AND mbq.type_material_id = p_type_material_id
                AND mbq.week_type_material_id = p_week_type_material_id
                AND mbq.fl_status = true
            ORDER BY mbq.course_id ASC, mbq.position ASC;
        END;
        $$;


ALTER FUNCTION materials.fn_material_ballot_question(p_material_id bigint, p_week smallint, p_type_material_id smallint, p_week_type_material_id bigint) OWNER TO postgres;

--
