-- Function: academic.fn_get_syllabus_template_subtopics(integer, bigint)

--

CREATE FUNCTION academic.fn_get_syllabus_template_subtopics(p_syllabus_template_topic_id integer, p_company_id bigint) RETURNS TABLE(syllabus_template_topic_subtopic_id bigint, subtopic_id smallint, subtopic_code character varying, name text)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
                SELECT
                    stst.id,
                    stst.subtopic_id,
                    subtop.code AS subtopic_code,
                    CONCAT(subtop.code, ' - ', subtop.name) AS name
                FROM syllabus_template_topic stt
                INNER JOIN syllabus_template_topic_subtopic stst ON stst.syllabus_template_topic_id = stt.id
                    AND stst.fl_status IS true
                    AND stst.company_id = p_company_id
                INNER JOIN subtopic subtop ON subtop.id = stst.subtopic_id
                    AND subtop.fl_status IS true
                WHERE 1 = 1
                    AND stt.id = p_syllabus_template_topic_id
                    AND stt.company_id = p_company_id
                ORDER BY stst.id DESC;
        END;
        $$;


ALTER FUNCTION academic.fn_get_syllabus_template_subtopics(p_syllabus_template_topic_id integer, p_company_id bigint) OWNER TO postgres;

--
