-- Function: odiseo.fn_get_material_missing_question(integer, integer, bigint[], text[])

--

CREATE FUNCTION odiseo.fn_get_material_missing_question(p_perpage integer, p_npage integer, p_course_ids bigint[], p_status text[]) RETURNS TABLE(id bigint, material_id bigint, week smallint, request_date timestamp without time zone, expiration_date timestamp without time zone, total_questions bigint, completed_questions bigint, course_id smallint, course character varying, status character varying, type_material character varying, cycle character varying, company character varying, total bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    offset_val integer;
BEGIN
    offset_val := p_perpage *(p_npage - 1);
    RETURN QUERY WITH summary_missing_question_detail AS (
        SELECT
            mmqd.material_missing_question_id,
            COUNT(mmqd.*) total_questions,
            COUNT(
                CASE WHEN mmqd.status = 'completed' THEN
                    1
                END) AS completed_questions
        FROM
            material_missing_question_detail mmqd
        WHERE mmqd.deleted_at IS NULL
        GROUP BY
            mmqd.material_missing_question_id
),
filtered_data AS (
    SELECT
        mmq.id,
        mmq.material_id,
        mmq.week,
        mmq.request_date,
        mmq.expiration_date,
        COALESCE(sqd.total_questions, 0) AS total_questions,
        COALESCE(sqd.completed_questions, 0) AS completed_questions,
        mmq.course_id,
        c."name" course,
        mmq.status,
        tm.description type_material,
        cy.description cycle,
        co.commercial_name company
    FROM
        material_missing_question mmq
        JOIN material m ON m.id = mmq.material_id
        JOIN companies co ON co.id = m.company_id
        JOIN cycle cy ON cy.id = m.cycle_id
        JOIN type_material tm ON tm.id = mmq.type_material_id
        JOIN course c ON c.id = mmq.course_id
        LEFT JOIN summary_missing_question_detail sqd ON sqd.material_missing_question_id = mmq.id
    WHERE (p_course_ids IS NULL
        OR mmq.course_id = ANY (p_course_ids))
    AND (p_status IS NULL
        OR mmq.status = ANY(p_status))
    AND sqd.total_questions > 0
    AND mmq.deleted_at IS NULL
    ORDER BY
        date_trunc('minute', mmq.request_date) DESC, mmq.course_id DESC, mmq.material_id DESC, mmq.type_material_id DESC, mmq.week DESC, mmq.id DESC
),
data_with_total AS (
    SELECT
        fd.id,
        fd.material_id,
        fd.week,
        fd.request_date,
        fd.expiration_date,
        fd.total_questions,
        fd.completed_questions,
        fd.course_id,
        fd.course,
        fd.status,
        fd.type_material,
        fd.cycle,
        fd.company,
        COUNT(*) OVER () AS total
    FROM
        filtered_data fd
)
SELECT
    *
FROM
    data_with_total
LIMIT p_perpage OFFSET offset_val;
END;
$$;


ALTER FUNCTION odiseo.fn_get_material_missing_question(p_perpage integer, p_npage integer, p_course_ids bigint[], p_status text[]) OWNER TO postgres;

--
