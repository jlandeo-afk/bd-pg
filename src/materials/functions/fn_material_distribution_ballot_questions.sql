-- Function: materials.fn_material_distribution_ballot_questions(bigint, smallint, smallint, bigint)

--

CREATE FUNCTION materials.fn_material_distribution_ballot_questions(p_material_id bigint, p_week smallint, p_type_material_id smallint, p_week_type_material_id bigint) RETURNS TABLE(id bigint, material_id bigint, week smallint, type_material_id smallint, week_type_material_id bigint, course_id smallint, code_course character varying, course character varying, "position" smallint, position_initial smallint, subtopic_id bigint, code_subtopic character varying, subtopic character varying, topic_id smallint, code_topic character varying, topic character varying, level_id bigint, level_description character varying, level_name character varying, usage_level_id bigint, question_id bigint, type character varying, usage_status boolean)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            SELECT
                mdqb.id,
                mdqb.material_id,
                mdqb.week,
                mdqb.type_material_id,
                mdqb.week_type_material_id,
                mdqb.course_id,
                c.code AS course_code,
                c.name AS course,
                mdqb.position,
                mdqb.position_initial,
                mdqb.subtopic_id,
                st.code AS subtopic_code,
                st.name AS subtopic,
                mdqb.topic_id,
                t.code AS topic_code,
                t.name AS topic,
                mdqb.level_id,
                l.description AS level_description,
                l.name AS level_name,
                mdqb.usage_level_id,
                mdqb.question_id,
                mdqb.type,
                mdqb.usage_status
            FROM materials.material_distribution_ballot_questions AS mdqb
            INNER JOIN academic.course AS c ON mdqb.course_id = c.id
            LEFT JOIN academic.topic AS t ON mdqb.topic_id = t.id
            LEFT JOIN academic.subtopic AS st ON mdqb.subtopic_id = st.id
            LEFT JOIN academic.level AS l ON mdqb.level_id = l.id
            WHERE
                mdqb.material_id = p_material_id
                AND mdqb.week = p_week
                AND mdqb.type_material_id = p_type_material_id
                AND mdqb.week_type_material_id = p_week_type_material_id
                AND mdqb.fl_status = true
            ORDER BY mdqb.course_id ASC, mdqb.position ASC;
        END;
        $$;


ALTER FUNCTION materials.fn_material_distribution_ballot_questions(p_material_id bigint, p_week smallint, p_type_material_id smallint, p_week_type_material_id bigint) OWNER TO postgres;

--
