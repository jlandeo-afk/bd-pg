-- Function: questions.fn_question_verified_material_pagination(integer, integer, jsonb, character varying, smallint, smallint, bigint, smallint, bigint)

--

CREATE FUNCTION questions.fn_question_verified_material_pagination(p_perpage integer, p_npage integer, p_subtopics_filter jsonb, p_search character varying, p_course_id smallint, p_topic_id smallint, p_subtopic_id bigint, p_level_id smallint, p_material_id bigint) RETURNS TABLE(id bigint, code character varying, course_id smallint, course text, topic_id smallint, topic text, level_id smallint, level smallint, type character varying, status character varying, subtopic_id integer, subtopic text, frequent_subtopic boolean, cycle_id integer, week smallint, type_material_id smallint, history jsonb, total_count bigint)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            offset_val INTEGER;
        BEGIN
            offset_val := p_perpage * (p_npage - 1);

            RETURN QUERY
            WITH tbl_questions_verified AS (
                SELECT
                   	fqvm.id,
                   	fqvm.code,
                   	fqvm.course_id,
					CONCAT(c.code, '-', c.name) AS course,
                   	fqvm.topic_id,
					CONCAT(t.code, '-', t.name) AS topic,
                   	fqvm.level_id,
                   	fqvm.level,
                   	fqvm.type,
                   	fqvm.status,
                   	fqvm.subtopic_id,
					CONCAT(s.code, '-', s.name) AS subtopic,
                   	fqvm.frequent_subtopic,
                   	fqvm.cycle_id,
                   	fqvm.week,
                   	fqvm.type_material_id,
                   	fqvm.history
               	FROM fn_question_verified_material(p_material_id) fqvm
				INNER JOIN course c ON fqvm.course_id = c.id
				INNER JOIN topic t ON fqvm.topic_id = t.id
				INNER JOIN subtopic s ON fqvm.subtopic_id = s.id
                WHERE fqvm.subtopic_id IN (
                    SELECT value::INT FROM jsonb_each_text(p_subtopics_filter)
                )
            ), tbl_questions_filtered AS (
                SELECT tqv.* FROM tbl_questions_verified tqv
				WHERE 1 = 1
                    AND (p_search IS NULL OR tqv.code ILIKE '%' || p_search || '%')
                    AND (p_course_id IS NULL OR tqv.course_id = p_course_id)
                    AND (p_topic_id IS NULL OR tqv.topic_id = p_topic_id)
                    AND (p_subtopic_id IS NULL OR tqv.subtopic_id = p_subtopic_id)
                    AND (p_level_id IS NULL OR tqv.level_id = p_level_id)
			)
            SELECT *, count(*) OVER () AS total_count
            FROM tbl_questions_filtered as tqv
            ORDER BY tqv.course_id ASC, tqv.topic ASC, tqv.subtopic ASC, tqv.id ASC
            LIMIT p_perpage
            OFFSET offset_val;
        END;
        $$;


ALTER FUNCTION questions.fn_question_verified_material_pagination(p_perpage integer, p_npage integer, p_subtopics_filter jsonb, p_search character varying, p_course_id smallint, p_topic_id smallint, p_subtopic_id bigint, p_level_id smallint, p_material_id bigint) OWNER TO postgres;

--
