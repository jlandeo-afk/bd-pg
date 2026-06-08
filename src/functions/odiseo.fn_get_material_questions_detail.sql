-- Function: odiseo.fn_get_material_questions_detail(bigint)

--

CREATE FUNCTION odiseo.fn_get_material_questions_detail(p_material_missing_question_id bigint) RETURNS TABLE(id bigint, topic_id smallint, topic character varying, subtopic_id smallint, subtopic character varying, level_id bigint, level character varying, question_id bigint, question_code character varying, question_status character varying, type_question character varying, status character varying, course_id smallint, course character varying, employee text, employee_id bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        mmqd.id,
        mdbq.topic_id,
        t."name" topic,
        mdbq.subtopic_id,
        s."name" subtopic,
        mdbq.level_id,
        l.name level,
        q.id question_id,
        q.code question_code,
        q.status question_status,
        mdbq.type type_question,
        mmqd.status,
        mdbq.course_id,
        c."name" course,
        CONCAT_WS(' ', e.first_name, e.first_surname, e.second_surname) as employee,
        e.id as employee_id
    FROM
        material_missing_question_detail mmqd
        JOIN material_ballot_question mdbq ON mdbq.id = mmqd.material_ballot_question_id
        JOIN topic t ON t.id = mdbq.topic_id
        JOIN subtopic s ON s.id = mdbq.subtopic_id
        JOIN "level" l ON l.id = mdbq.level_id
        LEFT JOIN question q ON q.id = mmqd.question_id
        JOIN course c ON c.id = mdbq.course_id
        LEFT JOIN employees e ON e.id = mmqd.employee_id
    WHERE
        mmqd.material_missing_question_id = p_material_missing_question_id
        AND mmqd.deleted_at IS NULL
    ORDER BY
        mdbq.topic_id,
        mdbq.subtopic_id,
        mdbq.level_id;
END;
$$;


ALTER FUNCTION odiseo.fn_get_material_questions_detail(p_material_missing_question_id bigint) OWNER TO postgres;

--
