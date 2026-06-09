-- Function: materials.fn_paginate_material_questions_detail(integer, integer, jsonb, bigint, smallint)

--

CREATE FUNCTION materials.fn_paginate_material_questions_detail(p_perpage integer, p_npage integer, p_courses jsonb, p_employee_id bigint DEFAULT NULL::bigint, p_course_id smallint DEFAULT NULL::smallint) RETURNS TABLE(id bigint, topic_id smallint, topic text, subtopic_id smallint, subtopic text, level_id bigint, level character varying, question_id bigint, question_code character varying, question_status character varying, type_question character varying, status character varying, employee_id bigint, employee character varying, course text, course_id smallint, request_date timestamp without time zone, total bigint)
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    offset_val integer;
BEGIN
    offset_val := p_perpage * (p_npage - 1);

    RETURN QUERY
    WITH filtered_data AS (
        SELECT
            mmqd.id,
            mdbq.topic_id,
            CONCAT_WS(' - ', t.code, t."name") topic,
            mdbq.subtopic_id,
            CONCAT_WS(' - ', s.code, s."name") subtopic,
            mdbq.level_id,
            l.name level,
            q.id question_id,
            q.code question_code,
            q.status question_status,
            mdbq.type type_question,
            mmqd.status,
            mmqd.employee_id,
            TRIM(CONCAT_WS(' ', e.first_name, e.first_surname, e.second_surname))::character varying AS employee,
            CONCAT_WS(' - ', c.code, c."name") course,
            c.id course_id,
            mmq.request_date
        FROM
            material_missing_question_detail mmqd
            JOIN material_missing_question mmq ON mmq.id = mmqd.material_missing_question_id
            JOIN material_ballot_question mdbq ON mdbq.id = mmqd.material_ballot_question_id
            JOIN topic t ON t.id = mdbq.topic_id
            JOIN subtopic s ON s.id = mdbq.subtopic_id
            JOIN "level" l ON l.id = mdbq.level_id
            JOIN course c ON c.id = mdbq.course_id
            LEFT JOIN question q ON q.id = mmqd.question_id
            LEFT JOIN employees e ON e.id = mmqd.employee_id
        WHERE
            (p_employee_id IS NULL OR mmqd.employee_id = p_employee_id)
            AND mdbq.course_id = ANY (
                SELECT (jsonb_array_elements_text(p_courses))::SMALLINT
            )
            AND mmqd.deleted_at IS NULL
        ORDER BY
            mmq.request_date,
            mdbq.topic_id,
            mdbq.subtopic_id,
            mdbq.level_id,
            mmqd.id DESC
    ),
    data_with_total AS (
        SELECT
            fd.id,
            fd.topic_id,
            fd.topic,
            fd.subtopic_id,
            fd.subtopic,
            fd.level_id,
            fd.level,
            fd.question_id,
            fd.question_code,
            fd.question_status,
            fd.type_question,
            fd.status,
            fd.employee_id,
            fd.employee,
            fd.course,
            fd.course_id,
            fd.request_date,
            COUNT(*) OVER () AS total
        FROM
            filtered_data fd
        WHERE (p_course_id IS NULL OR fd.course_id = p_course_id)
    )
    SELECT
        *
    FROM
        data_with_total
    LIMIT p_perpage OFFSET offset_val;
END;
$$;


ALTER FUNCTION materials.fn_paginate_material_questions_detail(p_perpage integer, p_npage integer, p_courses jsonb, p_employee_id bigint, p_course_id smallint) OWNER TO postgres;

--
